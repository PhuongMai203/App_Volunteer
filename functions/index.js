// index.js (hoặc index.mjs nếu bạn muốn)

// Import theo chuẩn ES Modules
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall } from 'firebase-functions/v2/https';
import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { logger } from 'firebase-functions/v2';

import admin from 'firebase-admin';
import nodemailer from 'nodemailer';
import crypto from 'crypto';

// Khởi tạo Firebase Admin
admin.initializeApp();

// Định nghĩa secret (lấy từ Firebase Console > Environment Variables)
const emailUser = defineSecret('EMAIL_USER');
const emailPass = defineSecret('EMAIL_PASS');

// Tạo transporter Nodemailer
function createTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: emailUser.value(),
      pass: emailPass.value(),
    },
  });
}

/* ========== CLOUD FUNCTIONS ========== */

// 1. Vô hiệu hóa tài khoản người dùng
export const disableUser = onCall(
  {
    secrets: [emailUser, emailPass],
    enforceAppCheck: true,
  },
  async (request) => {
    const userId = request.data.userId;

    if (!request.auth) {
      throw new Error('Unauthenticated request');
    }

    try {
      await admin.auth().updateUser(userId, { disabled: true });
      return { success: true };
    } catch (error) {
      logger.error('Lỗi khi vô hiệu hóa người dùng:', error);
      throw new Error('INTERNAL');
    }
  }
);

// 2. Cấp quyền admin và gửi thông báo xác minh
export const setAdminRole = onCall(
  {
    secrets: [emailUser, emailPass],
    enforceAppCheck: true,
  },
  async (request) => {
    const data = request.data;
    const auth = request.auth;

    if (!auth || !auth.token.admin) {
      throw new Error('Permission denied');
    }

    const users = [
      { email: 'admin1@gmail.com' },
      { email: 'admin2@gmail.com' },
    ];

    try {
      for (const user of users) {
        const userRecord = await admin.auth().getUserByEmail(user.email);
        await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

        await admin.firestore().collection('adminLogs').add({
          action: 'GRANT_ADMIN',
          targetUserId: userRecord.uid,
          executor: auth.uid,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // Gửi FCM đến các admin đã đăng ký token
      const payload = {
        notification: {
          title: '🔔 Yêu cầu xác minh mới',
          body: `${data.businessName || 'Doanh nghiệp'} - ${data.ownerName || 'Chủ sở hữu'}`,
        },
        data: {
          screen: 'business_verification_detail',
          businessId: data.docId || '',
        },
      };

      const tokensSnapshot = await admin.firestore().collection('adminTokens').get();
      const tokens = tokensSnapshot.docs.map(doc => doc.data().token).filter(Boolean);

      if (tokens.length > 0) {
        await admin.messaging().sendToDevice(tokens, payload);
      }

      return { message: 'Cấp quyền admin thành công' };
    } catch (error) {
      logger.error('Lỗi khi cấp quyền admin:', error);
      throw new Error('INTERNAL');
    }
  }
);

// 3. Xử lý gửi email từ chối từ hàng chờ Firestore (collection: mail)
export const handleRejectionEmail = onDocumentCreated(
  {
    document: 'mail/{docId}',
    secrets: [emailUser, emailPass], // 🟢 THÊM DÒNG NÀY
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      logger.log('Không có dữ liệu');
      return;
    }
    const mailData = snap.data();
    const docRef = snap.ref;
    const transporter = createTransporter();
    await transporter.verify();

    try {
      if (!mailData.to || !mailData.message) {
        throw new Error('Thiếu trường "to" hoặc "message"');
      }
      const mailOptions = {
        from: `"Hệ thống Xác minh" <${emailUser.value()}>`,
        to: mailData.to,
        subject: mailData.message.subject || 'Thông báo từ chối xác minh',
        text: mailData.message.text,
        html: mailData.message.html || mailData.message.text,
      };
      await transporter.sendMail(mailOptions);
      logger.log(`📧 Đã gửi email đến ${mailData.to}`);
      await docRef.delete();
    } catch (error) {
      logger.error('Gửi email thất bại:', error);
      await docRef.update({
        status: 'failed',
        error: error.message,
        retries: admin.firestore.FieldValue.increment(1),
        lastAttempt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

// 4. Hàm helper để thêm email vào hàng chờ
export async function sendEmail(to, subject, text, html) {
  try {
    await admin.firestore().collection('mail').add({
      to,
      message: { subject, text, html },
      created: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.log(`📨 Đã thêm email vào queue cho: ${to}`);
  } catch (error) {
    logger.error('Lỗi khi thêm email vào queue:', error);
    throw error;
  }
}
/// TỰ ĐỘNG XÓA TÀI KHOẢN NGHƯỜI DÙNG YÊU CẦU
// Node.js (pseudocode)
export const deleteExpiredAccounts = onSchedule(
  'every 24 hours',
  async (event) => {
    const usersRef = admin.firestore().collection('users');
    const now = new Date();

    const expiredUsers = await usersRef
      .where('scheduledDeleteAt', '<=', now.toISOString())
      .get();

    if (expiredUsers.empty) {
      logger.log('✅ Không có tài khoản hết hạn để xóa.');
      return;
    }

    const deletePromises = [];

    for (const doc of expiredUsers.docs) {
      const uid = doc.id;
      logger.log(`🗑️ Xóa tài khoản UID: ${uid}`);

      deletePromises.push(
        admin.auth().deleteUser(uid)
          .then(() => doc.ref.delete())
          .catch(error => {
            logger.error(`❌ Lỗi khi xóa UID ${uid}:`, error);
          })
      );
    }

    await Promise.all(deletePromises);
    logger.log('✅ Đã xử lý xong việc xóa tài khoản hết hạn.');
  }
);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusinessVerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Định dạng ngày tháng
  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  static Future<void> _sendRejectionEmail({
    required String userEmail,
    required String userName,
    required DateTime requestDate,
    required String rejectionReason,
  }) async {
    try {
      final emailContent = '''
Kính chào $userName,
Chúng tôi đã xem xét yêu cầu xác minh doanh nghiệp của bạn gửi vào ngày ${_formatDate(requestDate)}.
Rất tiếc, sau khi kiểm tra, chúng tôi không thể chấp nhận yêu cầu do:
$rejectionReason
Vui lòng kiểm tra lại thông tin và gửi yêu cầu mới.
Trân trọng,
Bộ phận Hỗ trợ & Xác minh''';

      await _firestore.collection('mail').add({
        'to': userEmail,
        'message': {
          'subject': 'Thông báo từ chối xác minh',
          'text': emailContent,
          'html': emailContent.replaceAll('\n', '<br>'),
        },
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> rejectVerification({
    required String verificationId,
    required String rejectionReason,
  }) async {
    try {
      if (rejectionReason.trim().isEmpty) throw 'Lý do từ chối không được trống';

      final verificationRef = _firestore.collection('businessVerifications').doc(verificationId);

      await _firestore.runTransaction((tx) async {
        // Phase 1: Đọc và validate dữ liệu
        final verificationDoc = await tx.get(verificationRef);
        if (!verificationDoc.exists) throw 'Hồ sơ không tồn tại';

        final data = verificationDoc.data()!;
        final Timestamp submittedTimestamp = data['submittedAt'] as Timestamp;
        final String userEmail = data['userEmail']?.toString().trim() ?? '';
        if (userEmail.isEmpty) throw 'Email người dùng không hợp lệ';

        // Phase 2: Truy vấn thông tin user
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) throw 'Không tìm thấy người dùng';
        final userDoc = userQuery.docs.first;
        final userName = userDoc['name']?.toString() ?? 'Quý khách';

        // Phase 3: Cập nhật trạng thái
        tx.update(verificationRef, {
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'rejectionReason': rejectionReason,
        });

        // Phase 4: Gửi email
        await _sendRejectionEmail(
          userEmail: userEmail,
          userName: userName,
          requestDate: submittedTimestamp.toDate(),
          rejectionReason: rejectionReason,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  // ========================== XỬ LÝ PHÊ DUYỆT ==========================
  static Future<void> _sendApprovalEmail({
    required String userEmail,
    required String userName,
    required DateTime approvalDate,
  }) async {
    try {
      final emailContent = '''
          Kính chào $userName,
          Chúc mừng bạn! Yêu cầu xác minh doanh nghiệp của bạn đã được **PHÊ DUYỆT** vào lúc${_formatDate(approvalDate)}.
          Bạn đã có quyền truy cập đầy đủ và có thể **ĐĂNG NHẬP** vào ứng dụng bằng tài khoản của mình ngay từ bây giờ.
          Nếu có bất kỳ thắc mắc hay cần hỗ trợ, bạn vui lòng phản hồi email hỗ trợ: thiennguyen123@gmail.com.
          Trân trọng,
          ỨNG DỤNG KẾT NỐI TÌNH NGUYỆN VIÊN VỚI CỘNG ĐỒNG  
          Bộ phận Hỗ trợ & Xác minh
          ''';

      await _firestore.collection('mail').add({
        'to': userEmail,
        'message': {
          'subject': 'Thông báo phê duyệt xác minh',
          'text': emailContent,
          'html': emailContent.replaceAll('\n', '<br>'),
        },
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> approveBusinessVerification({
    required String verificationId,
  }) async {
    try {
      final verRef = _firestore.collection('businessVerifications').doc(verificationId);

      await _firestore.runTransaction((tx) async {
        // Phase 1: Đọc và validate dữ liệu
        final verificationDoc = await tx.get(verRef);
        if (!verificationDoc.exists) throw 'Hồ sơ không tồn tại';

        final data = verificationDoc.data()!;
        final String userEmail = data['userEmail']?.toString().trim() ?? '';
        if (userEmail.isEmpty) throw 'Email người dùng không hợp lệ';

        // Phase 2: Truy vấn thông tin user
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) throw 'Không tìm thấy người dùng';
        final userDoc = userQuery.docs.first;
        final userName = userDoc['name']?.toString() ?? 'Quý khách';
        final userRef = userDoc.reference;

        // Phase 3: Cập nhật trạng thái
        tx.update(userRef, {'isApproved': true});
        tx.update(verRef, {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
          'isApproved': FieldValue.delete(),
        });

        // Phase 4: Gửi email
        await _sendApprovalEmail(
          userEmail: userEmail,
          userName: userName,
          approvalDate: DateTime.now(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseBusinessRepo {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Tải ảnh lên Firebase Storage và trả về URL
  Future<String> uploadImage(File imageFile, String folderName) async {
    final fileId = const Uuid().v4();
    final ref = _storage.ref().child('$folderName/$fileId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// Gửi thông tin xác minh doanh nghiệp
  Future<void> submitBusinessVerification({
    required String userId,
    required Map<String, dynamic> data,
    File? cccdFrontImage,
    File? cccdBackImage,
    File? portraitImage,
    File? logoImage,
    File? stampImage,
  }) async {
    final Map<String, dynamic> uploadData = {...data};

    // Upload ảnh nếu có, có try-catch riêng từng ảnh
    if (cccdFrontImage != null) {
      try {
        uploadData['cccdFrontUrl'] =
        await uploadImage(cccdFrontImage, 'cccd_front');
      } catch (e) {
        print('Lỗi upload ảnh CCCD mặt trước: $e');
      }
    }

    if (cccdBackImage != null) {
      try {
        uploadData['cccdBackUrl'] =
        await uploadImage(cccdBackImage, 'cccd_back');
      } catch (e) {
        print('Lỗi upload ảnh CCCD mặt sau: $e');
      }
    }

    if (portraitImage != null) {
      try {
        uploadData['portraitUrl'] =
        await uploadImage(portraitImage, 'portrait');
      } catch (e) {
        print('Lỗi upload ảnh chân dung: $e');
      }
    }

    if (logoImage != null) {
      try {
        uploadData['logoUrl'] = await uploadImage(logoImage, 'logo');
      } catch (e) {
        print('Lỗi upload ảnh logo: $e');
      }
    }

    if (stampImage != null) {
      try {
        uploadData['stampUrl'] = await uploadImage(stampImage, 'stamp');
      } catch (e) {
        print('Lỗi upload ảnh con dấu: $e');
      }
    }

    // Thêm thông tin hệ thống
    uploadData['submittedAt'] = FieldValue.serverTimestamp();
    uploadData['status'] = 'pending';
    uploadData['verifiedBy'] = null;
    uploadData['reviewNote'] = '';

    // Gửi lên Firestore
    await _firestore
        .collection('business_verifications')
        .doc(userId)
        .set(uploadData);
  }

  /// Thêm dữ liệu mẫu (nếu cần để test)
  Future<void> addSampleVerificationData(
      String companyName,
      String repName,
      String logoUrl,
      String stampUrl,
      ) async {
    final verificationData = {
      'companyName': companyName,
      'representativeName': repName,
      'logoUrl': logoUrl,
      'stampUrl': stampUrl,
      'status': 'pending',
      'submittedAt': Timestamp.now(),
      'verifiedBy': null,
      'reviewNote': '',
    };

    await _firestore
        .collection('business_verifications')
        .add(verificationData);
  }
}

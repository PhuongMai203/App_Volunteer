import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để xử lý logic ghi và kiểm tra feedback
class CampaignFeedbackService {
  final _feedbackRef = FirebaseFirestore.instance.collection('campaign_feedback');
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  /// Kiểm tra xem user đã đánh giá chiến dịch này chưa
  Future<bool> isAlreadyFeedback({
    required String userId,
    required String campaignId,
  }) async {
    final snapshot = await _feedbackRef
        .where('userId', isEqualTo: userId)
        .where('campaignId', isEqualTo: campaignId)
        .get();
    return snapshot.docs.isNotEmpty;
  }
  /// Gửi feedback lên Firestore
  Future<void> submitFeedback({
    required String campaignId,
    required int rating,
    String? comment,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // 🔹 Lấy thông tin chiến dịch từ Firestore
    final campaignSnapshot = await FirebaseFirestore.instance
        .collection('featured_activities')
        .doc(campaignId)
        .get();

    if (!campaignSnapshot.exists) {
      throw Exception("campaign_exits".tr());
    }

    final campaignData = campaignSnapshot.data()!;
    final title = campaignData['title'] ?? "no_title".tr();
    final creatorUserId = campaignData['userId'] ?? "unknown".tr();

    // 🔹 Lấy thông tin người dùng đang đăng nhập
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final userData = userSnapshot.data() ?? {};
    final userName = userData['name'] ?? "anonymous".tr();
    final avatarUrl = userData['avatarUrl'] ?? "";  // Lấy avatarUrl an toàn

    // 🔹 Thêm feedback vào Firestore với thông tin bổ sung
    await _feedbackRef.add({
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'campaignId': campaignId,
      'title': title,
      'campaignCreatorId': creatorUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

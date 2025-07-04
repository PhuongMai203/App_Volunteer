// recommendation_engine.dart

import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationEngine {
  final FirebaseFirestore firestore;

  RecommendationEngine({required this.firestore});

  /// 1. Lấy campaignId từ đăng ký
  Future<List<String>> getRegisteredCampaignIds(String userId) async {
    final snapshot = await firestore
        .collection('campaign_registrations')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc['campaignId'] as String)
        .toList();
  }

  /// 2. Lấy campaignId từ đã ủng hộ (payments)
  Future<List<String>> getDonatedCampaignIds(String userId) async {
    final snapshot = await firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc['campaignId'] as String)
        .toList();
  }

  /// 3. Lấy danh mục yêu thích từ campaignId
  Future<List<String>> getFavoriteCategories(List<String> campaignIds) async {
    if (campaignIds.isEmpty) return [];

    final snapshot = await firestore
        .collection('featured_activities')
        .where(FieldPath.documentId, whereIn: campaignIds)
        .get();

    return snapshot.docs
        .map((doc) => doc['category'] as String)
        .toSet()
        .toList(); // loại trùng
  }

  /// 4. Lấy các chiến dịch cùng category, loại trừ các campaignId đã biết
  Future<List<Map<String, dynamic>>> getRecommendedCampaigns(
      List<String> categories,
      List<String> excludeCampaignIds,
      ) async {
    if (categories.isEmpty) return [];

    final snapshot = await firestore
        .collection('featured_activities')
        .where('category', whereIn: categories)
        .get();

    return snapshot.docs
        .where((doc) => !excludeCampaignIds.contains(doc.id))
        .map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    })
        .toList();
  }

  /// 5. Tích hợp toàn bộ
  Future<List<FeaturedActivity>> fetchRecommendedCampaigns(String userId) async {
    final registeredIds = await getRegisteredCampaignIds(userId);
    final donatedIds = await getDonatedCampaignIds(userId);

    final allRelatedIds = {...registeredIds, ...donatedIds}.toList(); // gộp và loại trùng
    final favoriteCategories = await getFavoriteCategories(allRelatedIds);

    final recommendedCampaignMaps = await getRecommendedCampaigns(
      favoriteCategories,
      allRelatedIds,
    );

    return recommendedCampaignMaps.map((data) {
      final docId = data['id'] ?? '';
      return FeaturedActivity.fromMap(data, docId);
    }).toList();
  }
}

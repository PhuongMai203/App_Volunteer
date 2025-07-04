// lib/repositories/firebase_activity_repo.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:activity_repository/src/models/models.dart';
import 'package:flutter/foundation.dart'; // để dùng debugPrint

class FirebaseActivityRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy 5 hoạt động nổi bật mới nhất từ collection "featured_activities"
  Future<List<FeaturedActivity>> fetchFeaturedActivities() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("featured_activities")
          .orderBy("startDate", descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        return FeaturedActivity.fromDocument(doc);
      }).toList();
    } catch (e) {
      throw Exception("Failed to load featured activities: \$e");
    }
  }

  /// Lấy tối đa 10 hoạt động sắp diễn ra từ collection "featured_activities"
  Future<List<FeaturedActivity>> fetchAllUpcomingActivities() async {
    final now = Timestamp.now();
    try {
      QuerySnapshot snapshot = await _db
          .collection("featured_activities")
          .where("endDate", isGreaterThan: now) // Chưa kết thúc
          .orderBy("startDate")
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        return FeaturedActivity.fromDocument(doc);
      }).toList();
    } catch (e) {
      throw Exception("Lỗi tải chiến dịch: \$e");
    }
  }

  /// Lấy hoạt động theo category
  Future<List<FeaturedActivity>> fetchActivitiesByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('featured_activities')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'upcoming')
          .get();

      return snapshot.docs.map((doc) {
        return FeaturedActivity.fromDocument(doc);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching activities by category: \$e');
    }
  }

  /// Lấy số liệu thống kê
  Future<Map<String, int>> fetchStats() async {
    try {
      int volunteerCount = 0;
      int campaignCount = 0;
      int cityCount = 0;

      // Đếm tình nguyện viên
      final usersSnapshot = await _db.collection('users').get();
      volunteerCount = usersSnapshot.docs.where((doc) {
        final role = doc['role'];
        return role != 'admin' && role != 'organization';
      }).length;

      // Đếm chiến dịch
      final featuredSnapshot = await _db.collection('featured_activities').get();
      campaignCount = featuredSnapshot.size;

      // Đếm tỉnh thành
      final addresses = featuredSnapshot.docs.map((doc) => doc['address']).toSet();
      cityCount = addresses.length;

      return {
        'volunteerCount': volunteerCount,
        'campaignCount': campaignCount,
        'cityCount': cityCount,
      };
    } catch (e) {
      throw Exception("Failed to fetch stats: \$e");
    }
  }
}

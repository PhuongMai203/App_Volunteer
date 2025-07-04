import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:activity_repository/src/models/models.dart';
import 'search_service.dart';

class ActivityService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<FeaturedActivity>> fetchActivities({
    required String searchQuery,
    required String selectedFilter,
  }) async {
    try {
      final snapshot = await _db.collection("featured_activities").get();

      final activities = snapshot.docs
          .map((doc) => FeaturedActivity.fromDocument(doc))
          .toList();

      return SearchService.filterActivities(
        activities: activities,
        searchQuery: searchQuery,
        selectedFilter: selectedFilter,
      );
    } catch (e) {
      throw Exception("${"error_loading_data".tr()} $e");
    }
  }
}

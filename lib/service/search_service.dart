import 'package:activity_repository/activity_repository.dart';

class SearchService {
  static List<FeaturedActivity> filterActivities({
    required List<FeaturedActivity> activities,
    required String searchQuery,
    required String selectedFilter,
  }) {
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      activities = activities.where((activity) =>
      activity.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          activity.category.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply sorting
    switch (selectedFilter) {
      case 'A-Z':
        activities.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'expiring':
        activities.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      default:
        activities.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    return activities;
  }
}

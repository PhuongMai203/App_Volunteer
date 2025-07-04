//CHIẾN DỊCH ĐANG DIỄN RA
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';
import '../../admin/sub_pages/upcoming_sub/campaign_card.dart';

class UpcomingCampaigns extends StatelessWidget {
  final List<FeaturedActivity> activities;

  const UpcomingCampaigns({
    super.key,
    required this.activities,
  });

  List<FeaturedActivity> _getOngoingActivities() {
    final now = DateTime.now();
    return activities.where((activity) {
      return activity.startDate.isBefore(now) && activity.endDate.isAfter(now);
    }).toList();
  }

  List<FeaturedActivity> _getUpcomingActivities() {
    final now = DateTime.now();
    return activities.where((activity) {
      return activity.startDate.isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ongoingActivities = _getOngoingActivities();
    final upcomingActivities = _getUpcomingActivities();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ongoingActivities.isNotEmpty) ...[
            ...ongoingActivities
                .map((activity) => CampaignCard(activity: activity,))
                .toList(),
            const SizedBox(height: 30),
          ],
          if (upcomingActivities.isNotEmpty) ...[
            ...upcomingActivities
                .map((activity) => CampaignCard(activity: activity,))
                .toList(),
          ],
          if (ongoingActivities.isEmpty && upcomingActivities.isEmpty)
            _buildNoContentCard("no_campaigns".tr()),
        ],
      ),
    );
  }

  Widget _buildNoContentCard(String message) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
import 'package:activity_repository/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:help_connect/components/app_colors.dart';
import '../../business/view/sub/campaign_detail.dart';
import '../campaign/campaign_detail_screen.dart';
import '../campaign/sub/campaign_feedback/campaign_detail_feedback.dart';

class EventList extends StatelessWidget {
  final List<FeaturedActivity> events;
  final String emptyMessage;
  final String userRole; // 👈 THÊM userRole
  final ValueChanged<FeaturedActivity>? onEventTap;
  final ValueChanged<int>? onUpdateDonationCount;

  const EventList({
    Key? key,
    required this.events,
    required this.emptyMessage,
    required this.userRole, // 👈 THÊM userRole
    this.onEventTap,
    this.onUpdateDonationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            emptyMessage,
            style: TextStyle(fontSize: 16, color: AppColors.deepOcean),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final now = DateTime.now();
    final donationCount = events.where((e) => e.endDate.isBefore(now)).length;
    onUpdateDonationCount?.call(donationCount);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final activity = events[index];
        final isCompleted = activity.endDate.isBefore(now);
        final displayDate = DateFormat('dd/MM/yyyy').format(activity.endDate);
        final imageUrl = activity.imageUrl.isNotEmpty
            ? activity.imageUrl
            : (activity.imageUrls.isNotEmpty ? activity.imageUrls.first : null);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: AppColors.peach,
          child: ListTile(
            leading: imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            )
                : const Icon(Icons.event, size: 40, color: Colors.green),
            title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(displayDate),
            onTap: () {
              onEventTap?.call(activity);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (userRole == 'admin') {
                      return CampaignDetailBN(activity: activity); // 👈 nếu là admin
                    }
                    return isCompleted
                        ? CampaignDetailFeedback(activity: activity)
                        : CampaignDetailScreen(activity: activity);
                  },
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF2F9E6C)),
          ),
        );
      },
    );
  }
}

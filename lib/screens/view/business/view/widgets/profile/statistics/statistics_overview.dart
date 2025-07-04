import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../components/app_colors.dart';

class StatisticsOverviewContainer extends StatelessWidget {
  const StatisticsOverviewContainer({super.key});

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("userNotLoggedIn".tr());

    final now = DateTime.now();
    final activitiesSnapshot = await FirebaseFirestore.instance
        .collection('featured_activities')
        .where('userId', isEqualTo: userId)
        .get();

    final activities = activitiesSnapshot.docs;
    int totalEvents = activities.length;

    double totalFillRate = 0.0;
    int completedEventCount = 0;

    Map<String, int> categoryCount = {};
    Map<String, double> categoryFillRates = {};

    for (var doc in activities) {
      final data = doc.data();
      final endDate = (data['endDate'] as Timestamp).toDate();
      final participantCount = data['participantCount'] ?? 0;
      final maxVolunteerCount = data['maxVolunteerCount'] ?? 1;
      final category = data['category'] ?? "genderOther".tr();

      categoryCount[category] = (categoryCount[category] ?? 0) + 1;

      if (endDate.isBefore(now)) {
        final fillRate = participantCount / maxVolunteerCount;
        totalFillRate += fillRate;
        completedEventCount++;
        categoryFillRates[category] = (categoryFillRates[category] ?? 0) + fillRate;
      }
    }

    double fillRateAvg = completedEventCount == 0 ? 0.0 : totalFillRate / completedEventCount;

    String popularCategory = "unknown".tr();
    double maxScore = -1;

    categoryCount.forEach((category, count) {
      double avgRate = (categoryFillRates[category] ?? 0.0) / count;
      double score = count * avgRate;
      if (score > maxScore) {
        maxScore = score;
        popularCategory = category;
      }
    });

    return {
      'totalEvents': totalEvents,
      'fillRate': fillRateAvg,
      'popularCategory': popularCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("errorLoadingData".tr());
        }

        final stats = snapshot.data!;
        return StatisticsOverviewWidget(
          totalEvents: stats['totalEvents'],
          fillRate: stats['fillRate'],
          popularCategory: stats['popularCategory'],
        );
      },
    );
  }
}

class StatisticsOverviewWidget extends StatelessWidget {
  final int totalEvents;
  final double fillRate;
  final String popularCategory;

  const StatisticsOverviewWidget({
    super.key,
    required this.totalEvents,
    required this.fillRate,
    required this.popularCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "activityStatisticsTitle".tr(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.deepOcean,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem("createdEvents".tr(), "$totalEvents"),
            _buildStatItem( "fillRate".tr(), "${(fillRate * 100).toStringAsFixed(1)}%"),
            _buildStatItem("popularCategory".tr(), popularCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.sunrise,
            ),
          ),
        ],
      ),
    );
  }
}

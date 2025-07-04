import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';

class VolunteerStatisticsSection extends StatelessWidget {
  const VolunteerStatisticsSection({super.key});

  Future<Map<String, dynamic>> _fetchVolunteerStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    final userId = user.uid;
    final userEmail = user.email;
    final now = DateTime.now();

    final activitiesSnapshot = await FirebaseFirestore.instance
        .collection('featured_activities')
        .where('userId', isEqualTo: userId)
        .get();

    final completedActivities = activitiesSnapshot.docs
        .where((doc) => (doc['endDate'] as Timestamp).toDate().isBefore(now))
        .toList();

    int totalCampaigns = completedActivities.length;
    int totalParticipants = 0;

    int totalRegistrations = 0;
    int totalAttendance = 0;

    List<int> birthYears = [];
    // **Xóa dòng locations = [] ở đây**
    Map<String, int> volunteerCounts = {};

    int highRatingCount = 0;

    for (var campaign in completedActivities) {
      final campaignId = campaign.id;
      final participantCount = campaign['participantCount'] ?? 0;
      totalParticipants += (participantCount as num).toInt();

      final registrationsSnapshot = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      for (var doc in registrationsSnapshot.docs) {
        totalRegistrations++;
        final status = doc.data().containsKey('attendanceStatus') ? doc['attendanceStatus'] : null;
        if (status == 'Có mặt') {
          totalAttendance++;
        }

        if (doc['email_campaign'] == userEmail) {
          if (doc['birthYear'] != null) {
            final year = doc['birthYear'];
            if (year is int) {
              birthYears.add(year);
            } else if (year is String) {
              final parsedYear = int.tryParse(year);
              if (parsedYear != null) {
                birthYears.add(parsedYear);
              }
            }
          }
        }

        String name = doc['name'] ?? '';
        if (name.isNotEmpty) {
          volunteerCounts[name] = (volunteerCounts[name] ?? 0) + 1;
        }
      }

      final feedbackSnapshot = await FirebaseFirestore.instance
          .collection('campaign_feedback')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      for (var feedback in feedbackSnapshot.docs) {
        final rating = feedback['rating'] ?? 0;
        if (rating >= 4) highRatingCount++;
      }
    }

    // --- Query riêng để lấy tất cả location của user ---
    final userRegistrationsSnapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('email_campaign', isEqualTo: userEmail)
        .get();

    List<String> locations = [];
    for (var doc in userRegistrationsSnapshot.docs) {
      if (doc['location'] != null) {
        locations.add(doc['location']);
      }
    }

    double avgVolunteersPerCampaign = totalCampaigns == 0
        ? 0.0
        : totalParticipants / totalCampaigns;

    double actualAttendanceRate = totalRegistrations == 0
        ? 0.0
        : totalAttendance / totalRegistrations;

    String mostActiveVolunteer = volunteerCounts.entries.isEmpty
        ? "Không có dữ liệu"
        : volunteerCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    double comebackRate = totalRegistrations == 0
        ? 0.0
        : highRatingCount / totalRegistrations;

    return {
      'avgVolunteers': avgVolunteersPerCampaign,
      'actualAttendanceRate': actualAttendanceRate,
      'birthYears': birthYears,
      'locations': locations,
      'mostActiveVolunteer': mostActiveVolunteer,
      'comebackRate': comebackRate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchVolunteerStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('${ "errorLoadingData".tr()} ${snapshot.error}'),
          );
        }

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "volunteerStatisticsTitle".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatItem(
                  "volunteerPerEvent".tr(),
                  '${stats['avgVolunteers'].toStringAsFixed(1)} ${"personUnit".tr()}',
                ),
                _buildStatItem(
                  "actualAttendanceRate".tr(),
                  '${(stats['actualAttendanceRate'] * 100).toStringAsFixed(1)}%',
                ),
                _buildStatItem(
                  "averageAge".tr(),
                  stats['birthYears'].isEmpty
                      ? "noData".tr()
                      : '${_calculateAverageAge(stats['birthYears'])} ${"year_old".tr()}',
                ),
                _buildStatItem(
                  "commonLocation".tr(),
                  stats['locations'].isEmpty
                      ? "noData".tr()
                      : _getMostCommonLocation(stats['locations']),
                ),
                _buildStatItem(
                  "mostActiveVolunteer".tr(),
                  stats['mostActiveVolunteer'],
                ),
                _buildStatItem(
                  "comebackRate".tr(),
                  '${(stats['comebackRate'] * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Để căn chỉnh top nếu có nhiều dòng
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.sunrise,
              ),
            ),
          ),
        ],
      ),
    );
  }


  int _calculateAverageAge(List<int> birthYears) {
    final currentYear = DateTime.now().year;
    final totalAge = birthYears.map((y) => currentYear - y).reduce((a, b) => a + b);
    return (totalAge / birthYears.length).round();
  }

  String _getMostCommonLocation(List<String> locations) {
    final count = <String, int>{};
    for (var loc in locations) {
      count[loc] = (count[loc] ?? 0) + 1;
    }
    return count.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

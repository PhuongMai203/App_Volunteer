import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class QualityStatisticsSection extends StatelessWidget {
  const QualityStatisticsSection({super.key});

  Future<Map<String, dynamic>> _fetchQualityStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("userNotLoggedIn".tr());

    final userId = user.uid;
    final userEmail = user.email;

    double totalRating = 0.0;
    int ratingCount = 0;
    int positiveCount = 0;
    int negativeCount = 0;

    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('campaign_feedback')
        .where('campaignCreatorId', isEqualTo: userId)
        .get();

    for (var doc in feedbackSnapshot.docs) {
      final rating = (doc['rating'] ?? 0).toDouble();
      totalRating += rating;
      ratingCount++;

      if (rating >= 4) {
        positiveCount++;
      } else {
        negativeCount++;
      }
    }

    double averageRating = ratingCount == 0 ? 0.0 : totalRating / ratingCount;

    final registrationsSnapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('email_campaign', isEqualTo: userEmail)
        .get();

    int totalRegs = registrationsSnapshot.docs.length;
    int attendedCount = registrationsSnapshot.docs
        .where((doc) => doc.data().containsKey('attendanceStatus') &&
        doc['attendanceStatus'] == 'Có mặt')
        .length;

    double goodVolunteerRatio =
    totalRegs == 0 ? 0.0 : attendedCount / totalRegs;

    return {
      'averageRating': averageRating,
      'positiveFeedback': positiveCount,
      'negativeFeedback': negativeCount,
      'goodVolunteerRatio': goodVolunteerRatio,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchQualityStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('${"errorLoadingData".tr()} ${snapshot.error}'),
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
                  "qualityStatisticsTitle".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "feedbackChartLabel".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: stats['positiveFeedback'].toDouble(),
                          color: Colors.green,
                          title: "positiveFeedback".tr(),
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: stats['negativeFeedback'].toDouble(),
                          color: Colors.red,
                          title:"negativeFeedback".tr(),
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                      sectionsSpace: 4,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  "qualityContributionChartLabel".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final chartHeight = constraints.maxHeight;
                      final barWidth = 20.0;
                      final spaceBetweenBars = (constraints.maxWidth - 2 * barWidth) / 3;

                      final avgRatingPercent = (stats['averageRating'] * 20).clamp(0, 100);
                      final goodVolunteerPercent = (stats['goodVolunteerRatio'] * 100).clamp(0, 100);

                      // Vị trí trái của từng thanh
                      final leftBarX = spaceBetweenBars;
                      final rightBarX = spaceBetweenBars * 2 + barWidth;

                      // Vị trí bottom tính theo phần trăm chiều cao thanh
                      final avgRatingY = chartHeight * (avgRatingPercent / 100);
                      final goodVolunteerY = chartHeight * (goodVolunteerPercent / 100);

                      return Stack(
                        children: [
                          BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return Text("averageRatingLabel".tr());
                                        case 1:
                                          return Text("goodRatioLabel".tr());
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: avgRatingPercent,
                                      color: Colors.blue,
                                      width: barWidth,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: goodVolunteerPercent,
                                      color: Colors.orange,
                                      width: barWidth,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Text trên thanh Đánh giá
                          Positioned(
                            left: leftBarX + barWidth / 2 - 15, // căn giữa thanh
                            bottom: avgRatingY + 8,
                            child: Text(
                              stats['averageRating'].toStringAsFixed(2),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          // Text trên thanh Tỷ lệ tốt
                          Positioned(
                            left: rightBarX + barWidth / 2 - 20, // căn giữa thanh
                            bottom: goodVolunteerY + 8,
                            child: Text(
                              '${(stats['goodVolunteerRatio'] * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  "averageRatingText".tr(),
                  '${stats['averageRating'].toStringAsFixed(1)} / 5',
                ),
                _buildStatItem(
                  "goodVolunteerRatioText".tr(),
                  '${(stats['goodVolunteerRatio'] * 100).toStringAsFixed(1)}%',
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
}

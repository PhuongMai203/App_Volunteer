import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../components/app_colors.dart';

class AdminChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool hasData;

  const AdminChart({super.key, required this.data, required this.hasData});

  Map<String, dynamic> _prepareChartData() {
    final userValues = <double>[];
    final campaignCreatedValues = <double>[];
    final campaignCompletedValues = <double>[];
    final donationValues = <double>[];
    final monthLabels = <String>[];

    for (int m = 1; m <= 12; m++) {
      final monthData = data.firstWhere(
            (item) => item['month'] == m,
        orElse: () => {
          'month': m,
          'users': 0, // Giá trị mặc định là int
          'created': 0, // Giá trị mặc định là int
          'completed': 0, // Giá trị mặc định là int
          'organizations': 0, // Giá trị mặc định là int
          'donation': 0.0, // Giá trị mặc định là double
        },
      );

      // Đã cập nhật để xử lý null an toàn và chuyển đổi sang double
      campaignCreatedValues.add((monthData['created'] is num ? monthData['created'] : 0).toDouble());
      campaignCompletedValues.add((monthData['completed'] is num ? monthData['completed'] : 0).toDouble());
      userValues.add((monthData['users'] is num ? monthData['users'] : 0).toDouble());
      donationValues.add((monthData['donation'] is num ? monthData['donation'] : 0).toDouble() / 100000);

      monthLabels.add(m.toString().padLeft(2, '0'));
    }

    return {
      'campaignCreatedValues': campaignCreatedValues,
      'campaignCompletedValues': campaignCompletedValues,
      'userValues': userValues,
      'donationValues': donationValues,
      'monthLabels': monthLabels,
    };
  }

  double _calculateMaxY(
      List<double> campaignCreated,
      List<double> campaignCompleted,
      List<double> users,
      List<double> donations,
      ) {
    final maxCreated = campaignCreated.isNotEmpty ? campaignCreated.reduce(max) : 0.0;
    final maxCompleted = campaignCompleted.isNotEmpty ? campaignCompleted.reduce(max) : 0.0;
    final maxUsers = users.isNotEmpty ? users.reduce(max) : 0.0;
    final maxDonations = donations.isNotEmpty ? donations.reduce(max) : 0.0;

    final overallMax = max(max(max(maxCreated, maxCompleted), maxUsers), maxDonations);

    return (overallMax > 0 ? overallMax * 1.2 : 1.0);
  }

  double _calculateMinY(
      List<double> campaignCreated,
      List<double> campaignCompleted,
      List<double> users,
      List<double> donations,
      ) {
    final minCreated = campaignCreated.isNotEmpty ? campaignCreated.reduce(min) : 0.0;
    final minCompleted = campaignCompleted.isNotEmpty ? campaignCompleted.reduce(min) : 0.0;
    final minUsers = users.isNotEmpty ? users.reduce(min) : 0.0;
    final minDonations = donations.isNotEmpty ? donations.reduce(min) : 0.0;

    final overallMin = min(min(min(minCreated, minCompleted), minUsers), minDonations);

    return overallMin < 0 ? overallMin * 1.2 : 0;
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    return (maxY / 5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();
    final campaignCreatedData = chartData['campaignCreatedValues'] as List<double>;
    final campaignCompletedData = chartData['campaignCompletedValues'] as List<double>;
    final usersData = chartData['userValues'] as List<double>;
    final donationData = chartData['donationValues'] as List<double>;
    final monthLabels = chartData['monthLabels'] as List<String>;

    final maxY = _calculateMaxY(campaignCreatedData, campaignCompletedData, usersData, donationData);
    final minY = _calculateMinY(campaignCreatedData, campaignCompletedData, usersData, donationData);
    final yInterval = _calculateInterval(maxY - minY);

    final colors = [
      Colors.blue, // Chiến dịch tạo
      Colors.green, // Chiến dịch hoàn thành
      Colors.orange, // Tình nguyện viên
      Colors.purple, // Số tiền (x100k)
    ];

    return AspectRatio(
      aspectRatio: 1.8, // Đã tăng tỷ lệ khung hình để chiều ngang dài hơn
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 8.0),
        child: Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  backgroundColor: AppColors.softBackground,
                  minY: minY,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < monthLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                monthLabels[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  barGroups: hasData
                      ? List.generate(monthLabels.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: campaignCreatedData[i],
                          color: colors[0],
                          width: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: campaignCompletedData[i],
                          color: colors[1],
                          width: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: usersData[i],
                          color: colors[2],
                          width: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: donationData[i],
                          color: colors[3],
                          width: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  })
                      : [],
                  groupsSpace: 16, // Đã tăng groupsSpace một chút để phân tách các tháng rõ hơn
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(colors[0], "legendCreatedCampaigns".tr()),
                _buildLegendItem(colors[1], "campaign_completed".tr()),
                _buildLegendItem(colors[2], "legendVolunteers".tr()),
                _buildLegendItem(colors[3], "legendDonations".tr()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
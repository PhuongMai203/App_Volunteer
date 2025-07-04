import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CampaignStatusChartManual extends StatefulWidget {
  const CampaignStatusChartManual({Key? key}) : super(key: key);

  @override
  _CampaignStatusChartManualState createState() => _CampaignStatusChartManualState();
}

class _CampaignStatusChartManualState extends State<CampaignStatusChartManual> {
  List<int> statusCounts = [0, 0, 0]; // [Ongoing, Upcoming, Ended]
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaignStatus();
  }

  Future<void> fetchCampaignStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('featured_activities').get();

      int ongoing = 0;
      int upcoming = 0;
      int ended = 0;

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? startTimestamp = data['startDate'];
        final Timestamp? endTimestamp = data['endDate'];

        if (startTimestamp != null && endTimestamp != null) {
          final startDate = startTimestamp.toDate();
          final endDate = endTimestamp.toDate();

          if (startDate.isAfter(now)) {
            upcoming++;
          } else if (startDate.isBefore(now) && endDate.isAfter(now)) {
            ongoing++;
          } else if (endDate.isBefore(now)) {
            ended++;
          }
        }
      }

      if (mounted) {
        setState(() {
          statusCounts = [ongoing, upcoming, ended];
          loading = false;
        });
      }
    } catch (e) {

      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = [
      Colors.blue.shade300,    // Ongoing
      Colors.yellow.shade200,  // Upcoming
      Colors.pink.shade200,     // Ended
    ];

    final labels = ["ongoing".tr(),"upcoming".tr(),"ended".tr(),];

    // Calculate max Y value with 20% padding
    final maxCount = statusCounts.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == value.toInt()) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                    interval: maxY > 0 ? (maxY / 5) : 1,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                  left: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              barGroups: statusCounts.asMap().entries.map((entry) {
                final index = entry.key;
                final count = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: colors[index],
                      width: 30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
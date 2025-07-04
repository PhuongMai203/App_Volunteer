import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../../components/app_colors.dart';

class CampaignBarChart extends StatefulWidget {
  const CampaignBarChart({super.key});

  @override
  State<CampaignBarChart> createState() => _CampaignBarChartState();
}

class _CampaignBarChartState extends State<CampaignBarChart> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Map<String, Map<String, double>> monthlyStats = {};
  bool isLoading = true;

  int selectedYear = DateTime.now().year;
  List<int> availableYears = [];

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final campaignsSnapshot = await FirebaseFirestore.instance
          .collection('featured_activities')
          .where('userId', isEqualTo: userId)
          .get();

      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('campaignCreatorId', isEqualTo: userId)
          .get();

      final Map<String, double> campaignDonations = {};
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        final campaignId = data['campaignId'];
        final amount = (data['amount'] ?? 0).toDouble();

        if (campaignId != null) {
          campaignDonations[campaignId] =
              (campaignDonations[campaignId] ?? 0) + amount;
        }
      }

      final Map<String, Map<String, double>> stats = {};
      final now = DateTime.now();

      for (var doc in campaignsSnapshot.docs) {
        final data = doc.data();
        final createdRaw = data['createdAt'] ?? data['createdDate'];
        final endRaw = data['endDate'];

        if (createdRaw == null || endRaw == null) {
          continue;
        }

        final createdDate = (createdRaw as Timestamp).toDate();
        final endDate = (endRaw as Timestamp).toDate();
        final campaignId = doc.id;
        final participants = (data['participantCount'] ?? 0).toDouble();

        final createdKey =
            '${createdDate.year}-${createdDate.month.toString().padLeft(2, '0')}';
        final endKey = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}';

        stats.putIfAbsent(createdKey, () => {
          'created': 0,
          'completed': 0,
          'volunteers': 0,
          'donation': 0,
        });

        stats[createdKey]!['created'] = stats[createdKey]!['created']! + 1;
        stats[createdKey]!['volunteers'] =
            stats[createdKey]!['volunteers']! + participants;

        if (endDate.isBefore(now)) {
          stats.putIfAbsent(endKey, () => {
            'created': 0,
            'completed': 0,
            'volunteers': 0,
            'donation': 0,
          });

          stats[endKey]!['completed'] = stats[endKey]!['completed']! + 1;

          final donation = campaignDonations[campaignId] ?? 0;
          stats[endKey]!['donation'] = stats[endKey]!['donation']! + donation;
        }
      }

      final currentYear = DateTime.now().year;
      availableYears = List.generate(1 + (currentYear + 5 - 2024), (i) => 2024 + i);


      setState(() {
        monthlyStats = Map.fromEntries(stats.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)));
        isLoading = false;
      });
    } catch (e, s) {

      setState(() {
        isLoading = false;
      });
    }
  }

  /// Lấy dữ liệu theo năm đã chọn, nhóm theo tháng
  Map<String, Map<String, double>> getFilteredStatsByYear(int year) {
    Map<String, Map<String, double>> filtered = {};

    for (var entry in monthlyStats.entries) {
      final key = entry.key; // "YYYY-MM"
      if (key.startsWith(year.toString())) {
        filtered[key] = entry.value;
      }
    }

    // Đảm bảo có đủ 12 tháng (nếu tháng không có dữ liệu thì set 0)
    for (int m = 1; m <= 12; m++) {
      final monthKey = '$year-${m.toString().padLeft(2, '0')}';
      filtered.putIfAbsent(monthKey, () => {
        'created': 0,
        'completed': 0,
        'volunteers': 0,
        'donation': 0,
      });
    }

    // Sắp xếp lại
    final sortedKeys = filtered.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, filtered[k]!)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (monthlyStats.isEmpty) {
      return Center(child: Text("noDataMessage".tr()));
    }

    final filteredStats = getFilteredStatsByYear(selectedYear);
    final monthKeys = filteredStats.keys.toList();

    // Màu cho 4 chỉ số
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    final maxY = filteredStats.values
        .map((e) => [
      e['created']!,
      e['completed']!,
      e['volunteers']!,
      (e['donation'] ?? 0) / 100000
    ].reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b) *
        1.2;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "chartTitle".tr(),
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Dropdown chọn năm
            if (availableYears.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "selectYearLabel".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Container khung viền cam, bo góc, nền trắng
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white, // nền trắng
                      border: Border.all(color: AppColors.coralOrange, width: 1.5), // viền màu cam
                      borderRadius: BorderRadius.circular(12), // bo góc 12
                    ),
                    // Giới hạn chiều rộng cho dropdown
                    constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: const InputDecoration.collapsed(hintText: ''),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.coralOrange),
                      isExpanded: true,
                      itemHeight: 48,
                      menuMaxHeight: 150,
                      items: availableYears.map((y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text(
                            y.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            selectedYear = v;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxY > 0 ? maxY : 1,
                  barGroups: List.generate(monthKeys.length, (i) {
                    final key = monthKeys[i];
                    final data = filteredStats[key]!;

                    return BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: data['created']!,
                          color: colors[0],
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: data['completed']!,
                          color: colors[1],
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: data['volunteers']!,
                          color: colors[2],
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: (data['donation'] ?? 0) / 100000,
                          color: colors[3],
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < monthKeys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                monthKeys[index].substring(5), // MM
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY > 0 ? maxY / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          String formatted;
                          if (value >= 1000000) {
                            formatted = '${(value / 1000000).toStringAsFixed(1)}M';
                          } else if (value >= 1000) {
                            formatted = '${(value / 1000).toStringAsFixed(1)}k';
                          } else {
                            formatted = value.toStringAsFixed(0);
                          }

                          return Text(
                            formatted,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ),

                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  groupsSpace: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(colors.length, (i) {
                final labels = [
                  "legendCreatedCampaigns".tr(),
                  "campaign_completed".tr(),
                  "legendVolunteers".tr(),
                  "legendDonations".tr(),
                ];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: colors[i],
                    ),
                    const SizedBox(width: 6),
                    Text(labels[i]),
                  ],
                );
              }),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Campaignbarchart extends StatefulWidget {
  const Campaignbarchart({Key? key}) : super(key: key);

  @override
  _CampaignbarchartState createState() => _CampaignbarchartState();
}

class _CampaignbarchartState extends State<Campaignbarchart> {
  List<String> labels = [];
  List<int> counts = [];
  bool loading = true;

  final colors = [
    Color(0xFF36a2eb),
    Color(0xFF4bc0c0),
    Color(0xFFff6384),
    Color(0xFF9966ff),
    Color(0xFFff9f40),
    Color(0xFFffcd56),
    Color(0xFFc9cbcf),
    Color(0xFF66bb6a),
    Color(0xFFf06292),
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final settingsDoc = await FirebaseFirestore.instance
          .collection('system_settings')
          .doc('main')
          .get();

      List<String> labelNames = [];
      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        if (data != null && data['categories'] is List) {
          for (var category in data['categories']) {
            if (category is Map && category.containsKey('name')) {
              labelNames.add(category['name']);
            }
          }
        }
      }

      List<int> countMap = List.filled(labelNames.length, 0);

      final activitiesSnapshot =
      await FirebaseFirestore.instance.collection('featured_activities').get();

      for (var doc in activitiesSnapshot.docs) {
        final activity = doc.data();
        final category = activity['category'];
        final index = labelNames.indexOf(category);
        if (index != -1) {
          countMap[index]++;
        }
      }

      if (mounted) {
        setState(() {
          labels = labelNames;
          counts = countMap;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = counts.fold<int>(0, (sum, element) => sum + element);

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: 'Không có dữ liệu',
          titleStyle: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ];
    }

    return List.generate(counts.length, (index) {
      final value = counts[index].toDouble();
      if (value == 0) return PieChartSectionData(value: 0);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${counts[index]}',
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    });
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: List.generate(labels.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: colors[index % colors.length],
            ),
            const SizedBox(width: 4),
            Text(
              labels[index],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }
}

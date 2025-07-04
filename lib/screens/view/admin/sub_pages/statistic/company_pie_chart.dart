import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CompanyPieChart extends StatefulWidget {
  const CompanyPieChart({Key? key}) : super(key: key);

  @override
  _CompanyPieChartState createState() => _CompanyPieChartState();
}

class _CompanyPieChartState extends State<CompanyPieChart> {
  final labels = [
    "Thực phẩm",
    "Tiền mặt",
    "Y tế",
    "Vật dụng",
    "Nhà ở",
    "Quần áo",
    "Tại chỗ",
    "Khác",
  ];

  List<int> counts = List.filled(8, 0);
  bool loading = true;

  final colors = [
    Color(0xFFff6384),
    Color(0xFF36a2eb),
    Color(0xFFffce56),
    Color(0xFF4bc0c0),
    Color(0xFF9966ff),
    Color(0xFFff9f40),
    Color(0xFFffcd56),
    Color(0xFFc9cbcf),
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('featured_activities').get();
      final countMap = List<int>.filled(labels.length, 0);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final supportType = data['supportType'];

        final index = labels.indexOf(supportType);
        if (index != -1) {
          countMap[index]++;
        }
      }

      if (mounted) {
        setState(() {
          counts = countMap;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: loading
                ? const CircularProgressIndicator()
                : PieChart(
              PieChartData(
                sections: _buildPieSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
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
        color: colors[index],
        value: value,
        title: '${counts[index]}',
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    });
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(labels.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(labels[index]),
          ],
        );
      }),
    );
  }
}

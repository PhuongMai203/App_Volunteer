import 'package:flutter/material.dart';

import '../../widgets/admin_chart.dart';
import '../../widgets/admin_repository.dart';

class AdminChartSection extends StatefulWidget {
  final int selectedYear;

  const AdminChartSection({Key? key, required this.selectedYear}) : super(key: key);

  @override
  State<AdminChartSection> createState() => _AdminChartSectionState();
}

class _AdminChartSectionState extends State<AdminChartSection> {
  final AdminRepository _repository = AdminRepository();
  bool loading = true;
  List<Map<String, dynamic>> data = [];
  bool hasData = false;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  @override
  void didUpdateWidget(covariant AdminChartSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      _loadChartData();
    }
  }

  Future<void> _loadChartData() async {
    setState(() {
      loading = true;
    });

    final fetchedData = await _repository.getYearlyMonthlyStats(widget.selectedYear);

    final _hasData = fetchedData.any((item) {
      final created = (item['created'] is num ? item['created'] : 0).toDouble();
      final completed = (item['completed'] is num ? item['completed'] : 0).toDouble();
      final users = (item['users'] is num ? item['users'] : 0).toDouble();
      final donation = (item['donation'] is num ? item['donation'] : 0).toDouble();
      return created > 0 || completed > 0 || users > 0 || donation > 0;
    });

    if (mounted) {
      setState(() {
        data = fetchedData;
        hasData = _hasData;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: AdminChart(data: data, hasData: hasData),
        ),
      ],
    );
  }
}

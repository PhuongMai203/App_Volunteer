import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../components/app_colors.dart';
import '../sub_pages/statistic/admin_chart_section.dart';
import '../sub_pages/statistic/admin_stats_row.dart';
import '../sub_pages/statistic/campaignBarChart.dart';
import '../sub_pages/statistic/campaign_status_chart.dart';
import '../sub_pages/statistic/company_pie_chart.dart';

class AdminAccountPage extends StatefulWidget {
  const AdminAccountPage({super.key});

  @override
  State<AdminAccountPage> createState() => _AdminAccountPageState();
}

class _AdminAccountPageState extends State<AdminAccountPage> {
  final AdminRepository _repository = AdminRepository();
  int _selectedYear = DateTime.now().year;
  final List<int> _years = [];

  @override
  void initState() {
    super.initState();
    _initializeYears();
  }

  void _initializeYears() {
    final now = DateTime.now();
    for (int year = 2023; year <= now.year + 5; year++) {
      _years.add(year);
    }
    _years.sort((a, b) => b.compareTo(a));
    if (!_years.contains(now.year)) {
      _years.insert(0, now.year);
      _selectedYear = now.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoutButton(),
            const SizedBox(height: 16),
            AdminStatsRow(repository: _repository),// Đây là hàng các thẻ thống kê đã được làm đẹp
            const SizedBox(height: 24),
            Center(
              child: Text(
                "statistical".tr(),
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Colors.deepOrange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAnalyticsContent(),
            const SizedBox(height: 20),

            Center(
              child: Text(
                "support_method".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900 ),
              ),
            ),
            const CompanyPieChart(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "campaign_type".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900 ),
              ),
            ),
            Campaignbarchart(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "campaign_status".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900 ),
              ),
            ),
            const SizedBox(height: 50),

            CampaignStatusChartManual(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('email');
          await prefs.remove('password');
          await prefs.remove('userType');
          await prefs.setBool('isLoggedOut', true);

          await FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase

          // Sau khi xoá toàn bộ → điều hướng lại màn hình đăng nhập
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/register');
        },

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(height: 4),
            Text(
              "logout".tr(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAnalyticsContent() {
    return AdminChartSection(selectedYear: _selectedYear);
  }
}

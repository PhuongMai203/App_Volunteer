import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:help_connect/components/app_colors.dart';

class UserStatisticsCard extends StatelessWidget {
  final num donatedAmount;
  final int campaignCount;

  const UserStatisticsCard({
    Key? key,
    required this.donatedAmount,
    required this.campaignCount,
  }) : super(key: key);

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.deepOcean)),
          ),
          const SizedBox(width: 25),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Card(
        color: const Color(0xFFFFFAF0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("activity_statistics".tr(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepOcean)),
              const SizedBox(height: 12),
              _buildRow(
                "total_donated".tr(),
                '${NumberFormat('#,###').format(donatedAmount)} VND',
              ),
              _buildRow("campaigns_participated".tr(), '$campaignCount'),
            ],
          ),
        ),
      ),
    );
  }
}

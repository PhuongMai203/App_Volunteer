import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../components/app_colors.dart';

class ActivityStatsSection extends StatelessWidget {
  final int donatedAmount;
  final int donationCount;
  final int campaignCount;
  final bool isEditing;
  final Map<String, dynamic> data;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const ActivityStatsSection({
    super.key,
    required this.donatedAmount,
    required this.donationCount,
    required this.campaignCount,
    required this.isEditing,
    required this.data,
    required this.onSave,
    required this.onCancel,
    required this.onToggleStatus,
    required this.onDelete,
  });

  Widget _buildRow(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.deepOcean)),
        ),
        Expanded(child: child),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card thống kê
        Card(
          color: const Color(0xFFFFFAF0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("activity_statistics".tr(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepOcean)),
                const SizedBox(height: 12),
                _buildRow("total_donated".tr(),
                    child: Text('$donatedAmount')),
                _buildRow("total_donations".tr(),
                    child: Text('$donationCount')),
                _buildRow("campaigns_created".tr(),
                    child: Text('$campaignCount')),
              ],
            ),
          ),
        ),

        // Khoảng cách giữa Card và Action Buttons
        const SizedBox(height: 24),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isEditing
              ? Row(children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: onSave,
                  child: Text("save_changes".tr()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sunrise,
                      minimumSize: const Size.fromHeight(48))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text("cancel".tr()),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepOcean,
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: AppColors.deepOcean)),
              ),
            ),
          ])
              : Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(data['isDisabled'] ?? false
                    ? Icons.check_circle
                    : Icons.block),
                label: Text(data['isDisabled'] ?? false
                    ? "reactivate".tr()
                    : "disable".tr()),
                style: _customButtonStyle(
                  bgColor: data['isDisabled'] ?? false
                      ? Colors.green[700]!
                      : Colors.orange[800]!,
                ),
                onPressed: onToggleStatus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete, size: 24),
                label: Text("delete".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                      const Size.fromHeight(48)),
                  side: WidgetStateProperty.all(
                    BorderSide(color: AppColors.sunrise, width: 1.5),
                  ),
                  backgroundColor:
                  WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return AppColors.sunrise;
                    }
                    return Colors.white;
                  }),
                  foregroundColor:
                  WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return AppColors.sunrise;
                  }),
                ),
                onPressed: onDelete,
              ),
            ),
          ]),
        ),
      ],
    );
  }
  ButtonStyle _customButtonStyle({
    Color bgColor = Colors.white,
    Color borderColor = Colors.transparent,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      elevation: 3,
      shadowColor: Colors.black12,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}
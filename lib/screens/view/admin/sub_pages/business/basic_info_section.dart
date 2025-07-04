import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../components/app_colors.dart';

class BasicInfoSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController phoneCtrl;
  final Map<String, dynamic> data;

  const BasicInfoSection({
    super.key,
    required this.isEditing,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.roleCtrl,
    required this.locationCtrl,
    required this.phoneCtrl,
    required this.data,
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
    return Card(
      color: const Color(0xFFFFFAF0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "basic_info".tr(),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepOcean),
            ),
            const SizedBox(height: 12),
            _buildRow(
              "name".tr(),
              child: isEditing
                  ? TextField(controller: nameCtrl)
                  : Text(data['name'] ?? '',
                  style: TextStyle(color: AppColors.slateGrey)),
            ),
            _buildRow(
              "email".tr(),
              child: isEditing
                  ? TextField(controller: emailCtrl)
                  : Text(data['email'] ?? '',
                  style: TextStyle(color: AppColors.slateGrey)),
            ),
            _buildRow(
              "role".tr(),
              child: isEditing
                  ? TextField(controller: roleCtrl)
                  : Text(data['role'] ?? '',
                  style: TextStyle(color: AppColors.slateGrey)),
            ),
            _buildRow(
              "address".tr(),
              child: isEditing
                  ? TextField(controller: locationCtrl)
                  : Text(data['location'] ?? '',
                  style: TextStyle(color: AppColors.slateGrey)),
            ),
            _buildRow(
              "phoneNumber".tr(),
              child: isEditing
                  ? TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
              )
                  : Text(data['phone'] ?? '',
                  style: TextStyle(color: AppColors.slateGrey)),
            ),
          ],
        ),
      ),
    );
  }
}
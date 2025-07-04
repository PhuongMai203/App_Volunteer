import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../components/app_colors.dart';

class BusinessInfoSection extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController taxIdController;
  final TextEditingController businessLicenseController;
  final TextEditingController addressController;
  final TextEditingController emailController;

  const BusinessInfoSection({
    Key? key,
    required this.companyNameController,
    required this.taxIdController,
    required this.businessLicenseController,
    required this.addressController,
    required this.emailController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow.shade50,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("title".tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            _buildTextField(companyNameController, "full_company_name".tr()),
            const SizedBox(height: 18),
            _buildTextField(taxIdController, "tax_id".tr()),
            const SizedBox(height: 18),
            _buildTextField(businessLicenseController, "license".tr()),
            const SizedBox(height: 18),
            _buildTextField(addressController, "head_office_address".tr()),
            const SizedBox(height: 18),
            _buildTextField(emailController, "company_email".tr(), enabled: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textPrimary),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deepOrange, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true, // <--- THÊM DÒNG NÀY: Bật chế độ đổ màu nền
        fillColor: Colors.white, // <--- THÊM DÒNG NÀY: Đặt màu nền là trắng
      ),
    );
  }
}
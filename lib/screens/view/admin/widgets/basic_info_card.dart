import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:help_connect/components/app_colors.dart';

class BasicInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isEditing;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController genderCtrl;
  final TextEditingController birthYearCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController phoneCtrl;

  const BasicInfoCard({
    Key? key,
    required this.data,
    required this.isEditing,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.roleCtrl,
    required this.genderCtrl,
    required this.birthYearCtrl,
    required this.locationCtrl,
    required this.phoneCtrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Card(
        color: const Color(0xFFFFFAF0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                  color: AppColors.deepOcean,
                ),
              ),
              const SizedBox(height: 12),
              _buildRow("name".tr(), isEditing ? TextField(controller: nameCtrl) : _buildText(data['name'])),
              _buildRow("email".tr(), isEditing ? TextField(controller: emailCtrl) : _buildText(data['email'])),
              _buildRow("role".tr(), isEditing ? TextField(controller: roleCtrl) : _buildText(data['role'])),
              _buildRow("Sex".tr(), isEditing ? TextField(controller: genderCtrl) : _buildText(data['gender'])),
              _buildRow(
                "birth_year".tr(),
                isEditing
                    ? TextField(
                  controller: birthYearCtrl,
                  keyboardType: TextInputType.number,
                )
                    : _buildText('${data['birthYear'] ?? ''}'),
              ),
              _buildRow("address".tr(), isEditing ? TextField(controller: locationCtrl) : _buildText(data['location'])),
              _buildRow(
                "phoneNumber".tr(),
                isEditing
                    ? TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                )
                    : _buildText(data['phone']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // chiều rộng cố định cho phần nhãn
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 20), // khoảng cách giữa nhãn và nội dung
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildText(String? value) {
    return Text(
      value ?? '',
      style: TextStyle(color: AppColors.slateGrey),
    );
  }
}

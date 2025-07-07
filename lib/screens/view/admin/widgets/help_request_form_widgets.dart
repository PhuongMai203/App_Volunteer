import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../components/app_colors.dart';
import '../../user/widgets/landing/landing_page_widgets.dart'; // Ensure this path is correct


Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE65100), // AppColors.sunrise color value
      ),
    ),
  );
}

Widget buildTextField(String label, Function(String?) onSave,
    {TextInputType? keyboardType, int maxLines = 1, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.deepOcean),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.peach, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? '${"please_enter_field".tr()} $label' : null,
      onSaved: onSave,
    ),
  );
}

Widget buildDisabledTextField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      enabled: false,
    ),
  );
}

Widget buildPhoneNumberField(TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "phoneNumber".tr(),
        labelStyle: TextStyle(color: AppColors.deepOcean),
        prefixText: '',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.peach, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      keyboardType: TextInputType.number,
      maxLength: 10,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "please_enter_phone".tr();
        }
        if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
          return "invalid_phone_format".tr();
        }
        return null;
      },
    ),
  );
}

Widget buildDatePickerField(String label, DateTime? selectedDate, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.deepOcean),
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFE65100)), // AppColors.sunrise
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.peach, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
        ),
      ),
      controller: TextEditingController(
        text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : "",
      ),
      onTap: onTap,
      validator: (value) => value!.isEmpty ? '${"please_select_field".tr()} $label' : null,
    ),
  );
}

Widget buildDropdownField(String label, List<String> options, Function(String?) onChanged, String? currentValue) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      value: currentValue, // Set the current value for the dropdown
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.deepOcean),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.peach, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '${"please_select_field".tr()} $label' : null,
    ),
  );
}

Widget buildCategoryGrid({
  required String? selectedCategory,
  required Function(String?) onCategorySelected,
  required BuildContext context,
  required List<Map<String, dynamic>> categories, // Bổ sung truyền danh sách
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          "categorys".tr(),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFE65100),
          ),
        ),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.4,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name']; // so sánh với name từ Firestore
          return GestureDetector(
            onTap: () => onCategorySelected(category['name']),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.peach : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.sunrise : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Center(
                child: Text(
                  category['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.orange : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      if (selectedCategory == null)
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "please_complete_all_info".tr(),
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
    ],
  );
}

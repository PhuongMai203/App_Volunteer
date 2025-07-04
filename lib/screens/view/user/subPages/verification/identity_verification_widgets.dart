import 'dart:io';
import 'package:flutter/material.dart';

Widget buildTitle(String title) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
    const SizedBox(height: 12),
  ],
);

Widget buildTextField({
  required String label,
  required FormFieldValidator<String>? validator,
  required FormFieldSetter<String>? onSaved,
  TextInputType keyboardType = TextInputType.text,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isTablet = MediaQuery.of(context).size.width > 600;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      );
    },
  );
}

Widget buildImagePicker({
  required String title,
  required File? imageFile,
  required VoidCallback onTap,
  double? height, // Cho phép tự tính height nếu không truyền
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isTablet = screenWidth > 600;
      final calculatedHeight = height ?? (isTablet ? 220 : 160);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: imageFile == null
                ? Container(
              height: calculatedHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(child: Text('Chọn ảnh')),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                height: calculatedHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      );
    },
  );
}

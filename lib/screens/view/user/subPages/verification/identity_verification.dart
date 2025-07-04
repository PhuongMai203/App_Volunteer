import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../components/app_colors.dart';
import '../../../../../components/app_gradients.dart';
import 'identity_verification_controller.dart';
import 'identity_verification_widgets.dart';

class IdentityVerificationPage extends StatefulWidget {
  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final controller = IdentityVerificationController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final primaryColor = Color(0xFFFF8A5C);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.peachPinkToOrange),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppColors.coralOrange,
              elevation: 0.5,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white, size: 26.0),
              title: Text(
                'Xác minh danh tính',
                style: GoogleFonts.agbalumo(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = isTablet
                    ? constraints.maxWidth * 0.6
                    : constraints.maxWidth;

                return Center(
                  child: Container(
                    width: contentWidth.clamp(300, 600),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('👤 Thông tin cá nhân'),
                            _inputField(
                              label: 'Họ và tên',
                              hintText: 'Nhập họ tên đầy đủ',
                              validator: (val) => (val == null || val.trim().isEmpty)
                                  ? 'Vui lòng nhập họ tên'
                                  : null,
                              onSaved: (val) => controller.fullName = val?.trim(),
                            ),
                            const SizedBox(height: 16),
                            _inputField(
                              label: 'Số CMND/CCCD',
                              hintText: 'VD: 0123456789',
                              validator: (val) => (val == null || val.trim().isEmpty)
                                  ? 'Vui lòng nhập số CMND/CCCD'
                                  : null,
                              onSaved: (val) => controller.idNumber = val?.trim(),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 28),
                            _sectionTitle('📸 Ảnh xác minh'),
                            _imagePicker(
                              label: 'Mặt trước CCCD',
                              imageFile: controller.idCardImage,
                              onPick: () => controller.pickImage(context, (file) {
                                setState(() => controller.idCardImage = file);
                              }),
                            ),
                            _imagePicker(
                              label: 'Mặt sau CCCD (tùy chọn)',
                              imageFile: controller.idCardBackImage,
                              onPick: () => controller.pickImage(context, (file) {
                                setState(() => controller.idCardBackImage = file);
                              }),
                              optional: true,
                            ),
                            _imagePicker(
                              label: 'Ảnh chân dung',
                              imageFile: controller.selfieImage,
                              onPick: () => controller.pickImage(context, (file) {
                                setState(() => controller.selfieImage = file);
                              }),
                            ),
                            const SizedBox(height: 36),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                ),
                                icon: const Icon(Icons.verified_user_rounded,
                                    size: 20, color: Colors.white),
                                label: const Text(
                                  'Gửi xác minh',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => controller.submitVerification(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  Widget _inputField({
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15)),
        SizedBox(height: 6),
        TextFormField(
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),

            // ❌ Không có viền khi chưa focus
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),

            // ✅ Có viền khi focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepOrange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }


  Widget _imagePicker({
    required String label,
    required File? imageFile,
    required VoidCallback onPick,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        if (optional)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('(Không bắt buộc)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
              image: imageFile != null
                  ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
                  : null,
            ),
            child: imageFile == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey),
                  SizedBox(height: 6),
                  Text('Chọn ảnh', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : null,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

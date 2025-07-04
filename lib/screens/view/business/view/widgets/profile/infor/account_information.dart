import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';
import '../../../../../../../components/app_colors.dart';
import 'legal_information.dart';

class AccountInformation extends StatefulWidget {
  final MyUser user;
  const AccountInformation({Key? key, required this.user}) : super(key: key);

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("update_successful".tr())),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        title: Text("edit_profile".tr(), style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: AppColors.pureWhite),
        actions: [
          TextButton.icon(
            onPressed: _saveProfile,
            icon: Icon(Icons.save, color: AppColors.pureWhite),
            label: Text(
              "save_changes".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: AppColors.pureWhite,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  "basic_info".tr(),
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                children: [
                  const SizedBox(height: 8),
                  buildTextFormField(
                    label: "name".tr(),
                    controller: _nameController,
                    validator: (value) =>
                    value == null || value.isEmpty ? "please_enter_name".tr() : null,
                  ),
                  const SizedBox(height: 16),
                  buildTextFormField(
                    label: "email".tr(),
                    initialValue: widget.user.email,
                    readOnly: true,
                  ),

                  const SizedBox(height: 16),
                  buildTextFormField(
                    label:"phoneNumber".tr(),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 24),
              const LegalInformationTile(),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildTextFormField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textPrimary),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepOrange),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepOrange, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}

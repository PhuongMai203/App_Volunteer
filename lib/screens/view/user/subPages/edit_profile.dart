import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/app_gradients.dart';

class EditProfilePage extends StatefulWidget {
  final MyUser user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  int? _selectedBirthYear;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();

    _fullNameController.text = widget.user.fullName ?? '';
    _nameController = TextEditingController(text: widget.user.name);
    _locationController = TextEditingController(text: widget.user.location ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _selectedGender = (widget.user.gender == "male" || widget.user.gender == "female")
        ? widget.user.gender
        : null;
    _selectedBirthYear = _generateYears().contains(widget.user.birthYear)
        ? widget.user.birthYear
        : null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  List<int> _generateYears() {
    final now = DateTime.now().year;
    return List.generate(now - 1920 + 1, (index) => now - index);
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedGender!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("please_select_gender".tr())),
        );
        return;
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'birthYear': _selectedBirthYear,
          'phone': _phoneController.text.trim(),
          'gender': _selectedGender,
          'address': _addressController.text.trim(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("update_successful".tr(), style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("update_failed".tr(), style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: AppColors.sunrise,
              title: Text(
                "edit_profile".tr(),
                style: GoogleFonts.agbalumo(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 26.0,
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSectionTitle("personal_information".tr()),
                    _buildCard(
                      children: [
                        _buildTextField(
                          controller: _fullNameController,
                          label: "full_name".tr(),
                          validatorMsg: "please_enter_full_name".tr(),
                        ),
                        _buildTextField(
                          controller: _nameController,
                          label: "username".tr(),
                          validatorMsg: "please_enter_name".tr(),
                        ),
                        _buildReadOnlyField(label: "email".tr(), value: widget.user.email),
                        _buildGenderRadio(),
                        _buildTextField(
                          controller: _locationController,
                          label: "current_address".tr(),
                        ),
                        _buildTextField(
                          controller: _addressController,
                          label: "permanent_address".tr(),
                        ),
                        _buildBirthYearDropdown(),
                        _buildTextField(
                          controller: _phoneController,
                          label: "phoneNumber".tr(),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save, color: AppColors.pureWhite),
                      label: Text(
                        "save_changes".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColors.pureWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepOcean),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StatefulBuilder(
        builder: (context, setState) {
          focusNode.addListener(() => setState(() {}));

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: AppColors.deepOcean, fontWeight: FontWeight.w600),
              filled: true,
              fillColor: focusNode.hasFocus
                  ? AppColors.sunrise.withOpacity(0.1)
                  : AppColors.peach.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.peach, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.sunrise, width: 2),
              ),
            ),
            validator: validator ?? (validatorMsg != null
                ? (value) => value == null || value.isEmpty ? validatorMsg : null
                : null),
          );
        },
      ),
    );
  }

  Widget _buildBirthYearDropdown() {
    final focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StatefulBuilder(
        builder: (context, setState) {
          focusNode.addListener(() => setState(() {}));

          return DropdownButtonFormField<int>(
            focusNode: focusNode,
            value: _selectedBirthYear,
            items: _generateYears().map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedBirthYear = value),
            decoration: InputDecoration(
              labelText: "birth_year".tr(),
              labelStyle: TextStyle(color: AppColors.deepOcean, fontWeight: FontWeight.w600),
              filled: true,
              fillColor: focusNode.hasFocus
                  ? AppColors.sunrise.withOpacity(0.1)
                  : AppColors.peach.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.peach, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.sunrise, width: 2),
              ),
            ),
            validator: (value) => value == null ? "select_year_of_birth".tr() : null,
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.deepOcean, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: AppColors.peach.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.peach, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.sunrise, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderRadio() {
    final genders = {
      "male": "genderMale".tr(),
      "female": "genderFemale".tr(),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "genderLabel".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: genders.entries.map((entry) {
              return Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: entry.key,
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      activeColor: AppColors.sunrise,
                    ),
                    Text(entry.value),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

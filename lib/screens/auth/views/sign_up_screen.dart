import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/app_colors.dart';
import '../../../components/app_gradients.dart';
import '../../../components/my_text_fiedl.dart';
import '../../view/user/subPages/privacy_policy_screen.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  final String userType;
  const SignUpScreen({super.key, required this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  bool signUpRequired = false;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;
  bool _isChecked = false;

  Future<void> _handleSignUp() async {
    if (_isChecked) {
      // Bước 1: Liên kết tài khoản ẩn danh với email/password
      final credential = EmailAuthProvider.credential(
        email: emailController.text,
        password: passwordController.text,
      );
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        await currentUser.linkWithCredential(credential);
      }
      // Người dùng đã tick vào checkbox => Thực hiện đăng ký
      final myUser = MyUser.empty.copyWith(
        email: emailController.text,
        name: nameController.text,
        role: widget.userType == 'organization' ? 'organization' : 'user',
        rank: "copper".tr(), // ✅ Rank mặc định
      );

      context.read<SignUpBloc>().add(
        SignUpRequired(
          myUser,
          passwordController.text,
          widget.userType, // truyền userType vào
        ),
      );
    } else {
      // Người dùng chưa tick vào checkbox => Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "please_agree_to_the_Privacy_Policy".tr(),
            style: TextStyle(
              color: AppColors.deepOcean, // Màu chữ dùng Deep Ocean
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.sunflower, // Màu nền dùng Sunflower
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: PrivacyPolicyScreen(), // Display PrivacyPolicyScreen
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
      decoration: const BoxDecoration(
      gradient: AppGradients.peachPinkToOrange,
    ),
    child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Đảm bảo AppBar trong suốt
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 36.0, color: Colors.white), // Màu icon
          onPressed: () => Navigator.pop(context),
        ), // Màu nền của AppBar
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/asd.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) {
                  if (state is SignUpSuccess) {
                    if (mounted) {
                      setState(() => signUpRequired = false);
                    }
                    // Điều hướng khác nhau dựa trên loại người dùng
                    if (widget.userType == 'organization') {
                      Navigator.pushReplacementNamed(
                        context,
                        '/business_verification',
                        arguments: {
                          'email': emailController.text,
                          'organizationName': nameController.text,
                        },
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/register');
                    }
                  } else if (state is SignUpProcess) {
                    if (mounted) {
                      setState(() => signUpRequired = true);
                    }
                  } else if (state is SignUpFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                    setState(() => signUpRequired = false);
                  }
                },
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "sign_up".tr(),
                          style: GoogleFonts.agbalumo(
                            fontSize: 34,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        MyTextField(
                          controller: emailController,
                          hintText: "email".tr(),
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(CupertinoIcons.mail_solid,
                              color: Colors.black87),
                          validator: (val) {
                            if (val?.isEmpty ?? true) {
                              return "email_required".tr();
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(val!)) {
                              return "email_invalid".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Password Field
                        MyTextField(
                          controller: passwordController,
                          hintText: "password".tr(),
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          prefixIcon: const Icon(CupertinoIcons.lock_fill,
                              color: Colors.black87),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                containsUpperCase = RegExp(r'[A-Z]').hasMatch(val);
                                containsLowerCase = RegExp(r'[a-z]').hasMatch(val);
                                containsNumber = RegExp(r'[0-9]').hasMatch(val);
                                containsSpecialChar =
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val);
                                contains8Length = val.length >= 8;
                              });
                            }
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                                iconPassword = obscurePassword
                                    ? CupertinoIcons.eye_fill
                                    : CupertinoIcons.eye_slash_fill;
                              });
                            },
                            icon: Icon(iconPassword, color: Colors.black87),
                          ),
                          validator: (val) {
                            if (val?.isEmpty ?? true) return "password_required".tr();
                            if (val!.length < 8) return  "min_8_chars".tr();
                            if (!containsUpperCase) return "missing_uppercase".tr();
                            if (!containsLowerCase) return "missing_lowercase".tr();
                            if (!containsNumber) return "missing_number".tr();
                            if (!containsSpecialChar) return "missing_special_char".tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Password Requirements
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRequirementText("requirement_uppercase".tr(), containsUpperCase),
                                  _buildRequirementText("requirement_lowercase".tr(), containsLowerCase),
                                  _buildRequirementText("requirement_number".tr(), containsNumber),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRequirementText("requirement_special_char".tr(), containsSpecialChar),
                                  _buildRequirementText("requirement_length".tr(), contains8Length),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Name Field
                        MyTextField(
                          controller: nameController,
                          hintText: widget.userType == 'organization'
                              ? "organization_name".tr()
                              : "username".tr(),
                          obscureText: false,
                          keyboardType: TextInputType.name,
                          prefixIcon: Icon(
                            widget.userType == 'organization'
                                ? CupertinoIcons.building_2_fill // icon phù hợp với tổ chức
                                : CupertinoIcons.person_fill,     // icon phù hợp với cá nhân
                            color: Colors.black87,
                          ),
                          validator: (val) {
                            if (val?.isEmpty ?? true) {
                              return widget.userType == 'organization'
                                  ? "enter_organization_name".tr()
                                  : "enter_full_name".tr();
                            }
                            if (widget.userType == 'organization' && val!.length > 50) {
                              return "organization_name_too_long".tr();
                            } else if (val!.length > 30) {
                              return "full_name_too_long".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Chính sách bảo mật + checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked = value ?? false;
                                });
                              },
                              activeColor: AppColors.sunrise,
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  Text(
                                    "I_have_read_and_agree_to_the".tr(),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _showTermsDialog(context);
                                      });
                                    },
                                    child: Text(
                                      "privacy_policy_title".tr(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.sunrise,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sign Up Button
                        !signUpRequired
                            ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _handleSignUp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sunrise,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                            child:Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical:5),
                              child: Text(
                                "sign_up".tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                            : const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildRequirementText(String text, bool isValid) {
    return Text(
      "⚈  $text",
      style: TextStyle(
        color: isValid ? Colors.green : Colors.grey[600],
        fontSize: 16,
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:help_connect/screens/auth/views/widgets/services/google_signIn_service.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../components/my_text_fiedl.dart';
import '../../blocs/sign_in_bloc/sign_in_bloc.dart';
import '../forgot_password_screen.dart';
import '../sign_up_screen.dart';
import 'auth_service.dart';

class SignInForm extends StatefulWidget {
  final String? userType;
  const SignInForm({super.key, this.userType});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  String? _emailServerError;
  String? _passwordServerError;
  String? _storedUserType;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedRole = prefs.getString('role');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      _storedUserType = savedRole;

      setState(() {
        _rememberMe = true;
      });

      final isLoggedOut = prefs.getBool('isLoggedOut') ?? false;
      if (!isLoggedOut) {
        context.read<SignInBloc>().add(SignInRequired(savedEmail, savedPassword));
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final fbToken = result.accessToken!;
        final oauthCredential = FacebookAuthProvider.credential(fbToken.tokenString);

        final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          final userData = await FacebookAuth.instance.getUserData(
            fields: "id,name,email,picture.width(500).height(500),cover",
          );
          final String avatarUrl = userData['picture']['data']['url'];
          final String? avatarStorageUrl = await _uploadAndUpdateImage(avatarUrl, true);
          final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
          await userRef.set({
            'name': firebaseUser.displayName ?? '',
            'email': firebaseUser.email ?? '',
            'avatar': avatarStorageUrl ?? '',
            'role': widget.userType ?? 'user',
          }, SetOptions(merge: true));

          await AuthService.handleSignInSuccessAndNavigate(
            context,
            widget.userType,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('facebook_login_error'.tr(args: [result.message ?? '']))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('facebook_login_error'.tr(args: [e.toString()]))),
      );
    }
  }

  Future<String?> _uploadAndUpdateImage(String imageUrl, bool isAvatar) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/${user.uid}/${isAvatar ? 'avatar' : 'cover'}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final imgBytes = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      final byteData = imgBytes.buffer.asUint8List();

      final uploadTask = storageRef.putData(byteData);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('image_upload_error'.tr(args: [e.toString()]))),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) async {
        if (state is SignInSuccess) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedOut', false);
          await AuthService.handleSignInSuccessAndNavigate(
            context,
            _storedUserType ?? widget.userType,
          );
        } else if (state is SignInFailure) {
          setState(() {
            _emailServerError = _mapError(state.emailError);
            _passwordServerError = _mapError(state.passwordError);
          });
          _formKey.currentState?.validate();
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('sign_in'.tr(), style: GoogleFonts.agbalumo(fontSize: 34, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              _buildEmailField(),
              const SizedBox(height: 30),
              _buildPasswordField(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRememberMeCheckbox(),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text('${'forgot_password'.tr()}?', style: const TextStyle(fontSize: 14, color: AppColors.sunrise, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              _buildSignInButton(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  String? _mapError(String? errorCode) {
    switch (errorCode) {
      case 'invalid-email': return 'email_invalid'.tr();
      case 'user-not-found': return 'account_not_found'.tr();
      case 'wrong-password': return 'wrong_password'.tr();
      default: return errorCode;
    }
  }

  Widget _buildEmailField() => MyTextField(
    controller: _emailController,
    hintText: 'email'.tr(),
    obscureText: false,
    keyboardType: TextInputType.emailAddress,
    prefixIcon: const Icon(CupertinoIcons.mail_solid, color: Colors.black87),
    validator: (value) {
      if (value == null || value.isEmpty) return 'email_required'.tr();
      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'email_invalid'.tr();
      return _emailServerError;
    },
    onChanged: (value) {
      if (_emailServerError != null) {
        setState(() => _emailServerError = null);
      }
      return null;
    },

  );

  Widget _buildPasswordField() => MyTextField(
    controller: _passwordController,
    hintText: 'password'.tr(),
    obscureText: _obscurePassword,
    keyboardType: TextInputType.text,
    prefixIcon: const Icon(CupertinoIcons.lock_fill, color: Colors.black87),
    suffixIcon: IconButton(
      icon: Icon(_obscurePassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill, color: Colors.black87),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'password_required'.tr();
      if (value.length < 8) return 'password_min_length'.tr(args: ['8']);
      return _passwordServerError;
    },
    onChanged: (value) {
      if (_passwordServerError != null) {
        setState(() => _passwordServerError = null);
      }
      return null;
    },
  );

  Widget _buildRememberMeCheckbox() => Row(
    children: [
      Checkbox(
        value: _rememberMe,
        onChanged: (value) => setState(() => _rememberMe = value!),
        activeColor: AppColors.sunrise,
      ),
      Text('remember_me'.tr()),
    ],
  );

  Widget _buildSignInButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final email = _emailController.text;
          final password = _passwordController.text;

          final prefs = await SharedPreferences.getInstance();
          if (_rememberMe) {
            await prefs.setString('email', email);
            await prefs.setString('password', password);
            await prefs.setString('role', widget.userType ?? 'user');
            await prefs.setBool('isLoggedOut', false);
          } else {
            await prefs.remove('email');
            await prefs.remove('password');
            await prefs.remove('role');
            await prefs.setBool('isLoggedOut', true);
          }

          context.read<SignInBloc>().add(SignInRequired(email, password));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sunrise,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('sign_in_button'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildFooter() => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("no_account".tr(), style: const TextStyle(fontSize: 12, color: Colors.black87)),
          TextButton(
            onPressed: () {
              final type = widget.userType ?? 'user';
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(userType: type)));
            },
            child: Text("signup".tr(), style: const TextStyle(fontSize: 16, color: AppColors.sunrise, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text("or".tr(), style: const TextStyle(fontSize: 16, color: Colors.black54)),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final userCredential = await GoogleSignInService.signInWithGoogle(userType: widget.userType ?? 'user');
              if (userCredential != null) {
                final firebaseUser = userCredential.user;
                if (firebaseUser != null) {

                  final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
                  await userRef.set({
                    'name': firebaseUser.displayName ?? '',
                    'email': firebaseUser.email ?? '',
                    'avatar': firebaseUser.photoURL,
                    'role': widget.userType ?? 'user',
                  }, SetOptions(merge: true));

                  await AuthService.handleSignInSuccessAndNavigate(
                    context,
                    widget.userType,
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('google_sign_in_failed'.tr())));
              }
            },
            child: Image.asset('assets/google_logo.png', height: 60),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _handleFacebookSignIn,
            child: Image.asset('assets/facebook.png', height: 70),
          ),
        ],
      ),
    ],
  );
}
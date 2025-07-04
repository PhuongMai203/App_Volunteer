import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("enter_email".tr(), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("email_sent_generic".tr(), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'invalid-email') {
        errorMsg = 'email_invalid'.tr();
      } else {
        errorMsg = 'email_sent_generic'.tr();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
          backgroundColor: e.code == 'invalid-email' ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error'.tr(namedArgs: {'message': e.toString()}), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("forgot_password".tr()),
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double formWidth = screenWidth * 0.85;
          if (formWidth > 500) formWidth = 500;

          double padding = screenWidth < 400 ? 16 : 24;
          double borderRadius = screenWidth < 400 ? 10 : 15;
          double fontSizeTitle = screenWidth < 360 ? 14 : 16;
          double inputFontSize = screenWidth < 360 ? 14 : 16;
          double buttonHeight = screenHeight * 0.065;
          if (buttonHeight < 48) buttonHeight = 48;
          if (buttonHeight > 60) buttonHeight = 60;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/asd.png',
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Container(
                  width: formWidth,
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "enter_email_reset_password".tr(),
                        style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.orangeAccent, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
                          ),
                          labelText: "email".tr(),
                          labelStyle: TextStyle(color: Colors.orange[800]),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: inputFontSize),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: sendPasswordResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA320),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "submit_button".tr(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

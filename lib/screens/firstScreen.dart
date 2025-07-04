import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:help_connect/screens/auth/views/sign_in_screen.dart';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:help_connect/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';

import 'view/user/main_pages/landing_page.dart';
import 'view/user/widgets/language_selector.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double topPadding = screenHeight * 0.03;
          double sidePadding = screenWidth * 0.05;
          double buttonHeight = screenHeight * 0.07;
          if (buttonHeight < 50) buttonHeight = 50;
          if (buttonHeight > 70) buttonHeight = 70;

          double titleFontSize = screenWidth < 360 ? 28 : 38;
          double descFontSize = screenWidth < 360 ? 16 : 22;
          double whoAreYouFontSize = screenWidth < 360 ? 20 : 26;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/asd.png', fit: BoxFit.cover),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.2),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Section: Language Selector and Skip Button
                          Padding(
                            padding: EdgeInsets.only(top: topPadding, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const LanguageSelector(),
                                _buildSkipButton(context),
                              ],
                            ),
                          ),

                          const Spacer(flex: 3),

                          // Middle Section: Welcome Text and Description
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "welcome".tr(),
                                style: GoogleFonts.agbalumo(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amberAccent,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 15.0,
                                      color: Colors.blueGrey,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                                child: Column(
                                  children: [
                                    Text(
                                      "description".tr(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.agbalumo(
                                        fontSize: descFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      "who_are_you".tr(),
                                      style: GoogleFonts.agbalumo(
                                        fontSize: whoAreYouFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amberAccent,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 12.0,
                                            color: Colors.black87,
                                            offset: Offset(1.5, 1.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Spacer(flex: 2),

                          // Bottom Section: Role Selection Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  text: "volunteer".tr(),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => BlocProvider(
                                          create: (_) => SignInBloc(ctx.read<UserRepository>()),
                                          child: const SignInScreen(userType: "volunteer"),
                                        ),
                                      ),
                                    );
                                  },
                                  backgroundColor: AppColors.sunrise,
                                  textColor: Colors.white,
                                  borderColor: AppColors.sunrise,
                                  height: buttonHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Expanded(
                                child: _buildButton(
                                  text: "organization".tr(),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => BlocProvider(
                                          create: (_) => SignInBloc(ctx.read<UserRepository>()),
                                          child: const SignInScreen(userType: "organization"),
                                        ),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.white,
                                  textColor: AppColors.coralOrange,
                                  borderColor: Colors.white,
                                  height: buttonHeight,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 50, end: 0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: 1 - (value / 50),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                );
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "skip".tr(),
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 2),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

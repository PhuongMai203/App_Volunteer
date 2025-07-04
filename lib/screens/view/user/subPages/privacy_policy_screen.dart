import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'thiennguyen@gmail.com',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? 36.0 : 24.0;
    final titleFontSize = isTablet ? 28.0 : 26.0;
    final sectionFontSize = isTablet ? 20.0 : 18.0;
    final paragraphFontSize = isTablet ? 18.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.sunrise, size: 36.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "privacy_policy_title".tr(),
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepOcean,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: paragraphFontSize, color: AppColors.deepOcean),
                  children: [
                    TextSpan(text: 'app_name'.tr()),
                    TextSpan(
                      text: "app_full_name".tr(),
                      style: const TextStyle(
                        color: AppColors.sunrise,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: "app_description".tr()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("section_1_title".tr(), sectionFontSize),
              _buildParagraph("paragraph_1".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_2_title".tr(), sectionFontSize),
              _buildBullet("bullet_1_1".tr(), paragraphFontSize),
              _buildBullet("bullet_1_2".tr(), paragraphFontSize),
              _buildBullet("bullet_1_3".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_3_title".tr(), sectionFontSize),
              _buildParagraph("paragraph_2_1".tr(), paragraphFontSize),
              _buildParagraph("paragraph_2_2".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_4_title".tr(), sectionFontSize),
              _buildParagraph("paragraph_3_1".tr(), paragraphFontSize),
              _buildParagraph("paragraph_3_2".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_5_title".tr(), sectionFontSize),
              _buildParagraph("paragraph_4_1".tr(), paragraphFontSize),
              _buildBullet("bullet_4_1".tr(), paragraphFontSize),
              _buildBullet("bullet_4_2".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_6_title".tr(), sectionFontSize),
              _buildParagraph("paragraph_5".tr(), paragraphFontSize),
              const SizedBox(height: 10),
              _buildSectionTitle("section_7_title".tr(), sectionFontSize),
              Text.rich(
                TextSpan(
                  text: "contact_text_1".tr(),
                  style: TextStyle(fontSize: paragraphFontSize, color: AppColors.slateGrey),
                  children: [
                    TextSpan(
                      text: 'thiennguyen@gmail.com',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _launchEmail,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2A3B4D),
      ),
    );
  }

  Widget _buildParagraph(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: const Color(0xFF6C7A89)),
    );
  }

  Widget _buildBullet(String text, double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(fontSize: fontSize, color: const Color(0xFF6C7A89))),
        Expanded(child: _buildParagraph(text, fontSize)),
      ],
    );
  }
}

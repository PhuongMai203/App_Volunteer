import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<Map<String, dynamic>?> _fetchPolicySettings() async {
    final doc = await FirebaseFirestore.instance.collection('system_settings').doc('main').get();
    if (doc.exists) {
      return doc.data()?['policySettings'];
    }
    return null;
  }

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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchPolicySettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("Không thể tải dữ liệu chính sách."));
            }

            final policySettings = snapshot.data!;
            final privacyPolicy = policySettings['privacyPolicy'] ?? '';
            final termsOfUse = policySettings['termsOfUse'] ?? '';
            final volunteerPolicy = policySettings['volunteerPolicy'] ?? '';

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chính sách & Điều khoản",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepOcean,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Chính sách quyền riêng tư", sectionFontSize),
                  _buildParagraph(privacyPolicy, paragraphFontSize),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Điều khoản sử dụng", sectionFontSize),
                  _buildParagraph(termsOfUse, paragraphFontSize),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Chính sách tình nguyện viên", sectionFontSize),
                  _buildParagraph(volunteerPolicy, paragraphFontSize),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Liên hệ", sectionFontSize),
                  Text.rich(
                    TextSpan(
                      text: "Mọi thắc mắc vui lòng liên hệ: ",
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
            );
          },
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:help_connect/components/app_colors.dart';
import '../../../admin/sub_pages/business/header_business.dart';
import '../widgets/nav_bar.dart';
import '../widgets/profile/account_settings_BN.dart';
import '../widgets/profile/campaign_count_card.dart';
import '../widgets/profile/statistics/campaign_line_chart.dart';
import '../widgets/profile/statistics/quality_statistics.dart';
import '../widgets/profile/statistics/statistics_overview.dart';
import '../widgets/profile/statistics/volunteer_statistics.dart';

class AccountBn extends StatefulWidget {
  const AccountBn({super.key});

  @override
  _AccountBnState createState() => _AccountBnState();
}

class _AccountBnState extends State<AccountBn> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool _isLoading = false;
  int _selectedIndex = 4;
  bool _showStats = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userData = doc.data() ?? {};
      });
    }
    setState(() => _isLoading = false);
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/partner-home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/my-campaigns');
        break;
      case 2:
        Navigator.pushNamed(context, '/completed-campaigns');
        break;
      case 3:
        Navigator.pushNamed(context, '/create-request_BN');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sunrise,
        statusBarIconBrightness: Brightness.dark,
      ),
        child: Scaffold(
          backgroundColor: AppColors.softBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite, size: 36),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false),
            ),
            title: Text("profile_title".tr(),
              style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
            ),),
            backgroundColor: AppColors.sunrise,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.pureWhite, size: 36),
                onPressed: () => showSettingsMenu_BN(context),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderBusiness(
                    user: FirebaseAuth.instance.currentUser,
                    userData: userData ?? {},
                  ),
                  const SizedBox(height: 10),
                  const CampaignCountCard(),
                  CampaignBarChart(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      initiallyExpanded: _showStats,
                      onExpansionChanged: (val) => setState(() => _showStats = val),
                      title: Text( "statistical".tr(),
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      children: _showStats
                          ? [
                        StatisticsOverviewContainer(),
                        VolunteerStatisticsSection(),
                        QualityStatisticsSection(),
                      ]
                          : [],
                    ),
                  ),


                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavBarTap,
          ),
        ),

    );
  }
}

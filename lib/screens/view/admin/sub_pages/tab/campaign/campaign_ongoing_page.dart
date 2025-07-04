// file: my_campaigns_screen.dart
import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../components/app_colors.dart';
import '../../../../../../../components/search_bar.dart';
import '../../../../../../../service/activity_service.dart';
import '../../../../business/view/sub/my_campaigns_body.dart';
import '../../../../business/view/widgets/campaign_filter_bar.dart';
class CampaignOngoingPage extends StatefulWidget {
  const CampaignOngoingPage({super.key});

  @override
  State<CampaignOngoingPage> createState() => _CampaignOngoingPageState();
}

class _CampaignOngoingPageState extends State<CampaignOngoingPage> {
  String _selectedFilter = '';
  String _searchQuery = '';
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  void _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data() as Map<String, dynamic>?;
      setState(() {
        _isAdmin = data?['role'] == 'admin';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }


  Future<List<FeaturedActivity>> getActivities() {
    return ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<FeaturedActivity>>(
              future: getActivities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.sunrise),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${"generalError".tr()} ${snapshot.error}',
                      style: TextStyle(color: AppColors.deepOcean, fontSize: 14),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: AppColors.slateGrey),
                        const SizedBox(height: 10),
                        Text(
                          "no_campaigns".tr(),
                          style: TextStyle(color: AppColors.slateGrey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return MyCampaignsBody(
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


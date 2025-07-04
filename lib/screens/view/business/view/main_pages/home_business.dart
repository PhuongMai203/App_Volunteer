import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';
import '../../../../../components/search_bar.dart';
import '../../../../../service/activity_service.dart';

import '../../components/partner_components.dart';
import '../sub/campaign_list_from.dart';
import '../sub/feature_banner.dart';
import '../widgets/nav_bar.dart';

class PartnerHomePage extends StatefulWidget {
  const PartnerHomePage({Key? key}) : super(key: key);

  @override
  State<PartnerHomePage> createState() => _PartnerHomePageState();
}

class _PartnerHomePageState extends State<PartnerHomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedFilter = '';

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
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
  Future<List<FeaturedActivity>> getActivities() {
    return ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PartnerHeader(),
              const SizedBox(height: 24),
              SearchBarWidget(
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const FeatureBanner(),
              const SizedBox(height: 32),
              SizedBox(
                height: 400, // hoặc MediaQuery.of(context).size.height * 0.5
                child: CampaignListFromFirebase(
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
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
    );
  }

}

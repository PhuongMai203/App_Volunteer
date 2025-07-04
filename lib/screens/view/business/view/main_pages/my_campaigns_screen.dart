// file: my_campaigns_screen.dart
import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../components/app_colors.dart';
import '../../../../../components/search_bar.dart';
import '../../../../../service/activity_service.dart';
import '../sub/my_campaigns_body.dart';
import '../widgets/campaign_filter_bar.dart';
import '../widgets/nav_bar.dart';

class MyCampaignsScreen extends StatefulWidget {
  const MyCampaignsScreen({super.key});

  @override
  State<MyCampaignsScreen> createState() => _MyCampaignsScreenState();
}

class _MyCampaignsScreenState extends State<MyCampaignsScreen> {
  int _selectedIndex = 1;
  String _selectedFilter = '';
  String _searchQuery = '';

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
    });
  }

  void _onSearchChanged(String newSearch) {
    setState(() {
      _searchQuery = newSearch;
    });
  }

  Future<List<FeaturedActivity>> getActivities() {
    return ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }
  void _onNavBarTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/partner-home', (route) => false);
        break;
      case 1:
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
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30.0,
        ),
        title: Text(
          "upcoming_campaign".tr(),
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),
        actions: [
          CampaignFilterBar(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SearchBarWidget(
            onSearchChanged: _onSearchChanged,
          ),
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
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}

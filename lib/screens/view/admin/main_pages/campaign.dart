import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../components/app_colors.dart';
import '../sub_pages/tab/campaign/campaign_completed_page.dart';
import '../sub_pages/tab/campaign/campaign_ongoing_page.dart';

class Campaign extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final List<String> registeredEvents;

  const Campaign({
    Key? key,
    this.searchQuery = '',
    this.selectedFilter = '',
    this.registeredEvents = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cotton,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Color(0xFFE65100),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFFE65100),
                tabs: [
                  Tab(icon: Icon(Icons.schedule), text: "upcoming_campaign".tr()),
                  Tab(icon: Icon(Icons.done_all), text: "campaign_completed".tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CampaignOngoingPage(),
                  CampaignCompletedPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:activity_repository/src/models/models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/service/activity_service.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/app_gradients.dart';
import '../../../../components/search_bar.dart';
import '../campaign/upcoming_campaigns.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late PageController _pageController;
  String _searchQuery = '';
  String _selectedFilter = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserRole();
  }

  Future<List<FeaturedActivity>> getActivities() {
    return ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userRole = doc.data()?['role'] ?? 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width > 600;
    final double titleFontSize = isTablet ? 40 : 35;
    final double iconSize = isTablet ? 32 : 28;
    final double searchBarPadding = isTablet ? 16 : 10;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        automaticallyImplyLeading: false,
        title: Text(
          "news_feed".tr(),
          style: GoogleFonts.agbalumo(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list_alt, color: Colors.white, size: iconSize),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              _buildFilterOption('', Icons.clear_all, 'filter_default'.tr()),
              _buildFilterOption('A-Z', Icons.sort_by_alpha, 'A-Z'),
              _buildFilterOption('expiring', Icons.hourglass_bottom, 'filter_expiring'.tr()),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.peachPinkToOrange,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: searchBarPadding),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                child: SearchBarWidget(
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(height: searchBarPadding),
              Expanded(
                child: FutureBuilder<List<FeaturedActivity>>(
                  future: getActivities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: AppColors.sunrise));
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
                            Icon(Icons.inbox, size: isTablet ? 80 : 60, color: AppColors.slateGrey),
                            SizedBox(height: 10),
                            Text(
                              "no_campaigns".tr(),
                              style: TextStyle(color: AppColors.slateGrey, fontSize: isTablet ? 18 : 16),
                            ),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: UpcomingCampaigns(activities: snapshot.data!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildFilterOption(String value, IconData icon, String text) {
    final bool isSelected = _selectedFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.sunrise : Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.sunrise : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

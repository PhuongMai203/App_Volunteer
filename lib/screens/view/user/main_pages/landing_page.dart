import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:help_connect/screens/view/user/main_pages/profile_screen.dart';
import 'package:provider/provider.dart';

import 'package:activity_repository/activity_repository.dart';
import '../../../../chat/chatweb_socker/chat_list_screen.dart';
import '../../../../components/app_gradients.dart';
import '../../../../components/my_floating_action_button.dart';
import '../../../../service/activity_service.dart';
import '../../../../service/dynamic_link_service.dart';
import '../campaign/featured_campaigns.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../campaign/upcoming_campaigns.dart';
import '../widgets/bookmarked.dart';
import '../widgets/landing/SupportRequestForm.dart';
import '../widgets/landing/home_widgets.dart' hide NewsFeedPage, SupportPage;
import '../widgets/landing/landing_page_widgets.dart';
import '../widgets/landing/statistics_widget.dart';
import '../widgets/landing/top_contributors.dart';

import 'SupportPage.dart';
import 'NewsFeedPage.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseActivityRepo _repo = FirebaseActivityRepo();
  final PageController _categoryPageController = PageController(); // Đổi tên để tránh nhầm lẫn
  final PageController _featuredController = PageController();
  final PageController _upcomingController = PageController();
  final PageController _mainPageController = PageController(); // Controller mới cho PageView chính

  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final int _autoScrollDuration = 3;

  List<FeaturedActivity> _featuredList = [];
  List<FeaturedActivity> _upcomingList = [];
  String _searchQuery = "";
  String _selectedFilter = "";

  int _currentIndex = 0;
  int _currentFeaturedPage = 0;
  int _currentUpcomingPage = 0;
  int _volunteerCount = 0;
  int _businessCount = 0;
  int _campaignCount = 0;
  int _cityCount = 0;

  bool _hasShownSnackbar = false;
  Timer? _timer;

  late Future<List<FeaturedActivity>> _featuredActivities;

  final HomeWidgets homeWidgets = HomeWidgets();

  List<Widget> get _pages => [
    _buildHomePage(),
    SupportPage(),
    NewsFeedPage(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _featuredActivities = _repo.fetchFeaturedActivities();
    _startAutoScroll();
    Provider.of<BookmarkProvider>(context, listen: false).loadBookmarkedEvents();
    fetchStats();
  }
  bool _isMounted = false;
  @override
  void dispose() {
    _timer?.cancel();
    _isMounted = false;
    _categoryPageController.dispose();
    _featuredController.dispose();
    _upcomingController.dispose();
    _mainPageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: _autoScrollDuration), (_) {
      if (!mounted) return;

      if (_featuredController.hasClients && _featuredList.isNotEmpty) {
        final nextPage = (_currentFeaturedPage + 1) % _featuredList.length;
        _featuredController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }

      if (_upcomingController.hasClients && _upcomingList.isNotEmpty) {
        final nextPage = (_currentUpcomingPage + 1) % _upcomingList.length;
        _upcomingController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    _mainPageController.jumpToPage(index);
  }

  Future<List<FeaturedActivity>> getActivities() {
    return ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }
  void onCategorySelected(String categoryName) async {
    try {
      List<FeaturedActivity> allActivities = await _repo.fetchAllUpcomingActivities();
      setState(() {
        _upcomingList = allActivities.where((a) => a.category == categoryName).toList();
      });
    } catch (e) {
      print("error_filtering_activities".tr() + ": $e");
    }
  }

  Future<void> fetchStats() async {
    final firestore = FirebaseFirestore.instance;
    final usersSnapshot = await firestore.collection('users').get();
    final featuredSnapshot = await firestore.collection('featured_activities').get();

    final users = usersSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    final volunteers = users.where((u) => u['role'] != 'admin' && u['role'] != 'organization').length;
    final businesses = users.where((u) => u['role'] == 'organization').length;
    final campaigns = featuredSnapshot.size;
    final cities = featuredSnapshot.docs.map((d) => d.get('address')).toSet().length;

    if (mounted) {
      setState(() {
        _volunteerCount = volunteers;
        _businessCount = businesses;
        _campaignCount = campaigns;
        _cityCount = cities;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasShownSnackbar) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final successMessage = args?['successMessage'];
      if (successMessage != null && successMessage.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        });
        _hasShownSnackbar = true;
      }
    }
  }
  // Hàm build trang chủ hiện tại của LandingPage
  Widget _buildHomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth; // Use constraints.maxWidth
        final crossAxisCount = screenWidth > 900 ? 8 : (screenWidth > 600 ? 6 : 3);
        final itemsPerPage = crossAxisCount * 2;
        final totalPages = (categories.length / itemsPerPage).ceil();

        return Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.peachPinkToOrange,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                const SizedBox(height: 15),
                buildHeader(
                  context,
                  onSearchChanged: (value) => setState(() => _searchQuery = value),
                ),
                buildCategorySection(
                  crossAxisCount,
                  itemsPerPage,
                  totalPages,
                  _categoryPageController,
                  onCategorySelected,
                  showBackgroundImage: true,
                ),
                const SizedBox(height: 15),
                TopContributorsWidget(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _searchQuery.isNotEmpty
                      ? FutureBuilder<List<FeaturedActivity>>(
                    future: getActivities(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("error_loading_search_results".tr(namedArgs: {'error': snapshot.error.toString()})));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("no_search_results".tr()));
                      }
                      return UpcomingCampaigns(activities: snapshot.data!);
                    },
                  )
                      : FutureBuilder<List<FeaturedActivity>>(
                    future: _featuredActivities,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("error_loading_featured_campaigns".tr(namedArgs: {'error': snapshot.error.toString()})));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("no_featured_campaigns".tr()));
                      }
                      return FeaturedCampaigns(
                        title: "featured_campaigns".tr(),
                        pageController: _featuredController,
                        currentPage: _currentFeaturedPage,
                        onPageChanged: (index) => setState(() => _currentFeaturedPage = index),
                        userId: currentUserId,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                StatisticsWidget(
                  volunteerCount: _volunteerCount,
                  businessCount: _businessCount,
                  campaignCount: _campaignCount,
                  cityCount: _cityCount,
                ),
                const SizedBox(height: 24),
                SupportRequestForm(),
                const SizedBox(height: 24),
                _buildImpactReportSection(),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView( // Sử dụng PageView làm body chính
        controller: _mainPageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Ngăn cuộn ngang bằng tay nếu muốn
        children: _pages, // Hiển thị các trang đã định nghĩa
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
      ),
    );
  }

  Widget _buildImpactReportSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Text(
            "impact_message".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 22 : 18, // Adjust based on screen width
              fontWeight: FontWeight.bold,
              color: Colors.green,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/pt4.png',
              width: MediaQuery.of(context).size.width * 0.9, // Occupy 90% of screen width
              height: MediaQuery.of(context).size.height * 0.4, // Occupy 40% of screen height (adjust as needed)
              fit: BoxFit.cover, // Or BoxFit.contain, depending on desired behavior
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 30),
                color: Colors.green,
                onPressed: DynamicLinkService.shareApp,
              ),
              Text(
                "share".tr(),
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

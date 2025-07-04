import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../admin/sub_pages/upcoming_sub/campaign_card.dart';
import 'recommendation/recommendation_engine.dart';

class FeaturedCampaigns extends StatefulWidget {
  final String title;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String userId;

  const FeaturedCampaigns({
    super.key,
    required this.title,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.userId,
  });

  @override
  _FeaturedCampaignsState createState() => _FeaturedCampaignsState();
}

class _FeaturedCampaignsState extends State<FeaturedCampaigns> {
  List<FeaturedActivity> featuredActivities = [];
  Timer? autoScrollTimer;
  bool isForward = true;

  final engine = RecommendationEngine(firestore: FirebaseFirestore.instance);

  @override
  void initState() {
    super.initState();
    _fetchRecommendedActivities();
  }

  @override
  void dispose() {
    autoScrollTimer?.cancel();
    super.dispose();
  }

  void _fetchRecommendedActivities() async {
    try {
      final activities = await engine.fetchRecommendedCampaigns(widget.userId);
      if (mounted) {
        setState(() {
          featuredActivities = activities;
        });
        if (featuredActivities.isNotEmpty) _startAutoScroll();
      }
    } catch (e) {

    }
  }

  void _startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!widget.pageController.hasClients || featuredActivities.isEmpty)
        return;

      int nextPage;
      if (isForward) {
        nextPage = (widget.currentPage < featuredActivities.length - 1)
            ? widget.currentPage + 1
            : (isForward = false, widget.currentPage - 1).$2;
      } else {
        nextPage = (widget.currentPage > 0)
            ? widget.currentPage - 1
            : (isForward = true, widget.currentPage + 1).$2;
      }

      widget.pageController.animateToPage(
        nextPage,
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOut,
      );

      widget.onPageChanged(nextPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final isTablet = screenWidth > 600;
    final double sliderHeight = isTablet ? screenHeight * 0.75 : screenHeight * 0.65;


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.roboto(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: sliderHeight,
            child: featuredActivities.isEmpty
                ? _buildEmptyState(isTablet)
                : PageView.builder(
              controller: widget.pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: widget.onPageChanged,
              itemCount: featuredActivities.length,
              itemBuilder: (context, index) =>
                  _buildAnimatedCard(index, screenWidth),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAnimatedCard(int index, double screenWidth) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;
    final double sliderHeight = isTablet ? screenHeight * 0.8 : screenHeight * 0.7;

    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double parallaxOffset = 0;

        if (widget.pageController.position.haveDimensions) {
          final page = widget.pageController.page ?? widget.pageController.initialPage.toDouble();
          final diff = index - page;
          parallaxOffset = diff * (screenWidth * 0.1);
        }

        return Transform.translate(
          offset: Offset(parallaxOffset, 0),
          child: SizedBox(
            height: sliderHeight,
            child: CampaignCard(
              activity: featuredActivities[index],
              onDeleted: () => _handleCampaignDeleted(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Text(
        "no_featured_campaigns".tr(),
        style: TextStyle(
          fontSize: isTablet ? 18 : 15,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }
  void _handleCampaignDeleted(int index) {
    setState(() => featuredActivities.removeAt(index));
    if (featuredActivities.isEmpty) autoScrollTimer?.cancel();
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../components/app_colors.dart';
import '../../../../admin/sub_pages/upcoming_sub/campaign_utils.dart';
import '../../../../admin/sub_pages/upcoming_sub/widgets/volunteer_count_widget.dart';
import '../../../../user/campaign/sub/campaign_feedback/sub/campaign_average_rating.dart';
import '../../../../user/campaign/sub/campaign_feedback/sub/feedback_section.dart';
import '../../../../user/widgets/campaign/campaign_description_field.dart';
import '../volunteer_list.dart';
import 'donation_list_widget.dart';

class ActivityInfo extends StatefulWidget {
  final dynamic activity;
  final Widget Function() detailBuilder;
  final bool isEditing;
  final TextEditingController descriptionController;
  final TextEditingController maxVolunteerCountController;
  final DateTime? endDate;
  final String currentUserId;

  const ActivityInfo({
    super.key,
    required this.activity,
    required this.detailBuilder,
    required this.isEditing,
    required this.descriptionController,
    required this.maxVolunteerCountController,
    this.endDate,
    required this.currentUserId,
  });

  @override
  State<ActivityInfo> createState() => _ActivityInfoState();
}

class _ActivityInfoState extends State<ActivityInfo> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Tab> _tabs = [];
  List<Widget> _tabViews = [];

  // Sử dụng DateTime.now() theo múi giờ Việt Nam
  bool get _isEnded {
    if (widget.endDate == null) return false;
    final now = DateTime.now();
    return widget.endDate!.isBefore(now);
  }

  @override
  void initState() {
    super.initState();
    _initTabsAndController();
  }

  @override
  void didUpdateWidget(covariant ActivityInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool oldIsEnded = oldWidget.endDate != null && oldWidget.endDate!.isBefore(DateTime.now());
    final bool newIsEnded = widget.endDate != null && widget.endDate!.isBefore(DateTime.now());

    bool shouldRecreateController = _generateTabs().length != _tabs.length || oldIsEnded != newIsEnded;

    if (shouldRecreateController) {
      _tabController?.dispose();
      _initTabsAndController();
    } else {

      if (widget.isEditing != oldWidget.isEditing || widget.activity != oldWidget.activity) {
        _tabViews = _generateTabViews();
        setState(() {});
      }
    }
  }

  void _initTabsAndController() {
    _tabs = _generateTabs();
    _tabViews = _generateTabViews();
    final int initialIndex = _tabController?.index ?? 0;
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _tabs.isNotEmpty ? _tabs.length - 1 : 0),
    );
  }

  List<Tab> _generateTabs() {
    return [
      Tab(text: "detail".tr()),
      Tab(text: "join".tr()),
      Tab(text: "Contribute".tr()),
      if (_isEnded) Tab(text: "evaluate".tr()),
    ];
  }

  List<Widget> _generateTabViews() {
    return [
      widget.detailBuilder(),
      VolunteerParticipantsList(
        campaignId: widget.activity.id,
        currentUserId: widget.currentUserId,
      ),
      DonationListWidget(campaignId: widget.activity.id),
      if (_isEnded)
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "evaluate".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepOcean,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CampaignAverageRating(campaignId: widget.activity.id),
                  ],
                ),
                const SizedBox(height: 8),
                FeedbackSection(campaignId: widget.activity.id),
              ],
            ),
          ),
        ),
    ];
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    final double screenHeight = MediaQuery.of(context).size.height;

    double estimatedHeaderHeight = 22 + 10;
    double estimatedDescriptionHeight = widget.isEditing ? 150 : 80;
    double estimatedCountWidgetHeight = 40;
    double estimatedTabBarHeight = 50;
    double paddingAndMargins = 10 * 3 + 12;

    final double tabViewHeight = screenHeight -
        (AppBar().preferredSize.height) -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom - 20 -
        estimatedHeaderHeight -
        estimatedDescriptionHeight -
        estimatedCountWidgetHeight -
        estimatedTabBarHeight -
        paddingAndMargins;


    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Tiêu đề
          Text(
            widget.activity.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          CampaignDescriptionField(
            campaignId: widget.activity.id,
            controller: widget.descriptionController,
            isEditing: widget.isEditing,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VolunteerCountWidget(
                campaignId: widget.activity.id,
                isEditing: widget.isEditing,
                maxVolunteerCountController: widget.maxVolunteerCountController,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CampaignUtils.formatDonation(activity.totalDonationAmount.toDouble() ?? 0.0),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_tabController != null)
            TabBar(
              controller: _tabController!,
              labelColor: AppColors.sunrise,
              unselectedLabelColor: AppColors.textPrimary,
              indicatorColor: AppColors.sunrise,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: _tabs,
            ),
          const SizedBox(height: 12),

          if (_tabController != null)
            SizedBox(
              height: tabViewHeight > 0 ? tabViewHeight : 0,
              child: TabBarView(
                controller: _tabController!,

                children: _tabViews,
              ),
            ),
        ],
      ),
    );
  }
}
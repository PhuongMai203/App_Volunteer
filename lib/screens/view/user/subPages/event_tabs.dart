import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../components/app_colors.dart';
import '../campaign/sub/campaign_feedback/widgets/campaign_feedback_service.dart';
import '../campaign/sub/campaign_feedback/widgets/feedback_prompt.dart';
import '../widgets/event_list.dart';

class EventTabs extends StatefulWidget {
  final List<FeaturedActivity> joinedEvents;
  final List<FeaturedActivity> registeredEvents;
  final List<FeaturedActivity> bookmarkedEvents;
  final String userRole;
  final ValueChanged<int>? onUpdateDonationCount;
  final ValueChanged<FeaturedActivity>? onJoinedTap;
  final ValueChanged<FeaturedActivity>? onRegisteredTap;
  final ValueChanged<FeaturedActivity>? onBookmarkedTap;

  const EventTabs({
    Key? key,
    required this.joinedEvents,
    required this.registeredEvents,
    required this.bookmarkedEvents,
    required this.userRole,
    this.onJoinedTap,
    this.onRegisteredTap,
    this.onBookmarkedTap,
    this.onUpdateDonationCount,
  }) : super(key: key);

  @override
  State<EventTabs> createState() => _EventTabsState();
}

class _EventTabsState extends State<EventTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFeedbackPrompt = true;
  final _feedbackService = CampaignFeedbackService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 0 &&
          _showFeedbackPrompt &&
          widget.joinedEvents.isNotEmpty &&
          widget.userRole != 'admin')
          {
        Future.microtask(() async {
          final activity = widget.joinedEvents.first;
          final campaignId = activity.id;

          final already = await _feedbackService.isAlreadyFeedback(
            userId: _feedbackService.currentUserId,
            campaignId: campaignId,
          );

          if (!already) {
            _showFeedbackDialog(campaignId);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFeedbackDialog(String campaignId) {
    showDialog(
      context: context,
      builder: (_) => FeedbackPrompt(
        onCancel: () => Navigator.of(context).pop(),
        onSubmit: (rating, comment) async {
          Navigator.of(context).pop();

          final already = await _feedbackService.isAlreadyFeedback(
            userId: _feedbackService.currentUserId,
            campaignId: campaignId,
          );
          if (already) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("already_rated".tr()),
                backgroundColor: AppColors.lightPinkRed,
              ),
            );
            return;
          }

          await _feedbackService.submitFeedback(
            campaignId: campaignId,
            rating: rating,
            comment: comment,
          );

          setState(() => _showFeedbackPrompt = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("thanks_feedback".tr()),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.event_available)),
                Tab(icon: Icon(Icons.event_note)),
                Tab(icon: Icon(Icons.bookmark)),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                EventList(
                  events: widget.joinedEvents,
                  emptyMessage: "no_joined".tr(),
                  userRole: widget.userRole,
                  onEventTap: widget.onJoinedTap,
                  onUpdateDonationCount: widget.onUpdateDonationCount,
                ),
                EventList(
                  events: widget.registeredEvents,
                  emptyMessage: "no_registered".tr(),
                  userRole: widget.userRole,
                  onEventTap: widget.onRegisteredTap,
                  onUpdateDonationCount: widget.onUpdateDonationCount,
                ),
                EventList(
                  events: widget.bookmarkedEvents,
                  emptyMessage: "no_bookmarked".tr(),
                  userRole: widget.userRole,
                  onEventTap: widget.onBookmarkedTap,
                  onUpdateDonationCount: widget.onUpdateDonationCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../business/view/sub/campaign_detail.dart';
import '../../user/campaign/campaign_registration_screen.dart';
import '../../user/subPages/event_tabs.dart';

class UserEventTabAdmin extends StatefulWidget {
  final String userId;

  const UserEventTabAdmin({super.key, required this.userId});

  @override
  State<UserEventTabAdmin> createState() => _UserEventTabAdminState();
}

class _UserEventTabAdminState extends State<UserEventTabAdmin> {
  List<FeaturedActivity> joinedEvents = [];
  List<FeaturedActivity> registeredEvents = [];
  List<FeaturedActivity> bookmarkedEvents = []; // Không cần thiết với Admin

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final userId = widget.userId;

    try {
      final regSnap = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('userId', isEqualTo: userId)
          .get();

      final campaignIds = regSnap.docs
          .map((doc) => doc.get('campaignId') as String?)
          .whereType<String>()
          .toList();

      final List<FeaturedActivity> allRegistered = [];

      for (var i = 0; i < campaignIds.length; i += 10) {
        final chunk = campaignIds.sublist(i, i + 10 > campaignIds.length ? campaignIds.length : i + 10);
        final snap = await FirebaseFirestore.instance
            .collection('featured_activities')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        allRegistered.addAll(
          snap.docs.map((doc) => FeaturedActivity.fromDocument(doc)).toList(),
        );
      }

      final now = DateTime.now();
      final ongoing = <FeaturedActivity>[];
      final ended = <FeaturedActivity>[];

      for (var a in allRegistered) {
        if (a.endDate.isBefore(now)) {
          ended.add(a);
        } else {
          ongoing.add(a);
        }
      }

      setState(() {
        joinedEvents = ended;
        registeredEvents = ongoing;
        bookmarkedEvents = []; // Không cần với admin
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("${"statistics_error".tr()} $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openRegistration(FeaturedActivity activity) async {
    await Navigator.push<FeaturedActivity>(
      context,
      MaterialPageRoute(
        builder: (_) => CampaignDetailBN(activity: activity),
      ),
    );
    if (!mounted) return;
    await _fetchUserStats();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return EventTabs(
      joinedEvents: joinedEvents,
      registeredEvents: registeredEvents,
      bookmarkedEvents: bookmarkedEvents,
      userRole: 'admin', // 👈 THÊM DÒNG NÀY
      onJoinedTap: (eventData) {
        if (eventData is FeaturedActivity) {
          _openRegistration(eventData);
        }
      },
    );

  }
}

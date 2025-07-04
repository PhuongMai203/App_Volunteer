import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../campaign/campaign_registration_screen.dart';
import '../../widgets/bookmarked.dart';
import '../../subPages/event_tabs.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class UserEventTabSection extends StatefulWidget {
  final User? user;

  const UserEventTabSection({super.key, required this.user});

  @override
  State<UserEventTabSection> createState() => _UserEventTabSectionState();
}

class _UserEventTabSectionState extends State<UserEventTabSection> {
  List<FeaturedActivity> joinedEvents = [];
  List<FeaturedActivity> registeredEvents = [];
  List<FeaturedActivity> bookmarkedEvents = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final user = widget.user;
    if (user == null) return;

    try {
      final regSnap = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('userId', isEqualTo: user.uid)
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
        bookmarkedEvents = context.read<BookmarkProvider>().bookmarkedEvents;
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
        builder: (_) => CampaignRegistrationScreen(activity: activity),
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
      userRole: 'user',
      onJoinedTap: (eventData) {
        if (eventData is FeaturedActivity) {
          _openRegistration(eventData);
        }
      },
    );

  }
}

import 'dart:async';
import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../../components/app_colors.dart';
import 'notification_item_rank.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final Set<String> _seenNotificationIds = {};
  List<Map<String, dynamic>> _rankNotifications = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadSeenNotifications();
    _listenToRankChanges();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToRankChanges() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subscription = FirebaseFirestore.instance
        .collection('user_rank_history')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _rankNotifications = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'type': 'rank',
            'newRank': doc['newRank'],
            'timestamp': doc['timestamp'],
          };
        }).toList();
      });
    }, onError: (e) {
      print('❌ Error listening ranks: $e');
    });
  }

  Future<void> _loadSeenNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final seenIds = List<String>.from(userDoc.data()?['seen_notifications'] ?? []);

    setState(() {
      _seenNotificationIds.addAll(seenIds);
    });
  }

  Future<void> _saveSeenNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'seen_notifications': _seenNotificationIds.toList(),
    }, SetOptions(merge: true));
  }

  void _markAllAsSeen() {
    setState(() {
      _seenNotificationIds.addAll(_rankNotifications.map((e) => e['id'] as String));
    });
    _saveSeenNotifications();
  }

  Future<void> _showNotificationList(BuildContext context, double screenWidth) async {
    final rankNotifications = _rankNotifications;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "notifications".tr(),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        final dialogWidth = screenWidth < 500 ? screenWidth * 0.7 : 350.0;
        const itemHeight = 90.0;
        const separator = 12.0;

        final contentHeight = rankNotifications.isEmpty
            ? 100.0
            : rankNotifications.length * itemHeight + (rankNotifications.length - 1) * separator;
        final actualHeight = contentHeight > screenHeight * 0.6 ? screenHeight * 0.6 : contentHeight;

        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.08, right: screenWidth * 0.04),
                width: dialogWidth,
                constraints: BoxConstraints(maxHeight: actualHeight, minHeight: 80),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAEE),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '${"notifications".tr()} (${rankNotifications.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: AppColors.deepOcean,
                        ),
                      ),
                    ),
                    Expanded(
                      child: rankNotifications.isEmpty
                          ? Center(
                        child: Text(
                          "no_notification".tr(),
                          style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: rankNotifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: separator),
                        itemBuilder: (_, index) {
                          final item = rankNotifications[index];
                          return RankNotificationItem(
                            id: item['id'],
                            newRank: item['newRank'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.07;
    final badgeSize = iconSize * 0.4;

    final newCount = _rankNotifications
        .where((e) => !_seenNotificationIds.contains(e['id']))
        .length;

    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -4, end: -4),
      showBadge: newCount > 0,
      badgeStyle: badges.BadgeStyle(
        padding: EdgeInsets.all(badgeSize * 0.3),
        elevation: 0,
      ),
      badgeContent: Text(
        newCount.toString(),
        style: TextStyle(color: Colors.white, fontSize: badgeSize * 0.5),
      ),
      child: IconButton(
        icon: Icon(
          Icons.notifications,
          color: newCount > 0 ? Colors.orangeAccent : Colors.grey[600],
          size: iconSize,
        ),
        onPressed: () async {
          await _showNotificationList(context, screenWidth);
          _markAllAsSeen();
        },
      ),
    );
  }
}

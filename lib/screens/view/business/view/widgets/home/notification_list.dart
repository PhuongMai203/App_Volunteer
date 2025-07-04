///THÔNG BÁO CỦA DOANNH NGHIỆP
import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../../components/app_colors.dart';
import '../../sub/campaign_detail.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('campaign_feedback')
        .where('campaignCreatorId', isEqualTo: userId)
        .get();

    final paymentSnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('campaignCreatorId', isEqualTo: userId)
        .get();

    final feedbacks = feedbackSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'feedback',
        'title': data['title'] ?? '',
        'userName': data['userName'] ?? '',
        'comment': data['comment'] ?? '',
        'rating': data['rating'] ?? 0,
        'campaignId': data['campaignId'] ?? '',
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'read': data['read'] ?? false,
        'docId': doc.id,
      };
    });

    final payments = paymentSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'payment',
        'userName': data['userName'] ?? '',
        'amount': data['amount'] ?? 0,
        'campaignId': data['campaignId'] ?? '',
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'read': data['read'] ?? false,
        'campaignTitle': data['campaignTitle'] ?? '',
        'docId': doc.id,
      };
    });

    final all = [...feedbacks, ...payments];
    all.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    return all;
  }

  static Future<int> fetchUnreadCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;

    final feedback = await FirebaseFirestore.instance
        .collection('campaign_feedback')
        .where('campaignCreatorId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final payment = await FirebaseFirestore.instance
        .collection('payments')
        .where('campaignCreatorId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    return feedback.docs.length + payment.docs.length;
  }

  static Future<void> markAllAsRead(List<Map<String, dynamic>> notifications) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var n in notifications) {
      final collection = n['type'] == 'feedback' ? 'campaign_feedback' : 'payments';
      final ref = FirebaseFirestore.instance.collection(collection).doc(n['docId']);
      batch.update(ref, {'read': true});
    }

    await batch.commit();
  }

  static void showNotificationPopup(BuildContext context, List<Map<String, dynamic>> notifications) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.6;
    const minHeight = 350.0;
    const itemHeight = 90.0;
    const separator = 12.0;

    final contentHeight = notifications.isEmpty
        ? minHeight
        : notifications.length * itemHeight + (notifications.length - 1) * separator;

    final actualHeight = contentHeight.clamp(minHeight, maxHeight);

    final tiles = notifications.map((data) {
      final isUnread = data['read'] == false;
      return InkWell(
        onTap: () async {
          Navigator.of(context).pop();
          final campaignId = data['campaignId'];
          if (campaignId.isEmpty) return;

          final doc = await FirebaseFirestore.instance
              .collection('featured_activities')
              .doc(campaignId)
              .get();

          if (doc.exists) {
            final activity = FeaturedActivity.fromMap(doc.data()!, doc.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CampaignDetailBN(activity: activity),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFFFF3CD) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['type'] == 'feedback'
                    ? '${"newRatingOf".tr()} "${data['title']}" ${"from".tr()} ${data['userName']}'
                    : '${"received".tr()} ${data['amount']}₫ ${"from".tr()} ${data['userName']} ${"forCampaign".tr()} "${data['campaignTitle']}"',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                data['type'] == 'feedback'
                    ? data['comment']
                    : '${"amount".tr()} ${data['amount']} VNĐ',
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (data['type'] == 'feedback') ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${data['rating']}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "notifications".tr(),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.topRight,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 60, right: 16),
                  height: actualHeight,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                    children: [
                      Text(
                        '${"notifications".tr()} (${notifications.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: notifications.isEmpty
                            ? Center(
                          child: Text("no_notification".tr(),
                              style: TextStyle(color: Colors.grey)),
                        )
                            : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: tiles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: separator),
                          itemBuilder: (_, index) => tiles[index],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail.dart';

class CampaignListFromFirebase extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const CampaignListFromFirebase({
    super.key,
    this.searchQuery = '',
    this.selectedFilter = '',
  });

  int _calculateDaysLeft(Timestamp endDate) {
    final now = DateTime.now();
    final end = endDate.toDate();
    return end.difference(now).inDays;
  }

  Future<int> _calculateTotalAmount(String campaignId) async {
    final query = await FirebaseFirestore.instance
        .collection('payments')
        .where('campaignId', isEqualTo: campaignId)
        .get();

    int totalAmount = 0;
    for (var doc in query.docs) {
      final data = doc.data();
      final amount = data['amount'];
      if (amount is int) {
        totalAmount += amount;
      } else if (amount is String) {
        totalAmount += int.tryParse(amount) ?? 0;
      }
    }

    return totalAmount;
  }

  Future<int> _calculateVolunteerCount(String campaignId) async {
    try {
      final countSnap = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: campaignId)
          .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
          .count()
          .get();

      int count = countSnap.count ?? -1;

      if (count < 0) {
        final fallbackSnap = await FirebaseFirestore.instance
            .collection('campaign_registrations')
            .where('campaignId', isEqualTo: campaignId)
            .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
            .get();
        count = fallbackSnap.docs.length;
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text("userNotLoggedIn".tr()));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('featured_activities')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              '${"no_campaigns".tr()}\nUID: ${currentUser.uid}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();

          final matchesSearch = searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());
          final matchesFilter = selectedFilter.isEmpty || category == selectedFilter.toLowerCase();

          return matchesSearch && matchesFilter;
        }).toList();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(filteredDocs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            final campaignId = doc.id;

            final totalAmount = await _calculateTotalAmount(campaignId);
            final volunteerCount = await _calculateVolunteerCount(campaignId);
            final maxVolunteerCount =
            (data['maxVolunteerCount'] is int && data['maxVolunteerCount'] > 0)
                ? data['maxVolunteerCount']
                : 1;

            final progress = volunteerCount / maxVolunteerCount;
            final currencyFormatter = NumberFormat("#,##0", "vi_VN");

            return {
              'title': data['title'] ?? "untitledCampaign".tr(),
              'daysLeft': _calculateDaysLeft(data['endDate']),
              'campaignId': campaignId,
              'progress': progress.clamp(0.0, 1.0),
              'target': '${currencyFormatter.format(totalAmount)}₫',
              'volunteerCount': volunteerCount,
              'maxVolunteerCount': maxVolunteerCount,
              'progressPercent': (progress * 100).toStringAsFixed(0),
              'docData': data,
              'docRef': doc,
            };
          }).toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final campaigns = snapshot.data!
                .where((c) => c['daysLeft'] != null && c['daysLeft'] > 0)
                .toList();

            if (campaigns.isEmpty) {
              return Center(child: Text("no_matching_campaigns".tr()));
            }

            return ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                final data = campaign['docData'] as Map<String, dynamic>;

                return CampaignCard(
                  campaign: campaign,
                  onTap: () {
                    final activity = FeaturedActivity.fromMap(data, campaign['campaignId']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampaignDetailBN(activity: activity),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

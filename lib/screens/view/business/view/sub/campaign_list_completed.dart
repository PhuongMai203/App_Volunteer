import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../components/app_colors.dart';
import '../widgets/campaign_complete/campaign_completed.dart';
import '../widgets/campaign_complete/dismissible_campaign_item.dart';
import 'campaign_detail.dart';

class CampaignListCompleted extends StatelessWidget {
  final Future<void> Function(String campaignId)? onDelete;

  const CampaignListCompleted({super.key, this.onDelete});

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
        // fallback nếu count() chưa hỗ trợ
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
      return  Center(child: Text("userNotLoggedIn".tr()));
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

        final campaignDocs = snapshot.data!.docs;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(campaignDocs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            final campaignId = doc.id;

            final totalAmount = await _calculateTotalAmount(campaignId);

            final maxVolunteerCount = (data['maxVolunteerCount'] is int && data['maxVolunteerCount'] > 0)
                ? data['maxVolunteerCount']
                : 1;

            final volunteerCount = await _calculateVolunteerCount(campaignId);

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
            };
          }).toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final campaigns = snapshot.data!;
            final filteredCampaigns = campaigns
                .where((campaign) => campaign['daysLeft'] != null && campaign['daysLeft'] < 0)
                .toList();

            return ListView.separated(
              itemCount: filteredCampaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final campaign = filteredCampaigns[index];
                final doc = campaignDocs.firstWhere((d) => d.id == campaign['campaignId']);
                final data = doc.data() as Map<String, dynamic>;

                return DismissibleCampaignItem(
                  key: Key(campaign['campaignId']),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.coralOrange, width: 2),
                        ),
                        title: Text(
                          "confirm".tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        content: Text(
                          "delete_this_campaign".tr(),
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              "cancel".tr(),
                              style: GoogleFonts.poppins(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              "delete".tr(),
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && onDelete != null) {
                      await onDelete!(campaign['campaignId']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${"campaign_deleted_successfully".tr()} "${campaign['title']}"')),
                      );
                    }
                  },

                  child: CampaignCompleted(
                    campaign: campaign,
                    onTap: () {
                      final activity = FeaturedActivity.fromMap(data, doc.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignDetailBN(activity: activity),
                        ),
                      );
                    },
                  ),
                );

              },
            );
          },
        );
      },
    );
  }
}

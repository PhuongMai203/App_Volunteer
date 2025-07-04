import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../components/app_colors.dart';
import '../../../../service/donation_service.dart';

class UserStatsWidget extends StatefulWidget {
  final String? userUid;
  const UserStatsWidget({Key? key, this.userUid}) : super(key: key);

  @override
  _UserStatsWidgetState createState() => _UserStatsWidgetState();
}

class _UserStatsWidgetState extends State<UserStatsWidget> {
  final donationService = DonationService();

  Future<int> countDirectParticipations(String uid) async {
    final query = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: uid)
        .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
        .get();
    return query.docs.length;
  }

  Future<int> countUserFeedbacks(String uid) async {
    final query = await FirebaseFirestore.instance
        .collection('campaign_feedback')
        .where('userId', isEqualTo: uid)
        .get();
    return query.docs.length;
  }

  Future<Map<String, int>> loadUserStats(String uid) async {
    final results = await Future.wait([
      donationService.getTotalDonatedAmount(uid),
      countDirectParticipations(uid),
      countUserFeedbacks(uid),
    ]);

    return {
      'donatedAmount': results[0],
      'directCount': results[1],
      'feedbackCount': results[2],
    };
  }

  @override
  Widget build(BuildContext context) {
    final uidNullable = widget.userUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uidNullable == null) {
      return Center(child: Text("unknown_user".tr()));
    }
    final uid = uidNullable;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(child: Text("load_error".tr()));
          }

          final userData = userSnapshot.data?.data() ?? {};
          final serverCampaignCount = userData['campaignCount'] ?? 0;

          return FutureBuilder<Map<String, int>>(
            future: loadUserStats(uid),
            builder: (context, statsSnapshot) {
              final stats = statsSnapshot.data;

              final donatedAmount = stats != null ? '${stats['donatedAmount']}đ' : null;
              final directCount = stats != null ? stats['directCount']?.toString() : null;
              final feedbackCount = stats != null ? stats['feedbackCount']?.toString() : null;
              final campaignCount = serverCampaignCount.toString();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  int crossAxisCount = 2;
                  double childAspectRatio = 1;

                  if (width > 600) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.2;
                  } else if (width > 400) {
                    crossAxisCount = 3;
                    childAspectRatio = 1.1;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6, // Tăng tỉ lệ này để khung thấp hơn (thường giá trị 1.4 - 1.8 là phù hợp)
                    children: [
                      StatCard(
                        title: "donated_amount".tr(),
                        value: donatedAmount,
                        icon: Icons.monetization_on,
                      ),
                      StatCard(
                        title: "direct_participation".tr(),
                        value: directCount,
                        icon: Icons.event_available,
                      ),
                      StatCard(
                        title: "registered_campaigns".tr(),
                        value: campaignCount,
                        icon: Icons.event,
                      ),
                      StatCard(
                        title: "feedbacks".tr(),
                        value: feedbackCount,
                        icon: Icons.star,
                        iconColor: Colors.amber,
                      ),
                    ],
                  );

                },
              );
            },
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String? value;
  final IconData? icon;
  final Color? iconColor;

  const StatCard({
    Key? key,
    required this.title,
    this.value,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? '--';
    final displayColor = value == null ? Colors.grey : Colors.green;
    final screenWidth = MediaQuery.of(context).size.width;

    double iconSize = 28;
    double valueFontSize = 18;
    double titleFontSize = 13;
    double padding = 10;

    if (screenWidth > 600) {
      iconSize = 34;
      valueFontSize = 22;
      titleFontSize = 15;
      padding = 14;
    }

    return Card(
      color: const Color(0xFFFFFAF0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.mint,
              ),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

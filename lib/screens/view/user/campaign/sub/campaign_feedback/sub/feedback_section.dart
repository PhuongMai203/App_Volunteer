import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {
  final String campaignId;

  const FeedbackSection({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.1; // Avatar chiếm ~10% chiều rộng màn hình
    final starSize = screenWidth * 0.04;
    final nameTextSize = screenWidth * 0.045;
    final dateTextSize = screenWidth * 0.035;
    final commentTextSize = screenWidth * 0.04;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaign_feedback')
          .where('campaignId', isEqualTo: campaignId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            '${"load_feedback_error".tr()} ${snapshot.error}',
            style: TextStyle(fontSize: commentTextSize),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            "no_feedback_yet".tr(),
            style: TextStyle(fontSize: commentTextSize),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final avatarUrl = data['avatarUrl'] as String?;
            final username = data['userName'] as String? ?? "user".tr();
            final rating = data['rating'] as int? ?? 0;
            final comment = data['comment'] as String? ?? '';
            final createdAtRaw = data['createdAt'];
            final createdAt = createdAtRaw is Timestamp ? createdAtRaw.toDate() : null;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    radius: avatarSize / 2,
                    child: avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: nameTextSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              createdAt != null
                                  ? '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                                  : 'no_date'.tr(),
                              style: TextStyle(
                                fontSize: dateTextSize,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: starSize,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          comment,
                          style: TextStyle(fontSize: commentTextSize),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

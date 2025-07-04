import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CampaignAverageRating extends StatelessWidget {
  final String campaignId;

  const CampaignAverageRating({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.05; // Icon sao tỉ lệ theo màn hình
    final textSize = screenWidth * 0.04;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaign_feedback')
          .where('campaignId', isEqualTo: campaignId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "rating_cannot_be_calculated".tr(),
            style: TextStyle(fontSize: textSize),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Text(
            "there_are_no_reviews_to_rate".tr(),
            style: TextStyle(fontSize: textSize),
          );
        }

        // Tính trung bình sao
        final totalRating = docs.fold<int>(0, (sum, doc) {
          final rating = doc['rating'] as int? ?? 0;
          return sum + rating;
        });
        final average = totalRating / docs.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: iconSize),
            SizedBox(width: screenWidth * 0.015),
            Text(
              '${"average_rating".tr()} ${average.toStringAsFixed(1)} / 5',
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

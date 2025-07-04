import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CampaignAverageRating extends StatelessWidget {
  final String campaignId;

  const CampaignAverageRating({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.045; // Cỡ icon sao ~4.5% chiều rộng
    final ratingTextSize = screenWidth * 0.04;
    final participantTextSize = screenWidth * 0.035;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaign_feedback')
          .where('campaignId', isEqualTo: campaignId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "rating_cannot_be_calculated".tr(),
            style: TextStyle(fontSize: participantTextSize),
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

        double average = 0.0;
        if (docs.isNotEmpty) {
          final totalRating = docs.fold<int>(0, (sum, doc) {
            final rating = doc['rating'] as int? ?? 0;
            return sum + rating;
          });
          average = totalRating / docs.length;
        }

        return Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: iconSize),
            SizedBox(width: screenWidth * 0.02),
            Text(
              '${average.toStringAsFixed(1)} / 5',
              style: TextStyle(
                fontSize: ratingTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

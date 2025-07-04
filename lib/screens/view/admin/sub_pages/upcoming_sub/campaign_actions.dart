import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:activity_repository/activity_repository.dart';
import '../../../../auth/views/sign_in_screen.dart';
import '../../../user/campaign/campaign_registration_screen.dart';

class CampaignActions {
  static void handleJoinCampaign(BuildContext context, FeaturedActivity activity) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignRegistrationScreen(activity: activity),
      ),
    );
  }

  // Xử lý bookmark
  static Future<void> toggleBookmark({
    required String activityId,
    required bool isCurrentlyBookmarked,
    required Function(bool) onBookmarkUpdated,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final newBookmarkStatus = !isCurrentlyBookmarked;

      await userDocRef.update({
        'bookmarkedEvents': newBookmarkStatus
            ? FieldValue.arrayUnion([activityId])
            : FieldValue.arrayRemove([activityId])
      });

      onBookmarkUpdated(newBookmarkStatus);
    } catch (e) {
      print('Error updating bookmark: $e');
    }
  }

}
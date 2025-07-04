import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../campaign/campaign_detail_screen.dart';

class DynamicLinkHandler {
  static Future<void> initDynamicLinks(BuildContext context) async {
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      await _handleLink(context, initialLink.link);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      await _handleLink(context, dynamicLinkData.link);
    }).onError((error) {
      debugPrint('Lỗi dynamic link: $error');
    });
  }

  // Hàm static để gọi trong _handleLink
  static Future<FeaturedActivity> fetchFeaturedActivityById(String id) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('featured_activities') // đổi tên collection nếu cần
        .doc(id)
        .get();

    if (!docSnapshot.exists) {
      throw Exception('Campaign with id $id not found');
    }

    return FeaturedActivity.fromDocument(docSnapshot);
  }

  // Chuyển hàm này thành async để dùng await
  static Future<void> _handleLink(BuildContext context, Uri deepLink) async {
    if (deepLink.pathSegments.contains('campaigns')) {
      final campaignId = deepLink.pathSegments.last;
      try {
        final activity = await fetchFeaturedActivityById(campaignId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignDetailScreen(activity: activity),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("no_campaigns_found".tr())),
        );
      }
    }
  }
}

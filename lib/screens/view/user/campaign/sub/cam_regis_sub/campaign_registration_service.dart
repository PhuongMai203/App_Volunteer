import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:activity_repository/activity_repository.dart';

class CampaignRegistrationService {
  String getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Future<void> fetchUserInfo(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController locationController,
      TextEditingController birthYearController,
      TextEditingController phoneController,
      ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        locationController.text = data['location'] ?? '';
        birthYearController.text = (data['birthYear'] ?? '').toString();
        phoneController.text = (data['phone'] ?? '').toString();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('fetchUserError'.tr(args: [e.toString()]))),
      );
    }
  }
  /// Kiểm tra xem user đã đăng ký chiến dịch này chưa
  Future<bool> isAlreadyRegistered({
    required String userId,
    required String campaignId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: userId)
        .where('campaignId', isEqualTo: campaignId)
        .get();

    return snapshot.docs.isNotEmpty;
  }
  Future<void> submitRegistration({
    required BuildContext context,
    required FeaturedActivity activity,
    required String name,
    required String location,
    required String birthYear,
    required String phone,
    required List<String> participationTypes,
    required String donationAmount,
    VoidCallback? onRegistered,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("userNotLoggedIn".tr());

      // Lấy dữ liệu người dùng từ Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception("userDataNotFound".tr());

      final userData = userDoc.data()!;
      print('User avatarUrl: ${userData['avatarUrl']}');

      // Thêm đăng ký
      await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .add({
        'userId': user.uid,
        'campaignId': activity.id,
        'email_campaign': activity.email,
        'title': activity.title,
        'name': name,
        'location': location,
        'birthYear': birthYear,
        'phone': phone,
        'participationTypes': participationTypes,
        'donationAmount': donationAmount,
        'avatarUrl': userData['avatarUrl'] ?? '',
        'email': userData['email'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Cập nhật campaign count
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'campaignCount': FieldValue.increment(1)});

      onRegistered?.call();
      Navigator.pop<FeaturedActivity>(context, activity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("campaignRegistrationSuccess".tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('generalError'.tr(args: [e.toString()]))),
      );
    }
  }
}
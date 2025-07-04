import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/view/admin/adminDashboardPage.dart';
import 'screens/view/business/view/main_pages/home_business.dart';
import 'screens/view/user/main_pages/landing_page.dart';
import 'screens/auth/views/sign_in_screen.dart'; // Nếu có

class AppStartRedirector extends StatelessWidget {
  const AppStartRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Đã xảy ra lỗi khi tải dữ liệu.')),
          );
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _getStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SignInScreen(); // hoặc LandingPage nếu bạn muốn
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';

      switch (role) {
        case 'admin':
          return const AdminDashboardPage();
        case 'organization':
        case 'volunteer':
          return const PartnerHomePage();
        case 'user':
        default:
          return const LandingPage();
      }
    } catch (e) {
      return const LandingPage(); // fallback nếu Firestore lỗi
    }
  }
}

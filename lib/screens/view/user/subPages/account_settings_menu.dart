import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

import '../../business/view/widgets/profile/edit/edit_profile_security_section.dart';

void showSettingsMenu(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final dialogWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.85;

  final firebaseUser = FirebaseAuth.instance.currentUser;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "settings".tr(),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: dialogWidth.clamp(250, 500), // tránh quá nhỏ hoặc quá to
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5ED),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: firebaseUser == null
                    ? _buildGuestMenu(context)
                    : _buildUserMenu(context, firebaseUser.uid),
              );
            },
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: anim1,
        curve: Curves.easeInOut,
      ));
      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

Widget _buildGuestMenu(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: Icon(Icons.login, color: Colors.red),
          title: Text("sign_in".tr()),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/register');
          },
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text("create_new_account".tr()),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}

Widget _buildUserMenu(BuildContext context, String uid) {
  final userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots();

  return StreamBuilder<DocumentSnapshot>(
    stream: userStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text("error_loading_data".tr()));
      }

      final data = snapshot.data?.data() as Map<String, dynamic>?;

      if (data == null) {
        return Center(child: Text("no_user_data".tr()));
      }

      final myUser = MyUser.fromEntity(MyUserEntity.fromMap(data));

      return Material(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),

          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: myUser.avatarUrl.isNotEmpty
                      ? NetworkImage(myUser.avatarUrl)
                      : null,
                  child: myUser.avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 30)
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  myUser.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  myUser.email,
                  style: TextStyle(color: Colors.grey),
                ),
                Divider(height: 30),
              ],
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("manage_personal_info".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-profile', arguments: myUser);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("security_and_passwords".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileSecurityPage(user: myUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text("identity_verification".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/verify');
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text("privacy_policy_terms".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/privacy-policy');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("logout".tr()),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedOut', true);
                await prefs.remove('email');
                await prefs.remove('password');
                Navigator.pushReplacementNamed(context, '/first');
              },
            ),
          ],
        ),
      );
    },
  );
}
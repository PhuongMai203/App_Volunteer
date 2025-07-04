import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

import 'infor/account_information.dart';
import 'edit/edit_profile_security_section.dart';

void showSettingsMenu_BN(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  // Chỉ hiển thị menu nếu người dùng đã đăng nhập
  if (firebaseUser == null) {
    return; // Không hiển thị gì nếu chưa đăng nhập
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "settings".tr(),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: screenWidth * 0.85,
          margin: EdgeInsets.only(right: 0),
          decoration: BoxDecoration(
            color: Color(0xFFFFF5ED),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
          ),
          child: _buildUserMenu(context, firebaseUser.uid),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final offsetAnimation = Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: anim1,
        curve: Curves.easeInOut,
      ));

      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
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

      // Chuyển đổi dữ liệu thành đối tượng MyUser
      final myUser = MyUser.fromEntity(MyUserEntity.fromMap(data));

      return Material(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),

          children: [
            // Avatar & Thông tin cơ bản
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: myUser.avatarUrl.isNotEmpty
                        ? Image.network(
                      myUser.avatarUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
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

            // Các mục trong menu
            ListTile(
              leading: Icon(Icons.person),
              title: Text("manage_personal_info".tr()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountInformation(user: myUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("security_and_passwords".tr()),
              onTap: () {
                Navigator.pop(context); // Đóng menu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileSecurityPage(user: myUser), // ✅ Dùng myUser ở đây
                  ),
                );
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
                Navigator.pop(context); // Đóng bottom sheet
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
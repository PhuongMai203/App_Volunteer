import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../components/app_colors.dart';
import '../../business/business_detail_dung.dart';


class BusinessPage extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const BusinessPage({
    super.key,
    this.searchQuery = '',
    this.selectedFilter = '',
  });

  // Hàm lấy dữ liệu người dùng từ Firebase
  Stream<QuerySnapshot> getUserData() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cotton,
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("error_occurred".tr()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("no_users".tr()));
          }

          // 1. Lọc chỉ role là "organization" và isApproved khác false
          List<QueryDocumentSnapshot> users = snapshot.data!.docs.where((user) {
            final data = user.data() as Map<String, dynamic>;
            final role = data['role']?.toString().toLowerCase() ?? '';
            final isApproved = data['isApproved'];
            return role == 'organization' && (isApproved == null || isApproved == true);
          }).toList();


          if (users.isEmpty) {
            return Center(child: Text("no_organizations".tr()));
          }

          // 2. Lọc theo tìm kiếm name và email
          final query = searchQuery.trim().toLowerCase();
          if (query.isNotEmpty) {
            users = users.where((user) {
              final data = user.data() as Map<String, dynamic>;
              final name = (data['name'] as String? ?? '').toLowerCase();
              final email = (data['email'] as String? ?? '').toLowerCase();
              return name.contains(query) || email.contains(query);
            }).toList();
          }

          if (users.isEmpty) {
            return Center(child: Text("no_matching_organization".tr()));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;
              final String name = data['name'] ?? "no_name".tr();
              final String email = data['email'] ?? "no_email".tr();
              final String avatarUrl = data['avatarUrl'] ?? '';
              final String userId = user.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.sunrise, width: 1.5),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessDetailsPage(userId: userId),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 40, color: AppColors.sunrise)
                        : CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${"email".tr()} $email',
                      style: TextStyle( color: AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

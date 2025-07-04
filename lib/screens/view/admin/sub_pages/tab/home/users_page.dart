import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../components/app_colors.dart';
import '../../user_details_page.dart';

class UsersPage extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const UsersPage({
    Key? key,
    this.searchQuery = '',
    this.selectedFilter = '',
  }) : super(key: key);

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

          // Lọc theo role
          List<QueryDocumentSnapshot> users = snapshot.data!.docs.where((user) {
            final data = user.data() as Map<String, dynamic>;
            final role = data['role']?.toString().toLowerCase() ?? '';
            return role == 'user';
          }).toList();

          // Lọc theo tìm kiếm name và email
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
            return Center(child: Text("no_matching_results_found".tr()));
          }

          return Column(
            children: [
              // Ghi chú legend
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                child: Row(
                  children: [
                    // Đã vô hiệu hóa
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("account_disabled".tr(), style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 24),
                    // Hoạt động
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.sunrise, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("statistics".tr(), style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;
                    final String name = data['name'] ?? "no_name".tr();
                    final String email = data['email'] ?? "no_email".tr();
                    final String avatarUrl = data['avatarUrl'] ?? '';
                    final String userId = user.id;
                    final bool isDisabled = data['isDisabled'] == true;
                    // Chọn màu nền: light-red (Red100) hoặc trắng
                    final Color bgColor = isDisabled
                        ? const Color(0xFFFFCDD2)  // Material Red 100
                        : Colors.white;
                    return Card(
                      color: bgColor,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDisabled ? Colors.red : AppColors.sunrise,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailsPage(userId: userId),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../components/app_colors.dart';
import '../sub_pages/add_user_page.dart';
import '../sub_pages/tab/home/business_page.dart';
import '../sub_pages/tab/home/users_page.dart';

class UsersAndBusinessesPage extends StatelessWidget {
  const UsersAndBusinessesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cotton,
        body: Column(
          children: [
            // TabBar nằm trong body
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.sunrise,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.sunrise,
                tabs: [
                  Tab(icon: Icon(Icons.people), text: 'legendVolunteers'.tr()),
                  Tab(icon: Icon(Icons.business), text: "organization".tr()),
                ],
              ),
            ),
// Nút thêm người dùng
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddUserPage()),
                  );
                },

                icon: const Icon(Icons.add, color: Colors.white,),
                label: Text("add_new_user".tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sunrise,
                ),
              ),
            ),
            // TabBarView mở rộng phần còn lại
            Expanded(
              child: TabBarView(
                children: [
                  UsersPage(),
                  BusinessPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

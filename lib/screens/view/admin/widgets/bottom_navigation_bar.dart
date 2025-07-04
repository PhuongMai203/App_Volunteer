import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../components/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.pureWhite, // Nền thanh điều hướng trắng
      selectedItemColor: AppColors.sunrise, // Màu cam cho mục được chọn
      unselectedItemColor: AppColors.slateGrey, // Màu xám cho mục chưa chọn
      showUnselectedLabels: true, // Hiển thị nhãn cho mục chưa chọn
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.supervised_user_circle),
          label: "user".tr(),
        ),
         BottomNavigationBarItem(
          icon:const Icon(Icons.assignment),
          label: "upcoming_campaign".tr(),
        ),
        BottomNavigationBarItem(
          icon:const Icon(Icons.add_box),
          label: "create_request".tr(),
        ),
        BottomNavigationBarItem(
          icon:const Icon(Icons.forum),
          label: "message".tr(),
        ),
         BottomNavigationBarItem(
          icon:const Icon(Icons.manage_accounts),
          label:"account".tr(),
        ),
      ],
    );
  }
}

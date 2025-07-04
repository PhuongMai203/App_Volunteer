import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
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
      type: BottomNavigationBarType.fixed, // Để hiện đầy đủ nhãn khi >3 items
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.maps_home_work_outlined),
          label: "home_title".tr(),
        ),
         BottomNavigationBarItem(
          icon:const Icon(Icons.schedule),
          label: "my_campaign".tr(),
        ),
         BottomNavigationBarItem(
          icon: const Icon(Icons.done_all),
          label: "campaign_completed".tr(),
        ),
         BottomNavigationBarItem(
          icon:const Icon(Icons.add_box),
          label: "create_request".tr(),
        ),
         BottomNavigationBarItem(
          icon:const Icon(Icons.manage_accounts),
          label: "account".tr(),
        ),
      ],
    );
  }
}

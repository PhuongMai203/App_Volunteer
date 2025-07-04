import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chat/chat_bn.dart';
import '../../../../components/app_colors.dart';

import '../view/widgets/home/notification_list.dart';

class PartnerHeader extends StatelessWidget {
  const PartnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome".tr(),
              style: GoogleFonts.agbalumo(
                fontSize: 16,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Business_is_back".tr(),
              style: GoogleFonts.agbalumo(
                fontSize: 24,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút thông báo với badge
            FutureBuilder<int>(
              future: NotificationService.fetchUnreadCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return IconButton(
                  icon: Badge(
                    label: count > 0
                        ? Text('+$count', style: const TextStyle(fontSize: 10))
                        : null,
                    isLabelVisible: count > 0,
                    child: const Icon(Icons.notifications_outlined, size: 28, color: AppColors.textPrimary),
                  ),
                  onPressed: () async {
                    final notifications = await NotificationService.fetchNotifications();
                    await NotificationService.markAllAsRead(notifications);
                    NotificationService.showNotificationPopup(context, notifications);
                  },
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.forum_outlined, size: 28, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBn()),
                );
              },
            ),
          ],
        ),

      ],
    );
  }
}

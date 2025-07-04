import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class AttendanceNotificationItem extends StatelessWidget {
  final String id;
  final String title;

  const AttendanceNotificationItem({
    Key? key,
    required this.id,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04; // khoảng 4% chiều rộng
    final verticalPadding = screenWidth * 0.025;  // khoảng 2.5% chiều rộng
    final fontSize = screenWidth * 0.035;         // khoảng 3.5% chiều rộng

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '✅ Điểm danh thành công chiến dịch "$title", được cộng 10đ thành tích!',
              style: TextStyle(
                fontSize: fontSize.clamp(12, 16), // Giới hạn kích thước font trong khoảng hợp lý
                fontWeight: FontWeight.w600,
                color: AppColors.deepOcean,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:activity_repository/activity_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class EventNotificationItem extends StatelessWidget {
  final FeaturedActivity event;
  final bool isNew;

  const EventNotificationItem({required this.event, required this.isNew});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expired = event.startDate.isBefore(now);

    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 22.0 : 28.0;
    final titleFontSize = screenWidth < 360 ? 13.0 : 14.0;
    final subtitleFontSize = screenWidth < 360 ? 11.0 : 12.0;
    final statusFontSize = screenWidth < 360 ? 11.0 : 12.0;
    final padding = screenWidth < 360 ? 8.0 : 12.0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 1.5),
            leading: Icon(Icons.campaign, color: Colors.orangeAccent, size: iconSize),
            title: Text(
              event.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: titleFontSize,
                color: AppColors.deepOcean,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expired)
                  Text(
                    'Đã hoàn thành',
                    style: TextStyle(
                      fontSize: statusFontSize,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'Còn lại: ${_calculateRemainingDays(event.startDate)} ngày',
                    style: TextStyle(
                      fontSize: statusFontSize,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  'Ngày bắt đầu: ${_formatDate(event.startDate)}',
                  style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey[700]),
                ),
              ],
            ),
            minVerticalPadding: 0,
            dense: true,
          ),
        ),
        if (isNew && !expired)
          const Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 5,
              backgroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  int _calculateRemainingDays(DateTime date) =>
      date.difference(DateTime.now()).inDays;
}

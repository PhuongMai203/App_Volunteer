import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';
import '../../subPages/profile_sub/user_rank.dart';

class RankNotificationItem extends StatelessWidget {
  final String id;
  final String newRank;

  const RankNotificationItem({
    required this.id,
    required this.newRank,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final textSize = screenWidth < 360 ? 13.0 : 14.0;
    final padding = screenWidth < 360 ? 8.0 : 12.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BeautifulRankPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: iconSize)),
            SizedBox(width: padding * 0.6),
            Expanded(
              child: Text(
                'Chúc mừng bạn đã đạt danh hiệu mới! Danh hiệu của bạn là: $newRank',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepOcean,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

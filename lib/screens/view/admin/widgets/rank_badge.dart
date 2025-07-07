import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RankBadge extends StatelessWidget {
  final String rank;
  final TextEditingController controller;
  final Color badgeColor;

  const RankBadge({
    Key? key,
    required this.rank,
    required this.controller,
    required this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            rank,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: badgeColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

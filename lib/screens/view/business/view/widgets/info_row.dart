import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Widget? textWidget;
  final bool isUrgent;
  const InfoRow({
    super.key,
    required this.icon,
    this.text,
    this.textWidget,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    String urgencyLevel = '';
    if (text != null &&
        (text!.toLowerCase().contains("khẩn cấp") ||
            text!.toLowerCase().contains("urgency"))) {
      urgencyLevel = text!.split(':').last.trim().toLowerCase();
    }

    Color? textColor;
    Color iconColor;

    switch (urgencyLevel) {
      case 'thấp':
        textColor = Colors.green;
        iconColor = Colors.green.shade800;
        break;
      case 'trung bình':
        textColor = Colors.orange;
        iconColor = Colors.orange.shade800;
        break;
      case 'cao':
        textColor = Colors.red;
        iconColor = Colors.red.shade800;
        break;
      default:
        textColor = isUrgent ? Colors.red : AppColors.deepOcean;
        iconColor = isUrgent ? Colors.red : Colors.black54;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: textWidget ??
                Text(
                  text ?? '',
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
          ),
        ],
      ),
    );
  }
}

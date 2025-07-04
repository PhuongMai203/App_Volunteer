import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart'; // Import AppColors nếu chưa có

import '../info_row.dart';

class CampaignDetailReadOnlySummary extends StatelessWidget {
  final String dateRange;
  final Map<String, dynamic> data;
  // THÊM: Callback khi người dùng nhấn nút xóa
  final VoidCallback? onDeleteCampaign;
  final bool isCurrentUserOwner; // THÊM: Để kiểm tra xem người dùng hiện tại có phải chủ sở hữu không

  const CampaignDetailReadOnlySummary({
    super.key,
    required this.dateRange,
    required this.data,
    this.onDeleteCampaign, // THÊM: Là một tham số tùy chọn
    required this.isCurrentUserOwner, // THÊM: Yêu cầu tham số này
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(icon: Icons.calendar_month, textWidget: Text('${tr("time")} $dateRange', style: const TextStyle(fontSize: 16))),
          InfoRow(icon: Icons.category, textWidget: Text('${tr("category")} ${data['category'] ?? ""}', style: const TextStyle(fontSize: 16))),
          InfoRow(icon: Icons.priority_high, textWidget: Text('${tr("urgency")} ${data['urgency'] ?? ""}', style: const TextStyle(fontSize: 16))),
          InfoRow(icon: Icons.location_on, textWidget: Text('${tr("address")} ${data['address'] ?? ""}', style: const TextStyle(fontSize: 16))),
          InfoRow(icon: Icons.phone, textWidget: Text('${tr("phoneNumber")} ${data['phoneNumber'] ?? ""}', style: const TextStyle(fontSize: 16))),
          InfoRow(icon: Icons.help_outline, textWidget: Text('${tr("supportType")} ${data['supportType'] ?? ""}', style: const TextStyle(fontSize: 16))),
          if ((data['bankName'] ?? '').isNotEmpty || (data['bankAccount'] ?? '').isNotEmpty)
            InfoRow(
              icon: Icons.account_balance,
              textWidget: Text('${tr("account_number")}: ${data['bankName'] ?? ""} - ${data['bankAccount'] ?? ""}', style: const TextStyle(fontSize: 16)),
            ),

          // THÊM: Nút xóa chiến dịch, chỉ hiển thị nếu người dùng là chủ sở hữu
          if (isCurrentUserOwner && onDeleteCampaign != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0), // Khoảng cách với thông tin phía trên
              child: SizedBox( // Bọc trong SizedBox để giới hạn chiều rộng
                width: double.infinity, // Nút sẽ chiếm toàn bộ chiều rộng có thể
                child: ElevatedButton.icon(
                  onPressed: onDeleteCampaign,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: Text(
                    tr("delete_campaign"), // Sử dụng easy_localization
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Màu đỏ cho nút xóa
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
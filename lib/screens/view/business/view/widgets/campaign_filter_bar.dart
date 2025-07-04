// campaign_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../components/app_colors.dart';

class CampaignFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CampaignFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2), // thêm khoảng cách phía trên
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list_alt, color: AppColors.pureWhite, size: 28.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            onSelected: onFilterChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: '',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: selectedFilter == '' ? AppColors.sunrise : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'filter_default'.tr(),
                      style: TextStyle(
                        color: selectedFilter == '' ? AppColors.sunrise : Colors.black87,
                        fontWeight: selectedFilter == '' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'A-Z',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: selectedFilter == 'A-Z' ? AppColors.sunrise : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "A-Z",
                      style: TextStyle(
                        color: selectedFilter == 'A-Z' ? AppColors.sunrise : Colors.black87,
                        fontWeight: selectedFilter == 'A-Z' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expiring',
                child: Row(
                  children: [
                    Icon(Icons.hourglass_bottom, color: selectedFilter == 'expiring' ? AppColors.sunrise : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'filter_expiring'.tr(),
                      style: TextStyle(
                        color: selectedFilter == 'expiring' ? AppColors.sunrise : Colors.black87,
                        fontWeight: selectedFilter == 'expiring' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

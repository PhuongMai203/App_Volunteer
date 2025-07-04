import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../components/app_colors.dart';

class CampaignCompleted extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback? onTap;
  const CampaignCompleted({Key? key, required this.campaign, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 100,
        child: Container(
          padding: const EdgeInsets.all(6), // Giảm padding nếu cần
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if ((campaign['daysLeft'] != null && campaign['daysLeft'] < 0))
                    Chip(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.mint.withOpacity(0.4),
                      label: Text(
                        "Completed".tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Middle row: progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: campaign['progress'],
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${campaign['progressPercent']}%',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Bottom row: reached / target
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "achieved".tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    campaign['target'] ?? '0₫',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:activity_repository/activity_repository.dart';
import '../../../../../service/dynamic_link_service.dart';
import '../../admin/sub_pages/upcoming_sub/campaign_actions.dart';
import '../campaign/button_upcoming/campaign_report.dart';

class CampaignActionButtons extends StatelessWidget {
  final FeaturedActivity activity;

  const CampaignActionButtons({
    super.key,
    required this.activity,
  });

  void _handleAction(BuildContext context, VoidCallback action) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/register');
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallDevice = constraints.maxWidth < 350;
        final buttonHeight = isSmallDevice ? 36.0 : 44.0;
        final iconSize = isSmallDevice ? 20.0 : 24.0;
        final spacing = isSmallDevice ? 6.0 : 8.0;

        return Padding(
          padding: EdgeInsets.only(left: spacing, right: spacing, bottom: spacing * 2),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF38759),
                    minimumSize: Size(double.infinity, buttonHeight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _handleAction(context, () {
                    CampaignActions.handleJoinCampaign(context, activity);
                  }),
                  child: Text(
                    "join".tr(),
                    style: TextStyle(color: Colors.white, fontSize: isSmallDevice ? 14 : 16),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    minimumSize: Size(double.infinity, buttonHeight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _handleAction(context, () {
                    CampaignReport.showReportDialog(context, activity);
                  }),
                  child: Text(
                    "report".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallDevice ? 14 : 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              IconButton(
                icon: Icon(Icons.share, color: Colors.orange, size: iconSize),
                onPressed: () {
                  DynamicLinkService.shareCampaign(activity.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

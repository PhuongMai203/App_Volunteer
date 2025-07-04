import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:activity_repository/activity_repository.dart';

import '../../../../components/app_gradients.dart';
import '../../admin/sub_pages/upcoming_sub/campaign_utils.dart';
import '../../admin/sub_pages/upcoming_sub/widgets/volunteer_count_widget.dart';
import '../subPages/campaign_action_buttons.dart';
import '../widgets/campaign/campaign_description_field.dart';

class CampaignDetailScreen extends StatefulWidget {
  final FeaturedActivity activity;
  final bool isEditing;

  const CampaignDetailScreen({
    super.key,
    required this.activity,
    this.isEditing = false,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionController =
        TextEditingController(text: widget.activity.description ?? '');
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end
        .month}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: AppGradients.peachPinkToOrange),
          child: Scaffold(
            backgroundColor: AppColors.softBackground,
            appBar: AppBar(
              title: Text(
                widget.activity.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.sunrise,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    widget.activity.imageUrl,
                    width: double.infinity,
                    height: isTablet ? 300 : 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: isTablet ? 300 : 220,
                            color: AppColors.pureWhite),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.title,
                          style: TextStyle(
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CampaignDescriptionField(
                          campaignId: widget.activity.id,
                          controller: descriptionController,
                          isEditing: widget.isEditing,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.calendar_month, '${tr(
                            "time")} ${_formatDateRange(
                            widget.activity.startDate,
                            widget.activity.endDate)}', isTablet),
                        _buildInfoRow(Icons.category, '${tr(
                            "category")} ${widget.activity.category}',
                            isTablet),
                        _buildInfoRow(Icons.priority_high, '${tr(
                            "urgency")} ${widget.activity.urgency}', isTablet,
                            isUrgent: true),
                        _buildInfoRow(Icons.location_on, '${tr(
                            "address")} ${widget.activity.address}', isTablet),
                        _buildInfoRow(Icons.phone, '${tr(
                            "phoneNumber")} ${widget.activity.phoneNumber}',
                            isTablet),
                        _buildInfoRow(Icons.help_outline, '${tr(
                            "supportType")} ${widget.activity.supportType}',
                            isTablet),
                        _buildInfoRow(Icons.receipt, '${tr(
                            "receivingMethod")} ${widget.activity
                            .receivingMethod}', isTablet),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.account_balance,
                                  size: isTablet ? 20 : 16,
                                  color: Colors.lightGreen.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${"account".tr()} ${widget.activity
                                      .bankName} - ${widget.activity
                                      .bankAccount}',
                                  style: TextStyle(fontSize: isTablet ? 16 : 14,
                                      color: AppColors.deepOcean),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, size: isTablet ? 20 : 18,
                                    color: Colors.grey),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: widget.activity.bankAccount!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("copiedBankAccount".tr(),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: VolunteerCountWidget(
                                campaignId: widget.activity.id,
                                isEditing: widget.isEditing,
                                maxVolunteerCountController: TextEditingController(
                                    text: widget.activity.maxVolunteerCount
                                        .toString()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 12 : 8,
                                  vertical: isTablet ? 6 : 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                CampaignUtils.formatDonation(
                                    widget.activity.totalDonationAmount),
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CampaignActionButtons(activity: widget.activity),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isTablet,
      {bool isUrgent = false}) {
    String urgencyLevel = '';
    if (text.toLowerCase().contains("urgency".tr().toLowerCase())) {
      final parts = text.split(':');
      if (parts.length > 1) {
        urgencyLevel = parts.last.trim().toLowerCase();
      }
    }

    Color? textColor;
    Color iconColor = Colors.lightGreen.shade900;

    switch (urgencyLevel) {
      case 'thấp':
        textColor = Colors.green;
        break;
      case 'trung bình':
        textColor = Colors.orange;
        break;
      case 'cao':
        textColor = Colors.red;
        break;
      default:
        textColor = isUrgent ? Colors.red : AppColors.deepOcean;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isTablet ? 20 : 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isTablet ? 16 : 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
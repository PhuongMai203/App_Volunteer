import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:activity_repository/activity_repository.dart';

import '../../../main_pages/profile_screen.dart';
import 'sub/campaign_average_rating.dart';
import 'sub/feedback_section.dart';
import 'widgets/campaign_feedback_service.dart';
import 'widgets/feedback_prompt.dart';

class CampaignDetailFeedback extends StatefulWidget {
  final FeaturedActivity activity;
  const CampaignDetailFeedback({super.key, required this.activity});

  @override
  State<CampaignDetailFeedback> createState() => _CampaignDetailFeedbackState();
}

class _CampaignDetailFeedbackState extends State<CampaignDetailFeedback> {
  String userRole = '';
  final _feedbackService = CampaignFeedbackService();
  bool hasRated = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _checkIfUserRated();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userRole = doc.data()?['role'] ?? '';
        });
      }
    }
  }

  Future<void> _checkIfUserRated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('campaign_feedback')
        .where('userId', isEqualTo: user.uid)
        .where('campaignId', isEqualTo: widget.activity.id)
        .get();

    setState(() {
      hasRated = snapshot.docs.isNotEmpty;
    });
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  String _formatDonation(double amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => false,
            );
          },
        ),
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.activity.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.pureWhite),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
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
                  Text(
                    widget.activity.description,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_month, '${tr("time")} ${_formatDateRange(widget.activity.startDate, widget.activity.endDate)}', isTablet),
                  _buildInfoRow(Icons.category, '${tr("category")} ${widget.activity.category}', isTablet),
                  _buildInfoRow(Icons.priority_high, '${tr("urgency")} ${widget.activity.urgency.isNotEmpty ? widget.activity.urgency : tr("not_updated")}', isTablet, isUrgent: true, urgencyLevel: widget.activity.urgency),
                  _buildInfoRow(Icons.location_on, '${tr("address")} ${widget.activity.address}', isTablet),
                  _buildInfoRow(Icons.phone, '${tr("phoneNumber")} ${widget.activity.phoneNumber}', isTablet),
                  _buildInfoRow(Icons.help_outline, '${tr("supportType")} ${widget.activity.supportType}', isTablet),
                  _buildInfoRow(Icons.receipt, '${tr("receivingMethod")} ${widget.activity.receivingMethod}', isTablet),
                  _buildInfoRow(Icons.account_balance, '${tr("account")} ${widget.activity.bankName} - ${widget.activity.bankAccount}', isTablet),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.lightGreen.shade900),
                          const SizedBox(width: 4),
                          Text('${tr("participants_count")} ${widget.activity.participantCount}'),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8, vertical: isTablet ? 8 : 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${tr("donation_amount")} ${_formatDonation(widget.activity.totalDonationAmount)} VNĐ',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        tr("feedback_from_participants"),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      const SizedBox(width: 16),
                      CampaignAverageRating(campaignId: widget.activity.id),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FeedbackSection(campaignId: widget.activity.id),
                  if (!hasRated) ...[
                    const SizedBox(height: 16),
                    FeedbackPrompt(
                      onCancel: () {},
                      onSubmit: (rating, comment) async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) return;

                        await _feedbackService.submitFeedback(
                          campaignId: widget.activity.id,
                          rating: rating,
                          comment: comment,
                        );

                        setState(() {
                          hasRated = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr("thanks_feedback")),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isTablet, {bool isUrgent = false, String? urgencyLevel}) {
    Color? textColor;
    Color iconColor = Colors.lightGreen.shade900;

    if (urgencyLevel != null) {
      switch (urgencyLevel.toLowerCase()) {
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
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: textColor,
                fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

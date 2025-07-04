import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';

import '../../../user/subPages/campaign_action_buttons.dart';
import '../../../user/campaign/campaign_detail_screen.dart';
import '../../../user/widgets/campaign/campaign_description_field.dart';
import 'campaign_actions.dart';
import 'campaign_utils.dart';
import 'widgets/volunteer_count_widget.dart';


class CampaignCard extends StatefulWidget {
  final FeaturedActivity activity;
  final VoidCallback? onDeleted;

  const CampaignCard({
    super.key,
    required this.activity,
    this.onDeleted,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isBookmarked = false;
  late TextEditingController _descController;
  late TextEditingController _maxCountController;

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.activity.description);
    _maxCountController = TextEditingController(text: widget.activity.maxVolunteerCount.toString());
    _loadInitialData();
  }

  @override
  void dispose() {
    _descController.dispose();
    _maxCountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docSnap = await _firestore.collection('users').doc(user.uid).get();
      final data = docSnap.data() ?? {};

      if (!mounted) return;
      setState(() {
        _isBookmarked = (data['bookmarkedEvents'] as List<dynamic>? ?? []).contains(widget.activity.id);
      });
    } catch (e) {
      _showErrorSnackbar('error_loading_data'.tr(args: [e.toString()]));
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CampaignDetailScreen(activity: widget.activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CampaignImage(
            imageUrl: activity.imageUrl,
            isBookmarked: _isBookmarked,
            onBookmarkToggle: () { // Vẫn giữ _handleAction cho bookmark vì nó liên quan trực tiếp đến state của CampaignCard
              if (_auth.currentUser == null) {
                Navigator.pushNamed(context, '/register');
              } else {
                CampaignActions.toggleBookmark(
                  activityId: activity.id,
                  isCurrentlyBookmarked: _isBookmarked,
                  onBookmarkUpdated: (newStatus) {
                    setState(() => _isBookmarked = newStatus);
                  },
                );
              }
            },
            onTap: _goToDetail,
          ),
          GestureDetector(
            onTap: _goToDetail,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CampaignDescriptionField(
                    campaignId: widget.activity.id,
                    controller: _descController,
                    isEditing: false,
                  ),
                  _buildInfoRow(Icons.calendar_today,
                      '${tr("time")} ${_formatDateRange(activity.startDate, activity.endDate)}'),
                  _buildInfoRow(Icons.category, '${tr("category")} ${activity.category}'),
                  _buildInfoRow(Icons.priority_high, '${tr("urgency")} ${activity.urgency}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      VolunteerCountWidget(
                        campaignId: activity.id,
                        maxVolunteerCountController: _maxCountController,
                        isEditing: false,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CampaignUtils.formatDonation(activity.totalDonationAmount.toDouble() ?? 0.0),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),

          CampaignActionButtons(activity: activity),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.lightGreen.shade900),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: color ?? Colors.black87))),
        ],
      ),
    );
  }
}

class _CampaignImage extends StatelessWidget {
  final String imageUrl;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTap;

  const _CampaignImage({
    required this.imageUrl,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: GestureDetector(
            onTap: onTap,
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey[200], height: 180),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onBookmarkToggle,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 30,
                color: isBookmarked ? Colors.amber.shade600 : Colors.amber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
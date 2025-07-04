import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class CampaignDescriptionField extends StatefulWidget {
  final String campaignId;
  final bool isEditing;
  final TextEditingController controller;

  const CampaignDescriptionField({
    super.key,
    required this.campaignId,
    required this.controller,
    required this.isEditing,
  });

  @override
  State<CampaignDescriptionField> createState() => _CampaignDescriptionFieldState();
}

class _CampaignDescriptionFieldState extends State<CampaignDescriptionField> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    try {
      final snapshot = await _firestore.collection('campaigns').doc(widget.campaignId).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        final description = data?['description'] ?? '';
        widget.controller.text = description;
      }
    } catch (e) {
      debugPrint('Error loading campaign description: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> updateDescription() async {
    try {
      await _firestore.collection('campaigns').doc(widget.campaignId).update({
        'description': widget.controller.text.trim(),
      });
    } catch (e) {
      debugPrint('Error updating campaign description: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final contentPadding = isTablet ? 24.0 : 16.0;

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(contentPadding),
        child: const SizedBox(
          height: 20,
          width: 50,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: contentPadding, right: contentPadding, bottom: contentPadding),
      child: widget.isEditing
          ? ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isTablet ? 150 : 100,
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: null,
          decoration: InputDecoration(
            labelText: 'Mô tả chiến dịch',
            labelStyle: TextStyle(color: AppColors.textPrimary),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepOrange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepOrange, width: 2),
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary),
        ),
      )
          : Text(
        widget.controller.text,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          color: AppColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }
}

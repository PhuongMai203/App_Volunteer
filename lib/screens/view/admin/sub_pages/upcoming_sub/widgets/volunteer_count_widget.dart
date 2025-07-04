import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../../components/app_colors.dart';

class VolunteerCountWidget extends StatefulWidget {
  final String campaignId;
  final bool isEditing;
  final TextEditingController maxVolunteerCountController;

  const VolunteerCountWidget({
    super.key,
    required this.campaignId,
    required this.maxVolunteerCountController,
    required this.isEditing,
  });

  @override
  State<VolunteerCountWidget> createState() => _VolunteerCountWidgetState();
}

class _VolunteerCountWidgetState extends State<VolunteerCountWidget> {
  final _firestore = FirebaseFirestore.instance;
  int _directVolunteerCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteerCount();
  }

  Future<void> _loadVolunteerCount() async {
    try {
      final countSnap = await _firestore
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: widget.campaignId)
          .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
          .count()
          .get();

      int count = countSnap.count ?? -1;

      if (count < 0) {
        final fallbackSnap = await _firestore
            .collection('campaign_registrations')
            .where('campaignId', isEqualTo: widget.campaignId)
            .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
            .get();
        count = fallbackSnap.docs.length;
      }

      if (!mounted) return;

      setState(() {
        _directVolunteerCount = count;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _directVolunteerCount = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.lightGreen.shade900),
            const SizedBox(width: 4),
            widget.isEditing
                ? SizedBox(
              width: 60,
              child: TextField(
                controller: widget.maxVolunteerCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
              '$_directVolunteerCount/${widget.maxVolunteerCountController.text}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

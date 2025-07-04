// lib/screens/admin/sub_pages/activity_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../components/app_colors.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({Key? key, required this.activityId}) : super(key: key);

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late final Stream<DocumentSnapshot> _campaignStream;
  Map<String, dynamic>? _reportDetails;

  @override
  void initState() {
    super.initState();
    _campaignStream = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(widget.activityId)
        .snapshots();

    _loadReportDetails();
  }

  Future<void> _loadReportDetails() async {
    final report = await FirebaseFirestore.instance
        .collection('reports')
        .where('activityId', isEqualTo: widget.activityId)
        .limit(1)
        .get();

    if (report.docs.isNotEmpty) {
      setState(() {
        _reportDetails = report.docs.first.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("report_details".tr()),
        backgroundColor: AppColors.deepOcean,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _campaignStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("campaign_exits".tr()));
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                 "report_information".tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepOcean,
                  ),
                ),
                const Divider(),

                if (_reportDetails != null) ...[
                  _buildDetailItem("reason".tr(), _reportDetails!['reason']),
                  _buildDetailItem(
                    "reporting_time".tr(),
                    DateFormat('dd/MM/yyyy HH:mm').format(
                      (_reportDetails!['createdAt'] as Timestamp).toDate(),
                    ),
                  ),
                  _buildDetailItem("annunciator".tr(), _reportDetails!['userId']),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.deepOcean.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.deepOcean,
            ),
          ),
        ],
      ),
    );
  }
}
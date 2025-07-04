// business_detail_body.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../../../../components/app_colors.dart';

class BusinessDetailBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final String businessId;
  final Future<void> Function() onApproved;
  final Future<void> Function() onRejected;

  static const _imageLabels = {
    'logoUrl': 'Logo công ty',
    'stampUrl': 'Con dấu công ty',
    'idCardFrontUrl': 'Mặt trước CCCD',
    'idCardBackUrl': 'Mặt sau CCCD',
  };

  const BusinessDetailBody({
    Key? key,
    required this.data,
    required this.businessId,
    required this.onApproved,
    required this.onRejected,
  }) : super(key: key);

  String _formatTimestamp(Timestamp ts) => DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate());

  Widget _buildInfoSection() {
    final infoMapping = {
      "organization_name".tr(): data['companyName'],
      "email".tr(): data['userEmail'],
      "tax_id".tr(): data['taxCode'],
      "license".tr(): data['license'],
      "address".tr(): data['address'],
      "representative".tr(): data['representativeName'],
      "position".tr(): data['position'],
      "id_number".tr(): data['idNumber'],
      "bank_name".tr(): data['bankName'],
      "bank_branch".tr(): data['branch'],
      "account_number".tr(): data['accountNumber'],
      "accout_bank".tr(): data['accountHolder'],
      'User ID': data['userId'],
      "Date_sent".tr(): _formatTimestamp(data['submittedAt'] as Timestamp),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peach.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.sunrise.withAlpha((0.2 * 255).round()), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "title".tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.deepOcean,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...infoMapping.entries.map(
                (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    '${e.key}: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepOcean,
                        fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      e.value.toString(),
                      style: TextStyle(
                          color: AppColors.deepOcean,
                          fontSize: 16.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peach.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.yellowAccent.withAlpha((0.2 * 255).round()),
            blurRadius: 8
        )],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: _imageLabels.entries.map((entry) {
          final url = data[entry.key] as String?;
          return _ImageCard(imageUrl: url, label: entry.value);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          const SizedBox(height: 24),
          Text(
            "attached_documents".tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 12),
          _buildImageSection(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: data['isApproved'] == true
                      ? Colors.grey
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                onPressed: data['isApproved'] == true
                    ? null
                    : () async {
                  try {
                    await onApproved();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("approve_success".tr()),
                          backgroundColor: Colors.green,
                        )
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${"error".tr()} ${e.toString()}'),
                          backgroundColor: Colors.red,
                        )
                    );
                  }
                },
                child: Text(
                  data['isApproved'] == true
                      ? "approved".tr()
                      : "approve".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: data['isApproved'] == false
                      ? Colors.grey
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                onPressed: data['isApproved'] == false
                    ? null
                    : () async {
                  try {
                    await onRejected();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("rejection_successful".tr()),
                        backgroundColor: Colors.green,
                      )
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${"error".tr()} ${e.toString()}'),
                          backgroundColor: Colors.red,
                        )
                    );
                  }
                },
                child: Text(
                  data['isApproved'] == false
                      ? "reject_success".tr()
                      : "reject".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;
  final String label;
  const _ImageCard({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Expanded(
              child: imageUrl == null
                  ? Container(
                color: AppColors.peach.withAlpha((0.1 * 255).round()),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.deepOcean.withAlpha((0.5 * 255).round()),
                  ),
                ),
              )
                  : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Container(
              color: AppColors.peach.withAlpha((0.2 * 255).round()),
              padding: const EdgeInsets.all(8),
              child: Text(
                label,
                style: TextStyle(color: AppColors.deepOcean),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
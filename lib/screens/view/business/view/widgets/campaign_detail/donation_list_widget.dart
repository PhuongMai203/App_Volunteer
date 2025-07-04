import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../admin/sub_pages/upcoming_sub/campaign_utils.dart';
import '../../../utli/export_util.dart';
import '../../../utli/donation_export_excel.dart';

class DonationListWidget extends StatelessWidget {
  final String campaignId;

  const DonationListWidget({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('campaignId', isEqualTo: campaignId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text( "errorLoadingData".tr()));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(child: Text("no_contributions_yet".tr()));
        }

        // Gộp các khoản đóng góp theo userName
        final Map<String, double> donationMap = {};

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String userName = data['userName'] ?? "anonymous".tr();
          final amount = data['amount'];

          double parsedAmount = 0;
          if (amount is int) {
            parsedAmount = amount.toDouble();
          } else if (amount is double) {
            parsedAmount = amount;
          }

          donationMap.update(userName, (value) => value + parsedAmount,
              ifAbsent: () => parsedAmount);
        }

        final donationList = donationMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)); // Sắp xếp giảm dần theo số tiền

        return Column( // Dòng 58: Đây là Column cần chiều cao giới hạn từ cha
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // đẩy nút sang bên phải
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      DonationExporter.exportToExcel(context, campaignId);
                    },
                    icon: const Icon(Icons.download),
                    label: Text("exportExcel".tr()),
                  ),
                ],
              ),
            ),
            Expanded( // Widget này sẽ mở rộng để lấp đầy không gian còn lại
              child: ListView.separated(
                itemCount: donationList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final entry = donationList[index];
                  final userName = entry.key;
                  final amount = entry.value;

                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      CampaignUtils.formatDonation(amount),
                      style: const TextStyle(color: Color(0xFF006D77), fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      },
    );
  }
}

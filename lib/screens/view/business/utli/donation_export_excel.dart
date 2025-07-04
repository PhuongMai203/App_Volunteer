import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class DonationExporter {
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  static Future<void> exportToExcel(BuildContext context, String campaignId) async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text( "save_the_file".tr())),
        );
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('campaignId', isEqualTo: campaignId)
          .orderBy('createdAt', descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text( tr('noDataToExport'))),
        );
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel["DonationList".tr()];
      sheet.appendRow([
        TextCellValue(tr('index')),
        TextCellValue(tr('name')),
        TextCellValue("donation_amount".tr()),
        TextCellValue("DonationDay".tr()),
      ]);

      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data() as Map<String, dynamic>;
        final String userName = data['userName'] ??  "anonymous".tr();
        final amount = data['amount'] ?? 0;
        final Timestamp? createdAtTimestamp = data['createdAt'];
        String dateStr = '';
        if (createdAtTimestamp != null) {
          final dt = createdAtTimestamp.toDate();
          dateStr = "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
        }

        double parsedAmount = 0;
        if (amount is int) parsedAmount = amount.toDouble();
        else if (amount is double) parsedAmount = amount;

        sheet.appendRow([
          IntCellValue(i + 1),  // Use IntCellValue for index
          TextCellValue(userName),
          DoubleCellValue(parsedAmount),  // Fixed: Use DoubleCellValue
          TextCellValue(dateStr),
        ]);
      }

      String? newPath;
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        List<String> paths = directory!.path.split("/");
        int androidIndex = paths.indexOf("Android");
        if (androidIndex != -1) {
          newPath = paths.sublist(0, androidIndex).join("/") + "/Download";
        } else {
          newPath = directory.path;
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        newPath = directory.path;
      }

      final filePath = '$newPath/danh_sach_quyen_gop_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final fileBytes = excel.encode();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${"exportSuccess".tr()} $filePath'),
          action: SnackBarAction(
            label: "openFile".tr(),
            onPressed: () => OpenFile.open(filePath),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${"exportError".tr()} $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
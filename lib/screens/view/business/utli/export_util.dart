//XUẤT EXCEL DANH SÁCH TNV THAM GIA TRỰC TIẾP
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ExportUtil {
  // Hàm xin quyền lưu trữ theo chuẩn Android 11+ và iOS
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  // Hàm hiển thị snackbar thành công màu xanh lá chữ trắng
  static void showSuccessSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hàm hiển thị snackbar lỗi màu đỏ chữ trắng
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> exportVolunteerListToExcel(BuildContext context, String campaignId) async {
    try {
      bool hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        SnackBar(content: Text("save_the_file".tr()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: campaignId)
          .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
          .get();

      if (snapshot.docs.isEmpty) {
        showErrorSnackBar(context, tr('noDataToExport'));
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel[tr('sheetVolunteerList')];

      // Cập nhật tiêu đề cột
      sheet.appendRow([
        TextCellValue(tr('index')),
        TextCellValue(tr('name')),
        TextCellValue(tr('phone')),
        TextCellValue(tr('email')),
        TextCellValue(tr('birthYear')),
        TextCellValue(tr('location')),
        TextCellValue(tr('attendanceStatus')),
      ]);

      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();

        sheet.appendRow([
          TextCellValue('${i + 1}'),
          TextCellValue(data['name'] ?? ''),
          TextCellValue(data['phone'] ?? ''),
          TextCellValue(data['email'] ?? ''),
          TextCellValue(data['birthYear']?.toString() ?? ''),
          TextCellValue(data['location'] ?? ''),
          TextCellValue(data['attendanceStatus'] ?? tr('notCheckedIn')),
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

      final filePath = '$newPath/danhsach_tnv_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final fileBytes = excel.encode();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      showSuccessSnackBar(
        context,
        '${tr('exportSuccess')}: $filePath',
        action: SnackBarAction(
          label: tr('openFile'),
          textColor: Colors.white,
          onPressed: () {
            OpenFile.open(filePath);
          },
        ),
      );
    } catch (e) {
      showErrorSnackBar(context, '${tr('exportError')}: $e');
    }
  }

}

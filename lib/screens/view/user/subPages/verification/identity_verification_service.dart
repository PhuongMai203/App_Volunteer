// lib/services/identity_verification_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:http/http.dart' as http;

class IdentityVerificationService {
  /// Hàm OCR gọi Google Vision API
  static  Future<String?> performOCR(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=AIzaSyBrJGuKZS4ciXiyYRSKt8Ycg_wSHShbjQg'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [{'type': 'TEXT_DETECTION'}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responses'][0]['fullTextAnnotation']?['text'] ?? '';
      } else {
        print('OCR failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('OCR error: $e');
      return null;
    }
  }

  /// Hàm trích xuất các trường từ văn bản CCCD
  static Map<String, String?> parseFrontIdCardText(String text) {
    final lines = text.split('\n').map((e) => e.trim()).toList();

    String? number;
    String? name;
    String? dob;
    String? address;
    String? gender;

    final numberReg = RegExp(r'(số|no)[\s:.]*([\dA-Z]+)', caseSensitive: false);
    final nameReg = RegExp(r'(họ\s?và\s?tên|ho\s?ten|name)[\s:/]*$', caseSensitive: false, unicode: true);
    final dobReg = RegExp(
      r'(ngày\s?sinh|dob|birth)[\s:.]*([0-3]?\d[\/\-.][0-1]?\d[\/\-.](?:19|20)\d{2})',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lowerLine = removeDiacritics(line).toLowerCase();

      if (number == null) {
        final m = numberReg.firstMatch(line);
        if (m != null) {
          number = m.group(2)?.trim();
          print('✅ Số CCCD: $number');
          continue;
        }
      }

      if (name == null) {
        final nameMatch = nameReg.firstMatch(removeDiacritics(line).toLowerCase());
        if (nameMatch != null && i + 1 < lines.length) {
          name = lines[i + 1].trim();
          print('✅ Họ tên: $name');
          continue;
        }
      }

      if (dob == null) {
        final m = dobReg.firstMatch(line);
        if (m != null) {
          dob = m.group(2)?.trim();
          print('✅ Ngày sinh: $dob');
          continue;
        }
      }

      if (gender == null && (lowerLine.contains('gioi tinh') || lowerLine.contains('sex'))) {
        final m = RegExp(r'(nam|nữ)', caseSensitive: false).firstMatch(line);
        if (m != null) {
          gender = m.group(0)?.trim();
          print('✅ Giới tính: $gender');
        }
      }

      if (address == null && (lowerLine.contains('noi thuong tru') || lowerLine.contains('dia chi') || lowerLine.contains('place of residence'))) {
        String part1 = line.split(':').length > 1 ? line.split(':')[1].trim() : '';
        String part2 = (i + 1 < lines.length) ? lines[i + 1].trim() : '';
        address = '$part1 ${part2}'.trim();
        print('✅ Địa chỉ: $address');
      }

      // Debug log từng dòng
      print('🔍 Dòng ${i + 1}: "$line"');
    }

    return {
      'number': number,
      'name': name,
      'dob': dob,
      'address': address,
      'gender': gender,
    };
  }


}

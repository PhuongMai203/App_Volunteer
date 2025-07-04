import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_similarity/string_similarity.dart';
import 'identity_verification_service.dart';
import 'verifyFace.dart';

class IdentityVerificationController {
  final formKey = GlobalKey<FormState>();
  String? fullName, idNumber;
  File? idCardImage, selfieImage, idCardBackImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(BuildContext context, Function(File) onImagePicked) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Chụp ảnh'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Chọn từ thư viện'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        final file = File(picked.path);
        onImagePicked(file);
      }
    }
  }

  String normalizeString(String input) {
    return removeDiacritics(input)
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String? extractGenderFromText(String ocrText) {
    final lines = ocrText.split('\n');
    for (String line in lines) {
      String normalizedLine = removeDiacritics(line).toLowerCase();
      if (normalizedLine.contains('gioi tinh') || normalizedLine.contains('sex')) {
        // Ví dụ: "Giới tính / Sex: Nữ"
        final parts = line.split(RegExp(r'[:/]', caseSensitive: false));
        if (parts.length >= 2) {
          String rawGender = parts.last.trim().toLowerCase();
          if (rawGender.contains("nam")) return "Nam";
          if (rawGender.contains("nu")) return "Nữ";
        }
      }
    }
    return null;
  }

  Future<void> submitVerification(BuildContext context) async {
    if (!formKey.currentState!.validate() || idCardImage == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng điền đầy đủ thông tin và chọn ảnh.')));
      return;
    }

    formKey.currentState!.save();

    final extractedText = await IdentityVerificationService.performOCR(idCardImage!);
    if (extractedText == null || extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể trích xuất thông tin từ CCCD. Hãy thử lại.")));
      return;
    }
    final ocrLines = extractedText.split('\n');
    final parsedFields = IdentityVerificationService.parseFrontIdCardText(extractedText);
    String? fullAddress;
    int? residenceIndex;
    for (int i = 0; i < ocrLines.length; i++) {
      final normalizedLine = normalizeString(ocrLines[i]);
      if (normalizedLine.contains('noithuongtru') || normalizedLine.contains('placeofresidence')) {
        residenceIndex = i;
        break;
      }
    }

    if (residenceIndex != null) {
      final addressLine1Index = residenceIndex + 1;
      if (addressLine1Index < ocrLines.length) {
        final addressPart1 = ocrLines[addressLine1Index].trim();
        final addressLine2Index = addressLine1Index + 1;
        if (addressLine2Index < ocrLines.length) {
          final addressPart2 = ocrLines[addressLine2Index].trim();
          fullAddress = '$addressPart1 $addressPart2';
        } else {
          fullAddress = addressPart1;
        }
      }
    }
    if (fullAddress == null || fullAddress.isEmpty) {
      fullAddress = parsedFields['address'] ?? '';
    }

    final normalizedFullName = normalizeString(fullName!);
    final normalizedIdNumber = normalizeString(idNumber!);
    final normalizedOcrLines = ocrLines.map((line) => normalizeString(line)).toList();

    double bestNameScore = 0, bestIdScore = 0;
    for (String line in normalizedOcrLines) {
      bestNameScore = bestNameScore > StringSimilarity.compareTwoStrings(line, normalizedFullName)
          ? bestNameScore
          : StringSimilarity.compareTwoStrings(line, normalizedFullName);
      bestIdScore = bestIdScore > StringSimilarity.compareTwoStrings(line, normalizedIdNumber)
          ? bestIdScore
          : StringSimilarity.compareTwoStrings(line, normalizedIdNumber);
    }

    const threshold = 0.7;
    if (bestNameScore < threshold || bestIdScore < threshold) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thông tin không khớp với CCCD. Vui lòng kiểm tra lại.")));
      return;
    }

    double? similarity = await verifyFaceBackend(idCardImage!, selfieImage!);
    if (similarity == null || similarity < 0.6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Xác minh khuôn mặt thất bại hoặc không đủ giống (Độ tương đồng: ${(similarity ?? 0) * 100}%)")));
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final storage = FirebaseStorage.instance;
    final idCardUrl = await _uploadFile(storage, userId, 'id_card.jpg', idCardImage!);
    final selfieUrl = await _uploadFile(storage, userId, 'selfie.jpg', selfieImage!);
    String? idCardBackUrl = idCardBackImage != null
        ? await _uploadFile(storage, userId, 'id_card_back.jpg', idCardBackImage!)
        : null;

    final usersRef = FirebaseFirestore.instance.collection('users').doc(userId);
    int? birthYear;
    if (parsedFields['dob'] != null) {
      final dobParts = (parsedFields['dob'] as String).split(RegExp(r'[/-]'));
      if (dobParts.length == 3) {
        birthYear = int.tryParse(dobParts[2]);
      }
    }

    await usersRef.set({
      if (birthYear != null) 'birthYear': birthYear,
      'fullName': fullName,
      'address': fullAddress,
      'idCardUrl': idCardUrl,
      'selfieUrl': selfieUrl,
      if (idCardBackUrl != null) 'idCardBackUrl': idCardBackUrl,
      if (parsedFields['gender'] != null) 'gender': parsedFields['gender'],
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar
      (content:
    Text("Xác minh thành công! Vui lòng chờ xét duyệt.",
      style: const TextStyle(color: Colors.white),) ,backgroundColor: Colors.green,));
    Navigator.pop(context);
  }

  Future<String> _uploadFile(FirebaseStorage storage, String userId, String filename, File file) async {
    final ref = storage.ref('verifications/$userId/$filename');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
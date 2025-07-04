import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignEditController {
  static Future<void> updateCampaignInfo({
    required String docId,
    required String title,
    required String address,
    required String phoneNumber,
    required String supportType,
    required String urgency,
    required String bankName,
    required String bankAccount,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    required int maxVolunteerCount,
    required String description,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('featured_activities').doc(docId);
       try {
      await docRef.update({
        'title': title.trim(),
        'address': address.trim(),
        'phoneNumber': phoneNumber.trim(),
        'supportType': supportType,
        'urgency': urgency,
        'bankName': bankName,
        'bankAccount': bankAccount.trim(),
        'category': category,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'maxVolunteerCount': maxVolunteerCount,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  static Future<void> deleteCampaign({required String docId}) async {
    try {
      await FirebaseFirestore.instance.collection('featured_activities').doc(docId).delete();
    } catch (e) {
      throw Exception("Không thể xóa chiến dịch: $e");
    }
  }
}

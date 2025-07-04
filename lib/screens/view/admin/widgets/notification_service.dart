// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendNotification({
    required String userId,
    required String message,
    required String relatedId,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'message': message,
        'type': type,
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy tổng số tiền đã ủng hộ của user hiện tại
  Future<int> getTotalDonatedAmount(String uid) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final querySnapshot = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .get();

    int totalAmount = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final amount = data['amount'];
      if (amount is int) {
        totalAmount += amount;
      } else if (amount is double) {
        totalAmount += amount.toInt();
      }
    }

    return totalAmount;
  }
}

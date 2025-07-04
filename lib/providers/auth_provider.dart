import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getUserRoleFromFirestore(String uid) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data();
      return userData?['role'] ?? 'user'; // Lấy role từ Firestore
    } else {
      return 'user'; // Mặc định nếu không có role
    }
  } catch (e) {
    // Nếu có lỗi trong quá trình truy vấn Firestore
    print('Error getting user role: $e');
    return 'user'; // Mặc định nếu có lỗi
  }
}

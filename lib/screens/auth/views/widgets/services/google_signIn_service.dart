import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static Future<UserCredential?> signInWithGoogle({String userType = 'volunteer'}) async {
    try {
      // Bước 1: Mở cửa sổ chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Người dùng huỷ

      // Bước 2: Lấy token xác thực
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Bước 3: Tạo credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Bước 4: Đăng nhập với Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Bước 5: Ghi thông tin người dùng lên Firestore nếu chưa tồn tại
      final user = userCredential.user;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          await docRef.set({
            'email': user.email,
            'name': user.displayName ?? '',
            'password': 'google_oauth',
            'role': 'user',
            'createdAt': Timestamp.now(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }
}

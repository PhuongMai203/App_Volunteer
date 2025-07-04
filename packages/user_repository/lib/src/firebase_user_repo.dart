import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../user_repository.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if (firebaseUser == null) {
        yield MyUser.empty;
      } else {
        final doc = await usersCollection.doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          yield MyUser.fromEntity(MyUserEntity.fromDocument(doc.data()!));
        } else {
          yield MyUser.empty;
        }
      }
    });
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);

      // Tạo user mới với đầy đủ trường thống kê
      final newUser = myUser.copyWith(
        userId: user.user!.uid,
        donationCount: 0,
        campaignCount: 0,
        createdRequests: 0,
        joinedEvents: [],
        registeredEvents: [],
        avatarUrl: '',
        hasActiveCart: false,
        isApproved: myUser.role == 'organization' ? false : true,
      );

      // Lưu vào Firestore với giá trị mặc định
      await setUserData(newUser);

      return newUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection.doc(myUser.userId).set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ✅ Cải thiện xử lý lỗi khi gửi OTP đặt lại mật khẩu
  Future<void> sendPasswordResetOTP(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      log("Password reset email sent to $email");
    } catch (e) {
      log("Failed to send reset password email: ${e.toString()}");
      rethrow;
    }
  }
  // Thêm vào class FirebaseUserRepo
  Future<void> updateUserImage({
    required String userId,
    required String imageUrl,
    required bool isAvatar,
  }) async {
    try {
      await usersCollection.doc(userId).update({
        isAvatar ? 'avatar' : 'coverPhoto': imageUrl,
      });
    } catch (e) {
      log('Error updating user image: $e');
      rethrow;
    }
  }

}

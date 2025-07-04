import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  // Tài khoản admin cứng
  final Map<String, String> hardcodedAdmins = {
    'admin1@gmail.com': 'Btpmai2003@',
    'admin2@gmail.com': 'Btpmai2003@',
  };

  SignInBloc(this._userRepository) : super(const SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(const SignInProcess());

      final email = event.email.trim();
      final password = event.password.trim();

      try {
        User? firebaseUser;
        String role = 'user'; // role mặc định

        // 1. Đăng nhập admin cứng
        if (hardcodedAdmins[email] == password) {
          final cred = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          firebaseUser = cred.user;
          role = 'admin';
        } else {
          // 2. Đăng nhập thường qua repository
          firebaseUser = await _userRepository.signIn(email, password);
        }

        if (firebaseUser == null) {
          emit(SignInFailure(errorMessage: 'sign_in_failed'.tr()));
          return;
        }

        // 3. Lấy thông tin user từ Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) {
          // Người dùng chưa có thông tin Firestore (Google/Facebook mới đăng nhập)
          emit(SignInSuccess(user: firebaseUser, userRole: role));
          return;
        }

        final data = doc.data()!;
        final bool isApproved = data['isApproved'] as bool? ?? true;

        if (!isApproved) {
          await _userRepository.logOut();
          emit(SignInFailure(errorMessage: 'account_pending_approval'.tr()));
          return;
        }

        // Cập nhật role nếu có trên Firestore
        role = data['role'] ?? role;

        emit(SignInSuccess(user: firebaseUser, userRole: role));
      } on FirebaseAuthException catch (e) {
        // Xử lý các lỗi từ Firebase
        if (e.code == 'user-not-found') {
          emit(SignInFailure(
            emailError: 'email_not_found'.tr(),
            errorMessage: 'user_not_found_or_wrong_password'.tr(),
          ));
        } else if (e.code == 'wrong-password') {
          emit(SignInFailure(
            passwordError: 'wrong_password'.tr(),
            errorMessage: 'user_not_found_or_wrong_password'.tr(),
          ));
        } else if (e.code == 'invalid-email') {
          emit(SignInFailure(
            emailError: 'email_invalid_format'.tr(),
            errorMessage: 'invalid_email_format'.tr(),
          ));
        } else if (e.code == 'too-many-requests') {
          emit(SignInFailure(
            errorMessage: 'too_many_attempts_try_later'.tr(),
          ));
        } else if (e.code == 'invalid-credential' || e.code == 'auth/invalid-credential') {
          emit(SignInFailure(
            errorMessage: 'invalid_credential_error'.tr(),
          ));
        } else {
          emit(SignInFailure(errorMessage: 'firebase_auth_error_general'.tr(args: [e.code])));
        }
      } catch (e) {
        emit(SignInFailure(errorMessage: 'general_error_occurred'.tr(args: [e.toString()])));
      }
    });

    on<SignOutRequired>((event, emit) async {
      await _userRepository.logOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedOut', true);
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('userType'); // nếu bạn có dùng key này
    });
  }
}

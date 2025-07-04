import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;

  SignUpBloc(this._userRepository) : super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async {
      try {
        emit(SignUpProcess());

        // Đăng ký tài khoản
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: event.user.email,
          password: event.password,
        );

        final uid = userCredential.user?.uid;
        if (uid != null) {
          // Lưu thông tin vào Firestore với role
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': event.user.name,
            'email': event.user.email,
            'role': event.user.role ?? 'user', // Lưu role 'organization' hoặc mặc định là 'user'
            'isApproved': event.user.role == 'organization'
                ? false   // tổ chức mặc định chưa được duyệt
                : true,   // user thường auto approved
            'rank': event.user.rank ?? 'Đồng', // Thêm trường rank
          });

          // Đăng xuất sau khi đăng ký
          await FirebaseAuth.instance.signOut();

          // Tạo bản sao user có thêm userId
          final newUser = event.user.copyWith(
            userId: uid,
            rank: event.user.rank ?? 'Đồng', // Đảm bảo rank được truyền vào
          );

          // Emit thành công với user mới
          emit(SignUpSuccess(user: newUser));
        }
      } catch (e) {
        emit(SignUpFailure(e.toString()));
      }
    });
  }
}

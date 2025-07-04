part of 'sign_in_bloc.dart'; // Đảm bảo đúng part file của bạn

sealed class SignInState extends Equatable {
  /// userRole để downstream biết là 'admin' / 'user'
  const SignInState(this.userRole);
  final String userRole;

  @override
  List<Object?> get props => [userRole];
}

/// Ban đầu chưa sign in → không cần role
final class SignInInitial extends SignInState {
  const SignInInitial() : super('');
}

/// Khi đang xử lý → không cần role
final class SignInProcess extends SignInState {
  const SignInProcess() : super('');
}

/// Sign in thành công, trả về Firebase [user] và [userRole]
final class SignInSuccess extends SignInState {
  final User user;
  const SignInSuccess({
    required this.user,
    required String userRole,
  }) : super(userRole);

  @override
  List<Object?> get props => [user.uid, userRole];
}

/// Sign in lỗi, trả về [message]
final class SignInFailure extends SignInState {
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;

  // Cập nhật constructor để truyền userRole cho lớp cha
  const SignInFailure({this.errorMessage, this.emailError, this.passwordError}) : super('');

  @override
  List<Object> get props => [errorMessage ?? '', emailError ?? '', passwordError ?? ''];
}

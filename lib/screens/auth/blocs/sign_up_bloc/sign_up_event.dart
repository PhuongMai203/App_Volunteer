part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequired extends SignUpEvent {
  final MyUser user;
  final String password;
  final String userType;
  const SignUpRequired(this.user, this.password, this.userType);

  @override
  List<Object> get props => [user, password,  userType];
}
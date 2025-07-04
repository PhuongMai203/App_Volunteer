part of 'sign_up_bloc.dart';

class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final MyUser user;

  const SignUpSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class SignUpProcess extends SignUpState {}

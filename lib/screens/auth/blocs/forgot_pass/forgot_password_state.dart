part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordLinkSent extends ForgotPasswordState {
  final String email;

  ForgotPasswordLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  ForgotPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}

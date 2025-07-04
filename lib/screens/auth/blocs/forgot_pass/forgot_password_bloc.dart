import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());

    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      emit(ForgotPasswordLinkSent(event.email));
    } catch (e) {
      emit(ForgotPasswordFailure("Lỗi: ${e.toString()}"));
    }
  }
}

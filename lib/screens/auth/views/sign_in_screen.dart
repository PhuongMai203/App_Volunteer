import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_connect/screens/auth/views/widgets/auth_service.dart';
import 'package:help_connect/screens/auth/views/widgets/sign_in_form.dart';
import '../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatelessWidget {
  final String? userType;
  const SignInScreen({super.key, this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true, // Cho phép cuộn khi bàn phím bật
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26.0, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/first'),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/asd.png'),
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double formWidth = screenWidth * 0.85;
                if (formWidth > 500) formWidth = 500;

                double formPadding = screenWidth < 400 ? 16 : 24;
                double borderRadius = screenWidth < 400 ? 10 : 12;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Trừ phần bàn phím
                    top: 60,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 60,
                    ),
                    child: Center(
                      child: Container(
                        width: formWidth,
                        padding: EdgeInsets.all(formPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: BlocListener<SignInBloc, SignInState>(
                          listener: (context, state) {
                            if (state is SignInSuccess) {
                              AuthService.handleAuthState(
                                context: context,
                                state: state,
                                userType: userType,
                              );
                            } else if (state is SignInFailure) {
                              AuthService.handleAuthState(
                                context: context,
                                state: state,
                                userType: null,
                              );
                            }
                          },
                          child: SignInForm(userType: userType),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

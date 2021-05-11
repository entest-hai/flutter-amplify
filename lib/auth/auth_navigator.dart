import 'auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amplify/auth/signup/signup_view.dart';
import 'package:flutter_amplify/auth/login/login_view.dart';
import 'package:flutter_amplify/auth/confirm/confirmation_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Show login
          if (state == AuthState.login) MaterialPage(child: LoginView()),

          // Allow push animation
          if (state == AuthState.signUp ||
              state == AuthState.confirmSignUp) ...[
            //Show sign up
            MaterialPage(child: SignUpView()),

            // Show confirm sign up
            if (state == AuthState.confirmSignUp)
              MaterialPage(child: ConfirmationView()),
          ]
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
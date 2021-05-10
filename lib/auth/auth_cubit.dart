import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/session_cubit.dart';
import 'package:flutter_amplify/auth/auth_credentials.dart';

enum AuthState { login, signUp, confirmSignUp }

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  final SessionCubit sessionCubit;
  AuthCubit({this.sessionCubit}) : super(AuthState.login);

  AuthCredentials credentials;

  void showLogin() => emit(AuthState.login);

  void showSignUp() => emit(AuthState.signUp);

  void showConfirmSignUp({
    String username,
    String email,
    String password,
  }) {
    // creddentials
    credentials = AuthCredentials(
      username: username,
      email: email,
      password: password,
    );

    emit(AuthState.confirmSignUp);
  }

  void launchSession(AuthCredentials credentials) {
    // Session Cubit show session
    sessionCubit.showSession(credentials);
  }
}
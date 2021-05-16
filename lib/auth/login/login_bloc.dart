import 'login_event.dart';
import 'login_state.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/form_submission_state.dart';
import 'package:flutter_amplify/auth/auth_credentials.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  LoginBloc({this.authRepo, this.authCubit}) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // Username updated
    if (event is LoginUsernameChanged) {
      yield state.copyWith(username: event.username);
    }

    // Password updated
    else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);
    }

    // Sumibtted login form
    else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        // Amplify login
        // print(state.username);

        final userId = await authRepo.login(
            username: state.username, password: state.password);

        print('login in get userid: $userId');

        yield state.copyWith(formStatus: FormSubmissionSuccess());

        // Launch auth session from AuthCubit
        authCubit.launchSession(
            AuthCredentials(username: state.username, userId: userId));

        // Login failed need to sign up first
      } catch (e) {
        yield state.copyWith(formStatus: FormSubmissionFailed(exception: e));
      }
    }

    // Form submitted
  }
}

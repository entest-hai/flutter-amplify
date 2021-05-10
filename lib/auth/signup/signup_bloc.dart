import 'signup_event.dart';
import 'signup_state.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/form_submission_state.dart';



class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  SignUpBloc({this.authRepo, this.authCubit}) : super(SignUpState());

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    // Username changed
    if (event is SignUpUsernameChanged) {
      yield state.copyWidth(username: event.username);
    }

    // Email changed
    else if (event is SignUpEmailChanged) {
      yield state.copyWidth(email: event.email);
    }

    // Password changed
    
    else if (event is SignUpPasswordChanged) {
      yield state.copyWidth(password: event.password);
    }

    // Form submitted
    else if (event is SignUpSubmitted) {
      yield state.copyWidth(formStatus: FormSubmitting());

      // AuthRepository and Amplify sign up
      try {
        // await Amplify sign up
        await authRepo.signUp(
            username: state.username,
            email: state.email,
            password: state.password);

        yield state.copyWidth(formStatus: FormSubmissionSuccess());

        // Show confirmation signup
        authCubit.showConfirmSignUp(
          username: state.username,
          email: state.email,
          password: state.password,
        );
      } catch (e) {
        yield state.copyWidth(formStatus: FormSubmissionFailed(exception: e));
      }
    }
  }
}

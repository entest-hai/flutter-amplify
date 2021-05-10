import 'confirmation_event.dart';
import 'confirmation_state.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/form_submission_state.dart';


class ConfirmationBloc extends Bloc<ConfirmationEvent, ConfirmationState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  ConfirmationBloc({this.authRepo, this.authCubit})
      : super(ConfirmationState());

  @override
  Stream<ConfirmationState> mapEventToState(ConfirmationEvent event) async* {
    // Confirmation code updated
    if (event is ConfirmationCodeChanged) {
      yield state.copyWidth(code: event.code);
    }

    // Form submitted
    else if (event is ConfirmationSubmitted) {
      yield state.copyWidth(formStatus: FormSubmitting());

      try {
        // TODO: AuthRepository to confirm signUp
        await authRepo.confirmSignUp(
            username: authCubit.credentials.username,
            confirmationCode: state.code);

        yield state.copyWidth(formStatus: FormSubmissionSuccess());

        // Setup credential
        final credentials = authCubit.credentials;
        final userId = await authRepo.login(
            username: credentials.username, password: credentials.password);
        credentials.userId = userId;

        // AuthCubit launch session with credential
        authCubit.launchSession(credentials);
      } catch (e) {
        print(e);
        yield state.copyWidth(formStatus: FormSubmissionFailed(exception: e));
      }
    }

    // Confirm SinUp
  }
}

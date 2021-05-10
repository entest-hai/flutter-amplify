import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'confirmation_bloc.dart';
import 'confirmation_state.dart';
import 'confirmation_event.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_amplify/auth/confirm/confirmation_bloc.dart';
import 'package:flutter_amplify/auth/form_submission_state.dart';

class ConfirmationView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ConfirmationBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: _confirmationForm(),
      ),
    );
  }

  Widget _confirmationForm() {
    return BlocListener<ConfirmationBloc, ConfirmationState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is FormSubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _codeField(),
                _confirmButton(),
              ],
            ),
          ),
        ));
  }

  Widget _codeField() {
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Confirmation Code',
        ),
        onChanged: (value) => context.read<ConfirmationBloc>().add(
              ConfirmationCodeChanged(code: value),
            ),
      );
    });
  }

  Widget _confirmButton() {
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  context.read<ConfirmationBloc>().add(ConfirmationSubmitted());
                }
              },
              child: Text('Confirm'),
            );
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
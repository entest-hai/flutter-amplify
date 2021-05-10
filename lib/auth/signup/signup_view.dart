import 'package:flutter/material.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_amplify/auth/signup/signup_bloc.dart';
import 'package:flutter_amplify/auth/signup/signup_event.dart';
import 'package:flutter_amplify/auth/signup/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/form_submission_state.dart';



class SignUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUp"),
      ),
      body: BlocProvider(
        create: (context) => SignUpBloc(
            authRepo: context.read<AuthRepository>(),
            authCubit: context.read<AuthCubit>()),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _signUpForm(),
              _showLoginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signUpForm() {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is FormSubmissionFailed) {
          _showSnacBar(context, formStatus.exception.toString());
        }
      },
      child: Form(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _usernameField(),
              _emailField(),
              _passwordField(),
              _singUpButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration:
            InputDecoration(icon: Icon(Icons.person), hintText: "Username"),
        onChanged: (value) {
          context
              .read<SignUpBloc>()
              .add(SignUpUsernameChanged(username: value));
        },
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration:
            InputDecoration(icon: Icon(Icons.security), hintText: "Password"),
        onChanged: (value) {
          context
              .read<SignUpBloc>()
              .add(SignUpPasswordChanged(password: value));
        },
      );
    });
  }

  Widget _emailField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(icon: Icon(Icons.email), hintText: "Email"),
        onChanged: (value) {
          context.read<SignUpBloc>().add(SignUpEmailChanged(email: value));
        },
      );
    });
  }

  Widget _singUpButton() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                context.read<SignUpBloc>().add(SignUpSubmitted());
              },
              child: Text("Sign Up"),
            );
    });
  }

  Widget _showLoginButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          BlocProvider.of<AuthCubit>(context).showLogin();
        },
        child: Text('Already have an account? Sign in.'));
  }

  void _showSnacBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

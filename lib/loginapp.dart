import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'amplifyconfiguration.dart';

class LoginApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginAppState();
  }
}

class _LoginAppState extends State<LoginApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => AuthRepository()),
            RepositoryProvider(create: (context) => DataRepository()),
          ],
          child: MultiBlocProvider(
            providers: [BlocProvider(create: (context) => AuthCubit())],
            child: AuthNavigator(),
          )),
    );
  }

  // Configure Amplify
  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
      ]);
      await Amplify.configure(amplifyconfig);
      setState(() => _isAmplifyConfigured = true);
      print("Amplify has been configured");
    } catch (e) {
      print(e);
    }
  }
}

// AppNavigator View

// AuthNavigator View
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

// Login View
class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: BlocProvider(
        create: (context) => LoginBloc(
            authRepo: context.read<AuthRepository>(),
            authCubit: context.read<AuthCubit>()),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [_loginForm(), _showSignUpButton(context)],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is FormSubmissionFailed) {
          _showSnackBar(context, formStatus.exception.toString());
        }
      },
      child: Form(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_usernameField(), _passwordField(), _loginButton()],
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: "Username",
      ),
      onChanged: (value) {},
    );
  }

  Widget _passwordField() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        hintText: "Password",
      ),
      onChanged: (value) {},
    );
  }

  Widget _loginButton() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                context.read<LoginBloc>().add(LoginSubmitted());
              },
              child: Text("Login"));
    });
  }

  Widget _showSignUpButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text("Don\'t have an account? Sign up."),
        onPressed: () {
          BlocProvider.of<AuthCubit>(context).showSignUp();
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// Confirmation SignUp View
class ConfirmationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmation"),
      ),
    );
  }
}

// SignUp View
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
    return Form(
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

  Widget _showSnacBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// Sesssion View
class SessionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SessionView"),
      ),
    );
  }
}

// Session State

// Session Cubit

// Auth Credentials
class AuthCredentials {
  final String username;
  final String email;
  final String password;
  String userId;

  AuthCredentials({
    this.username,
    this.email,
    this.password,
    this.userId,
  });
}

// Auth State
enum AuthState { login, signUp, confirmSignUp }

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.login);

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
  }
}

// Login State
abstract class FormSubmissionStatus {
  const FormSubmissionStatus();
}

class InitialFormStatus extends FormSubmissionStatus {
  const InitialFormStatus();
}

class FormSubmitting extends FormSubmissionStatus {}

class FormSubmissionSuccess extends FormSubmissionStatus {}

class FormSubmissionFailed extends FormSubmissionStatus {
  final Exception exception;
  FormSubmissionFailed({this.exception});
}

class LoginState {
  final String username;
  final String password;
  final FormSubmissionStatus formStatus;

  LoginState({
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  LoginState copyWith({
    String username,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
        formStatus: formStatus ?? this.formStatus);
  }
}

// Login Event
abstract class LoginEvent {}

class LoginUsernameChanged extends LoginEvent {
  final String username;
  LoginUsernameChanged({this.username});
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged({this.password});
}

class LoginSubmitted extends LoginEvent {}

// Login Bloc
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
        final userId = await authRepo.login(state.username, state.password);
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

// SignUp Event
abstract class SignUpEvent {}

class SignUpUsernameChanged extends SignUpEvent {
  final String username;
  SignUpUsernameChanged({this.username});
}

class SignUpPasswordChanged extends SignUpEvent {
  final password;
  SignUpPasswordChanged({this.password});
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  SignUpEmailChanged({this.email});
}

class SignUpSubmitted extends SignUpEvent {}

// SignUp State
class SignUpState {
  final String username;
  final String email;
  final String password;
  final FormSubmissionStatus formStatus;

  SignUpState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  SignUpState copyWidth({
    String username,
    String email,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return SignUpState(
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        formStatus: formStatus ?? this.formStatus);
  }
}

// SignUp Bloc
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

    // Password changed
    else if (event is SignUpEmailChanged) {
      yield state.copyWidth(email: event.email);
    }

    // Form submitted
    else if (event is SignUpSubmitted) {
      yield state.copyWidth(formStatus: FormSubmitting());

      // AuthRepository and Amplify sign up
      try {
        // await Amplify sign up
        await authRepo.signUp(state.username, state.email, state.password);

        yield state.copyWidth(formStatus: FormSubmissionSuccess());

        // Show confirmation signup
        authCubit.showConfirmSignUp(
          username: state.username,
          email: state.email,
          password: state.password,
        );
      } catch (e) {
        yield state.copyWidth(formStatus: FormSubmissionFailed());
      }
    }
  }
}

// Auth Repository
class AuthRepository {
  Future<String> login(String username, String password) async {
    await Future.delayed(Duration(seconds: 3));

    throw Exception("Do not have an account yet, please sign up.");
    // return 'abc';
  }

  Future<void> signUp(String username, String email, String password) async {
    await Future.delayed(Duration(seconds: 3));
  }
}

// Data Repository
class DataRepository {}

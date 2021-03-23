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
        home: _isAmplifyConfigured
            ? MultiRepositoryProvider(
                providers: [
                    RepositoryProvider(create: (context) => AuthRepository()),
                    RepositoryProvider(create: (context) => DataRepository()),
                  ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => SessionCubit(
                            authRepo: context.read<AuthRepository>()))
                  ],
                  child: AppNavigator(),
                ))
            : LoadingView());
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
class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Show loading screen
          if (state is UnknownSessionState) MaterialPage(child: LoadingView()),

          // Show auth flow
          if (state is Unauthenticated)
            MaterialPage(
                child: BlocProvider(
              create: (context) =>
                  AuthCubit(sessionCubit: context.read<SessionCubit>()),
              child: AuthNavigator(),
            )),

          // Show session flow
          if (state is Authenticated)
            MaterialPage(
                child: SessionView(
              username: state.user,
            ))
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}

// Loading View
class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

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
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: "Username",
        ),
        onChanged: (value) {
          context.read<LoginBloc>().add(LoginUsernameChanged(username: value));
        },
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: "Password",
        ),
        onChanged: (value) {
          context.read<LoginBloc>().add(LoginPasswordChanged(password: value));
        },
      );
    });
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

// Sesssion View
class SessionView extends StatelessWidget {
  final String username;

  SessionView({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello $username'),
            TextButton(
              child: Text('sign out'),
              onPressed: () => BlocProvider.of<SessionCubit>(context).signOut(),
            )
          ],
        ),
      ),
    );
  }
}

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
        print(state.username);

        final userId = await authRepo.login(
            username: state.username, password: state.password);

        print(userId);

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

// Auth Repository
class AuthRepository {
  Future<String> _getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final userId = attributes
          .firstWhere((element) => element.userAttributeKey == 'sub')
          .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }

  Future<String> attemptAutoLogin() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      return session.isSignedIn ? (await _getUserIdFromAttributes()) : null;
    } catch (e) {
      throw e;
    }
  }

  Future<String> login({
    @required String username,
    @required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username.trim(),
        password: password.trim(),
      );

      return result.isSignedIn ? (await _getUserIdFromAttributes()) : null;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> signUp({
    @required String username,
    @required String email,
    @required String password,
  }) async {
    final options =
        CognitoSignUpOptions(userAttributes: {'email': email.trim()});
    try {
      final result = await Amplify.Auth.signUp(
        username: username.trim(),
        password: password.trim(),
        options: options,
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> confirmSignUp({
    @required String username,
    @required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username.trim(),
        confirmationCode: confirmationCode.trim(),
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }
}

// Data Repository
class DataRepository {}

// Confirmation State
class ConfirmationState {
  final String code;
  final FormSubmissionStatus formStatus;

  ConfirmationState({
    this.code = '',
    this.formStatus = const InitialFormStatus(),
  });

  ConfirmationState copyWidth({
    String code,
    FormSubmissionStatus formStatus,
  }) {
    return ConfirmationState(
      code: code ?? this.code,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}

// Confirmation Event
abstract class ConfirmationEvent {}

class ConfirmationCodeChanged extends ConfirmationEvent {
  final String code;
  ConfirmationCodeChanged({this.code});
}

class ConfirmationSubmitted extends ConfirmationEvent {}

// Confirmation Bloc
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

// Session Cubit
class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;

  SessionCubit({this.authRepo}) : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userId = await authRepo.attemptAutoLogin();
      // final user = dataRepo.getUser(userId);
      final user = userId;
      emit(Authenticated(user: user));
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession(AuthCredentials credentials) {
    // final user = dataRepo.getUser(credentials.userId);
    final user = credentials.username;
    emit(Authenticated(user: user));
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}

// Session State
abstract class SessionState {}

class UnknownSessionState extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  final dynamic user;

  Authenticated({@required this.user});
}

import 'loading_view.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../amplifyconfiguration.dart';

import 'auth_cubit.dart';
import 'auth_repository.dart';
import 'data_repository.dart';
import 'session_cubit.dart';
import 'session_state.dart';
import 'session_view.dart';
import 'auth_navigator.dart';

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
                    RepositoryProvider(create: (context) => UserCTGRepository())
                  ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (context) => SessionCubit(
                            authRepo: context.read<AuthRepository>(),
                            dataPepo: context.read<DataRepository>()))
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
              user: state.user,
            ))
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
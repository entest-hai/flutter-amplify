import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';
import 'package:flutter_amplify/profile/storage_repository.dart';
// Generated in previous step
import 'amplifyconfiguration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 's3.dart';
// Todo DB App
import 'todo_view.dart';
import 'todo_cubit.dart';
// SQI and S3 App
import 'sqi_cubit.dart';
import 'sqi_view.dart';
// CTG Batch App
import 'ctg_cubit.dart';
import 'ctg_view.dart';
// CTG Each Minute App
import 'ctg_realtime_cubit.dart';
import 'ctg_realtime_view.dart';
// Annotation
import 'annotation_app.dart';
// Historical CTG
import 'user_historical_app.dart';
// S3 App 
import 's3/s3_list_files_app.dart';
// S3 image view app
import 's3/s3_image_view.dart';
// AppSyncApp
import 'package:flutter_amplify/appsync/appsync_cubit.dart';
import 'package:flutter_amplify/appsync/appsync_item_cubit.dart';
import 'appsync/appsync_app.dart';
// AppSyncSearch
import 'appsync/app_sync_search.dart';
// Auth 
import 'package:flutter_amplify/auth/auth_cubit.dart';
import 'package:flutter_amplify/auth/session_cubit.dart';
import 'package:flutter_amplify/auth/session_state.dart';
import 'package:flutter_amplify/auth/loading_view.dart';
import 'package:flutter_amplify/auth/auth_navigator.dart';
import 'package:flutter_amplify/auth/session_view.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/data_repository.dart';
// Profile 
import 'package:flutter_amplify/profile/profile_view.dart';
import 'package:flutter_amplify/profile/profile_bloc.dart';
// 

void main() {
  // runApp(MyApp());
  runApp(CTGApp());
  // runApp(AnnotationApp());
  // runApp(HistoricalCTGApp());
  // runApp(S3App());
  // runApp(S3PhotoViewApp());
  // runApp(AppSyncApp());
  // runApp(AppSyncSearch());

}

class CTGApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CTGAppState();
  }
}

class _CTGAppState extends State<CTGApp> {
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
                    RepositoryProvider(create: (context) => StorageRepository())
                  ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => AppSyncCTGCubit()),
                    BlocProvider(create: (context) => AppSyncItemCubit()),
                    BlocProvider(
                        create: (context) => SessionCubit(
                            authRepo: context.read<AuthRepository>(),
                            dataPepo: context.read<DataRepository>()
                            )
                            ),
                  ],
                  child: AppNavigator(),
                )
                )
            : LoadingView()
            );
  }

  // Configure Amplify
  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
        AmplifyStorageS3()
      ]);
      await Amplify.configure(amplifyconfig);
      setState(() => _isAmplifyConfigured = true);
      print("Amplify has been configured");
    } catch (e) {
      print(e);
    }
  }
}

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
                child: MultiBlocProvider(
                  providers: [
                     BlocProvider(create: (context) => ProfileBloc(
                       dataRepo: context.read<DataRepository>(),
                       storageRepo: context.read<StorageRepository>(),
                       user: state.user,
                       isCurrentUser: false)),
                  ],
                  child: CTGAppSessionView(user: state.user,),
                  // child: SessionView(user: state.user,)
                // child: AppSyncNav()
                  )
                )
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}


class CTGAppSessionView extends StatefulWidget {
  final User user;
  CTGAppSessionView({this.user}); 
  @override
  State<StatefulWidget> createState() {
    return _CTGAppTabState();
  }
}


class _CTGAppTabState extends State<CTGAppSessionView> {
  var _currentIndex = 0;
  var _tabs = []; 
  
  @override
  void initState() {
    super.initState();
    _tabs = [
      SessionView(user: widget.user),
      AppSyncNav(),
      UserProfileView(),
  ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: "Login",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Setting",
            backgroundColor: Colors.blue
          )
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
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
// Login
import 'auth/loginapp.dart';
// Annotation
import 'annotation_app.dart';
// Historical CTG
import 'user_historical_app.dart';
// S3 App 
import 's3/s3_list_files_app.dart';
// S3 image view app
import 's3/s3_image_view.dart';
// AppSyncApp
import 'appsync/appsync_app.dart';
// AppSyncSearch
import 'appsync/app_sync_search.dart';

void main() {
  // runApp(MyApp());
  runApp(LoginApp());
  // runApp(AnnotationApp());
  // runApp(HistoricalCTGApp());
  // runApp(S3App());
  // runApp(S3PhotoViewApp());
  // runApp(AppSyncApp());
  // runApp(AppSyncSearch());

}


class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(providers: [
      BlocProvider(create: (context) => UploadCubit()..listFiles()),
      BlocProvider(
        create: (context) => CTGCubit(),
      ),
      BlocProvider(
        create: (context) => HeartRateCubit()..loadHeartRateFromFile(),
      ),
      BlocProvider(create: (context) => S3Cubit()..listCsvFiles()),
      BlocProvider(create: (context) => TodoCubit()..subscribeTodo()),
      BlocProvider(create: (context) => BeatCubit()..fetchBeat()),
    ], child: _amplifyConfigured ? CTGNavTab() : CTGNavTab()));
  }

  void _configureAmplify() async {
    if (!mounted) return;
    try {
      Amplify.addPlugins(
          [AmplifyAuthCognito(), AmplifyStorageS3(), AmplifyAPI()]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class CTGNavTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CTGNavTabState();
  }
}

class _CTGNavTabState extends State<CTGNavTab> {
  int _currentIndex = 0;
  final tabs = [
    Center(
      child: SQIAppView(),
    ),
    Center(
      child: CTGAppOnly(),
    ),
    TodoDBView(),
    Center(
      child: BeatView(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
            child: Scaffold(
          appBar: AppBar(title: Text("Amplify")),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "SQI",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: "CTG",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.data_usage),
                  label: "DB",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Setting",
                  backgroundColor: Colors.blue)
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body: tabs[_currentIndex],
        ))
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }
}

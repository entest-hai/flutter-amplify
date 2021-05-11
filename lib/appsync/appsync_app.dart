import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appsync_search_view.dart';
import 'appsync_cubit.dart';
import 'appsync_item_cubit.dart';

class AppSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AppSyncCTGCubit()),
          BlocProvider(create: (context) => AppSyncItemCubit()),
        ],
        child: AppSyncNav(),
      ),
    );
  }
}

class AppSyncNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: AppSyncSearchView())
      ],
      onPopPage: (result, route) {
        return route.didPop(result);
      },
    );
  }
}


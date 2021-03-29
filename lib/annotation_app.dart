import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// annotation table view
import 'annotation_table_view.dart';
// annotation cubit
import 'annotation_cubit.dart';
// annotation table view
import 'annotation_form_cubit.dart';
import 'add_annotation_view.dart';

class AnnotationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AnnotationCubit()),
        BlocProvider(
            create: (context) =>
                FormCubit(annotationCubit: context.read<AnnotationCubit>()))
      ],
      child: AnnotationNavigator(),
    ));
  }
}

class AnnotationNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [MaterialPage(child: AnnotationView())],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

class AnnotationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: AnnotationTableView(),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  Widget _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text("Annotations"),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => Container(
                  // height: MediaQuery.of(context).size.height/5,
                  child: AddAnnotationView(),
                ));
      },
    );
  }
}

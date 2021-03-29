import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: _listTodoView(),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  Widget _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text("Annotations"),
    );
  }

  Widget _listTodoView() {
    return SafeArea(
      child: BlocBuilder<AnnotationCubit, AnnotationState>(
        builder: (context, state) {
          if (state is AnnotationAdded) {
            return ListView.builder(
              itemCount: state.annotations.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        "start: ${state.annotations[index].startTime} duration: ${state.annotations[index].duration} description: ${state.annotations[index].description}"),
                  ),
                );
              },
            );
          }

          if (state is AnnotationInit) {
            return ListView.builder(
              itemCount: state.annotations.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        "start: ${state.annotations[index].startTime} duration: ${state.annotations[index].duration} description: ${state.annotations[index].description}"),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
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

class AddAnnotationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          _timeAnnotate(context),
          _durationAnnotate(context),
          _description(context),
          SizedBox(
            height: 20,
          ),
          _saveButton(context),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return BlocBuilder<FormCubit, FormState>(builder: (context, state) {
      return ElevatedButton(
          onPressed: () {
            BlocProvider.of<FormCubit>(context).submitForm();
            Navigator.pop(context);
          },
          child: Text("Save"));
    });
  }

  Widget _timeAnnotate(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          icon: Icon(Icons.av_timer), hintText: "Starting Time"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context).updateStartTime(value);
        print(value);
      },
    );
  }

  Widget _durationAnnotate(BuildContext context) {
    return TextFormField(
      decoration:
          InputDecoration(icon: Icon(Icons.timer_10), hintText: "Duration"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context)
            .updateDuration(double.parse('$value'));
        print(value);
      },
    );
  }

  Widget _description(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(icon: Icon(Icons.edit), hintText: "Note"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context).updateDescription(value);
        print(value);
      },
    );
  }
}

// Annotation Model
class Annotation {
  final String startTime;
  final double duration;
  final String description;
  Annotation({this.startTime, this.duration, this.description});
}

// Form State
class FormState {
  final String startTime;
  final double duration;
  final String description;
  FormState({
    String startTime,
    double duration,
    String description,
  })  : this.startTime = startTime ?? "",
        this.duration = duration ?? 0.0,
        this.description = description ?? "";
}

// Annotation State
abstract class AnnotationState {}

class AnnotationInit extends AnnotationState {
  final List<Annotation> annotations;
  AnnotationInit({
    List<Annotation> annotations,
  }) : this.annotations = annotations ?? [];
}

class AnnotationAdded extends AnnotationState {
  final List<Annotation> annotations;
  // Constructor
  AnnotationAdded({
    List<Annotation> annotations,
  }) : this.annotations = annotations ?? [];
}

// Form Cubit
class FormCubit extends Cubit<FormState> {
  final AnnotationCubit annotationCubit;
  FormCubit({this.annotationCubit}) : super(FormState());

  // Starttime field change
  void updateStartTime(String startTime) {
    emit(FormState(
        startTime: startTime,
        duration: this.state.duration,
        description: this.state.description));
  }

  // Duration field change
  void updateDuration(double duration) {
    emit(FormState(
        startTime: this.state.startTime,
        duration: duration,
        description: this.state.description));
  }

  // Descriptoin field change
  void updateDescription(String description) {
    emit(FormState(
        startTime: this.state.startTime,
        duration: this.state.duration,
        description: description));
  }

  // Save button pressed
  void submitForm() {
    annotationCubit.addAnnotation(Annotation(
        startTime: this.state.startTime,
        duration: this.state.duration,
        description: this.state.description));
  }
}

// Annotation Cubit
class AnnotationCubit extends Cubit<AnnotationState> {
  List<Annotation> _annotations = [];
  AnnotationCubit() : super(AnnotationInit());

  void addAnnotation(Annotation annotation) {
    _annotations.add(annotation);
    emit(AnnotationAdded(annotations: _annotations));
  }
}

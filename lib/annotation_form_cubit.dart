import 'package:flutter_bloc/flutter_bloc.dart';
import 'annotation_form_state.dart';
import 'annotation_cubit.dart';
import 'annotation.dart';

// Form Cubit
class FormCubit extends Cubit<AnnotationFormState> {
  final AnnotationCubit annotationCubit;
  FormCubit({this.annotationCubit}) : super(AnnotationFormState());

  // Starttime field change
  void updateStartTime(String startTime) {
    emit(AnnotationFormState(
        startTime: startTime,
        duration: this.state.duration,
        description: this.state.description));
  }

  // Duration field change
  void updateDuration(double duration) {
    emit(AnnotationFormState(
        startTime: this.state.startTime,
        duration: duration,
        description: this.state.description));
  }

  // Descriptoin field change
  void updateDescription(String description) {
    emit(AnnotationFormState(
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

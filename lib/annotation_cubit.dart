import 'package:flutter_amplify/acceleration.dart';
import 'package:flutter_amplify/deceleration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'annotation_state.dart';
import 'annotation.dart';
// heartrate cubit
import 'heartrate_cubit.dart';
// heartrate state
import 'heartrate_state.dart';

// Annotation Cubit
class AnnotationCubit extends Cubit<AnnotationState> {
  final HeartRateCubit heartRateCubit;
  List<Annotation> _annotations = [];
  List<Acceleration> _accels = [];
  List<Deceleration> _decels = [];
  List<double> _mHR = [];
  List<double> _fHR = [];

  // Constructor
  AnnotationCubit({
    this.heartRateCubit,
  }) : super(AnnotationAdded());

  // Load heartrate from database
  void loadHeartRate() async {
    await heartRateCubit.loadHeartRateFromFile();

    // get mHR and fHR from HeartRateCubit
    _mHR = (heartRateCubit.state as LoadedHeartRateScucess).mHR;
    _fHR = (heartRateCubit.state as LoadedHeartRateScucess).fHR;

    // update mHR and fHR to Annotation Cubit
    emit(AnnotationLoadedHeartRate(
      mHR: _mHR,
      fHR: _fHR,
      accels: _accels,
      decels: _decels,
      annotations: _annotations,
    ));
  }

  // Clinican add an annotation
  void addAnnotation(Annotation annotation) {
    _annotations.add(annotation);

    // create accel
    final acel = Acceleration(
        start: double.parse('${annotation.startTime}'),
        duration: annotation.duration);
    _accels.add(acel);

    // create decel

    // update state
    emit(AnnotationAdded(
        mHR: _mHR,
        fHR: _fHR,
        accels: _accels,
        decels: _decels,
        annotations: _annotations));
  }
  //
}

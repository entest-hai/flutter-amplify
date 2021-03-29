import 'annotation.dart';
import 'acceleration.dart';
import 'deceleration.dart';

// Annotation State
abstract class AnnotationState {}

class AnnotationInit extends AnnotationState {
  final List<Annotation> annotations;
  final List<double> mHR;
  final List<double> fHR;
  final List<Acceleration> accels;
  final List<Deceleration> decels;

  AnnotationInit({
    List<Annotation> annotations,
    List<double> mHR,
    List<double> fHR,
    List<Acceleration> accels,
    List<Deceleration> decels,
  })  : this.annotations = annotations ?? [],
        this.mHR = mHR ?? [],
        this.fHR = fHR ?? [],
        this.accels = accels ?? [],
        this.decels = decels ?? [];
}

class AnnotationLoadedHeartRate extends AnnotationAdded {
  final List<Annotation> annotations;
  final List<double> mHR;
  final List<double> fHR;
  final List<Acceleration> accels;
  final List<Deceleration> decels;

  // Constructor
  AnnotationLoadedHeartRate({
    List<Annotation> annotations,
    List<double> mHR,
    List<double> fHR,
    List<Acceleration> accels,
    List<Deceleration> decels,
  })  : this.annotations = annotations ?? [],
        this.mHR = mHR ?? [],
        this.fHR = fHR ?? [],
        this.accels = accels ?? [],
        this.decels = decels ?? [];
}

class AnnotationAdded extends AnnotationState {
  final List<Annotation> annotations;
  final List<double> mHR;
  final List<double> fHR;
  final List<Acceleration> accels;
  final List<Deceleration> decels;

  // Constructor
  AnnotationAdded({
    List<Annotation> annotations,
    List<double> mHR,
    List<double> fHR,
    List<Acceleration> accels,
    List<Deceleration> decels,
  })  : this.annotations = annotations ?? [],
        this.mHR = mHR ?? [],
        this.fHR = fHR ?? [],
        this.accels = accels ?? [],
        this.decels = decels ?? [];
}

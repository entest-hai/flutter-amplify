// HeartRateCubit
abstract class HeartRateState {}

class LoadingHeartRate extends HeartRateState {}

class LoadedHeartRateScucess extends HeartRateState {
  final List<double> mHR;
  final List<double> fHR;
  LoadedHeartRateScucess({this.mHR, this.fHR});
}

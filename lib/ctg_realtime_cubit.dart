import 'ctg_realtime_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

// Beat Cubit
abstract class BeatState {}

class LoadingBeat extends BeatState {}

class LoadedBeatSuccess extends BeatState {
  final List<Beat> beats;
  final List<double> mHR;
  final List<double> fHR;
  LoadedBeatSuccess({this.beats, this.mHR, this.fHR});
}

class BeatCubit extends Cubit<BeatState> {
  final _beatRepository = BeatRepository();
  BeatCubit() : super(LoadingBeat());

  Future<void> fetchBeat() async {
    List<double> mHR = [];
    List<double> fHR = [];
    final beats = await _beatRepository.fetchBeat();
    for (var beat in beats) {
      mHR += beat.mHR;
      fHR += beat.fHR;
    }
    emit(LoadedBeatSuccess(beats: beats, mHR: mHR, fHR: fHR));
  }

  Future<void> writeBeat(StorageItem item) async {
    List<double> mHR = [];
    List<double> fHR = [];
    await _beatRepository.writeBeat(item);
    final beats = await _beatRepository.fetchBeat();
    for (var beat in beats) {
      mHR += beat.mHR;
      fHR += beat.fHR;
    }
    // sort beats by createdTime
    emit(LoadedBeatSuccess(beats: beats, mHR: mHR, fHR: fHR));
  }
}

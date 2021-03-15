import 'ctg_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

// HeartRateCubit
abstract class HeartRateState {}

class LoadingHeartRate extends HeartRateState {
  final List<double> mHR;
  final List<double> fHR;
  LoadingHeartRate({this.mHR, this.fHR});
}

class LoadedHeartRateScucess extends HeartRateState {
  final List<double> mHR;
  final List<double> fHR;
  LoadedHeartRateScucess({this.mHR, this.fHR});
}

class HeartRateCubit extends Cubit<HeartRateState> {
  final _heartrateRepository = HeartRateRepository();
  HeartRateCubit() : super(LoadingHeartRate(mHR: [], fHR: []));

  Future<void> loadHeartRateFromFile() async {
    final mHR =
        await _heartrateRepository.readHeartRateFile("assets/mheartrate.txt");
    final fHR =
        await _heartrateRepository.readHeartRateFile("assets/fheartrate.txt");
    emit(LoadedHeartRateScucess(mHR: mHR, fHR: fHR));
  }

  Future<void> getHeartRateFromAPI(StorageItem item) async {
    final List<double> mHR = [];
    final List<double> fHR = [];
    emit(LoadingHeartRate(mHR: mHR, fHR: fHR));
    // Call FHR API
    try {
      final fhr = await _heartrateRepository.getHeartRateFromAPI(item);
      emit(LoadedHeartRateScucess(mHR: fhr.mHR, fHR: fhr.fHR));
    } catch (e) {
      print(e);
    }
  }
}

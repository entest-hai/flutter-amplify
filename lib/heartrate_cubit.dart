import 'package:flutter_bloc/flutter_bloc.dart';
// heartrate state
import 'heartrate_state.dart';
// heart rate repository
import 'heartrate_repository.dart';

class HeartRateCubit extends Cubit<HeartRateState> {
  final _heartrateRepository = HeartRateRepository();

  HeartRateCubit() : super(LoadingHeartRate());

  Future<void> loadHeartRateFromFile() async {
    final mHR =
        await _heartrateRepository.readHeartRateFile("assets/mheartrate.txt");
    final fHR =
        await _heartrateRepository.readHeartRateFile("assets/fheartrate.txt");
    emit(LoadedHeartRateScucess(mHR: mHR, fHR: fHR));
  }
}

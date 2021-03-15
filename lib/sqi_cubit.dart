import 'sqi_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

// State
abstract class UploadState {}

class ListingFiles extends UploadState {}

class ListFilesFailure extends UploadState {}

class ListFilesSuccess extends UploadState {
  final List<StorageItem> files;
  ListFilesSuccess({this.files});
}

// UploadCubit
class UploadCubit extends Cubit<UploadState> {
  final _dataRepository = DataRepository();
  UploadCubit() : super(ListingFiles());

  void listFiles() async {
    if (state is ListFilesSuccess == false) {
      emit(ListingFiles());
    }
    try {
      final files = await _dataRepository.listFiles();
      emit(ListFilesSuccess(files: files));
    } catch (e) {
      emit(ListFilesFailure());
    }
  }

  void uploadFile() async {
    await _dataRepository.uploadFile();
    listFiles();
  }
}

// SQI Cubit
abstract class CTGAPIState {}

class LoadingCTG extends CTGAPIState {}

class LoadedCTGSuccess extends CTGAPIState {
  GetUrlResult url;
  LoadedCTGSuccess({this.url});
}

class ComputedSQISuccess extends CTGAPIState {
  SQI sqi;
  ComputedSQISuccess({this.sqi});
}

class LoadedCTGFailure extends CTGAPIState {}

class CTGCubit extends Cubit<CTGAPIState> {
  final _ctgRepository = CTGRepository();
  CTGCubit() : super(LoadingCTG());

  void getCTG(StorageItem item) async {
    // Call sqiApi if data.csv
    String extension = '.' + item.key.toString().split(".").last;
    if ('.csv'.contains(extension)) {
      final sqi = await _ctgRepository.computeSQI(item);
      emit(ComputedSQISuccess(sqi: sqi));
    } else if ('.jpg, .jpeg, .png'.contains(extension)) {
      final url = await _ctgRepository.getCTG(item);
      emit(LoadedCTGSuccess(url: url));
    } else {
      emit(LoadedCTGFailure());
    }
  }

  void popToDataList() {
    emit(LoadingCTG());
  }
}

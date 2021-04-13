import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 's3_list_files_state.dart';
import 's3_list_files_repository..dart';
import 's3_detail_file_cubit.dart';

class S3ListFilesCubit extends Cubit<S3ListFilesState> {
  final S3DetailFileCubit s3detailFileCubit;
  final _dataRepository = S3Repository();
  S3ListFilesCubit({this.s3detailFileCubit}) : super(S3ListingFiles());

  void viewOneFile(StorageItem item) async {
    await s3detailFileCubit.fetchDetailFile(item);
  }

  void listFiles() async {
    
    print("list file cubit called ");
    emit(S3ListingFiles());
    
    try {
      final files = await _dataRepository.listFiles();
      emit(S3ListFilesSuccess(files: files));
    } catch (e) {
      print(e.toString());
      emit(S3ListFilesFailure());
    }
  }

  void listCsvFiles() async {
    emit(S3ListingFiles());

    if (state is S3ListFilesSuccess == false) {
      emit(S3ListingFiles());
    }
    try {
      final files = await _dataRepository.listCsvFiles();
      emit(S3ListFilesSuccess(files: files));
    } catch (e) {
      emit(S3ListFilesFailure());
    }
  }

  Future<void> uploadFile() async {
    _dataRepository.uploadFile();
    listFiles();
  }
}

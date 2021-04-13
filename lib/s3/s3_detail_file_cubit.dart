import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 's3_detail_file_state.dart';
import 's3_detail_file_model.dart';

class S3DetailFileCubit extends Cubit<S3DetailFileState>{
  S3DetailFileCubit() : super(FetchingS3DetailFileState());

  Future<void> fetchDetailFile(StorageItem item) async {
    emit(FetchingS3DetailFileState());

    try {
      emit(FetchingS3DetailFileState());
      GetUrlResult url =  await Amplify.Storage.getUrl(key: item.key);
      emit(FetchedS3DetailFileStateSuccess(s3detailFile: S3DetailFile(url: url, item: item)));

    } catch(e){
      emit(FetchedS3DetailFileStateFail());
    }
  }
}
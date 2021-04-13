import 's3_detail_file_model.dart';

abstract class S3DetailFileState {}

class FetchingS3DetailFileState  extends S3DetailFileState {}

class FetchedS3DetailFileStateFail extends S3DetailFileState {}

class FetchedS3DetailFileStateSuccess extends S3DetailFileState {
  final S3DetailFile s3detailFile;
  FetchedS3DetailFileStateSuccess({this.s3detailFile});
}


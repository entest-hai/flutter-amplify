import 'package:amplify_storage_s3/amplify_storage_s3.dart';


abstract class S3ListFilesState {}

class S3ListingFiles extends S3ListFilesState {}

class S3ListFilesFailure extends S3ListFilesState {}

class S3ListFilesSuccess extends S3ListFilesState {
  final List<StorageItem> files;
  S3ListFilesSuccess({this.files});
}

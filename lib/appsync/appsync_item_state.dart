import 'dart:io';

abstract class AppSyncItemState {}

class AppSyncItemDownloading  extends AppSyncItemState {}

class AppSyncItemDownloadedSuccess extends AppSyncItemState {
  final String ctgUrl;
  final File localCtgPath;
  AppSyncItemDownloadedSuccess({this.ctgUrl, this.localCtgPath});
}

class AppSyncItemDownloadedFail extends AppSyncItemState {

}
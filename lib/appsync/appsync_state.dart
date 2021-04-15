import 'appsync_ctg_model.dart';

class AppSyncCTGState {
  bool isFetching;
  bool isFetchSuccess;
  List<CTGRecordModel> ctgs;
  AppSyncCTGState({this.isFetching, this.isFetchSuccess, this.ctgs});
}

import 'appsync_ctg_model.dart';

class AppSyncCTGState {
  bool isFetchingMore;
  bool isFetching;
  bool isFetchSuccess;
  List<CTGRecordModel> ctgs;
  AppSyncCTGState({this.isFetchingMore, this.isFetching, this.isFetchSuccess, this.ctgs});
}

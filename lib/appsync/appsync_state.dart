import 'appsync_ctg_model.dart';

class AppSyncCTGState {
  String query;
  bool isFetchingMore;
  bool isFetching;
  bool isFetchSuccess;
  List<CTGRecordModel> ctgs;
  AppSyncCTGState({this.query, this.isFetchingMore, this.isFetching, this.isFetchSuccess, this.ctgs});
}

import 'package:flutter_amplify/appsync/appsync_ctg_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appsync_state.dart';
import 'appsync_repository.dart';

class AppSyncCTGCubit extends Cubit<AppSyncCTGState> {
  AppSyncRepository appSyncRepository = AppSyncRepository(records: []);
  AppSyncCTGCubit() : super(AppSyncCTGState(isFetching: false, isFetchSuccess: false, ctgs: []));

  Future<void> fetchFirstTimeCTG() async {
    await fetchCTG();
    await fetchCTG();
  }

  Future<void> fetchCTG() async {
    // first time fetch data
    if (this.appSyncRepository.records.length == 0){
      print("first time fetch");
      emit(
          AppSyncCTGState(
            isFetchingMore: false,
            isFetching: true,
            isFetchSuccess: false,
            ctgs: this.appSyncRepository.records,
          )
      );
    } else {
      print("fetch more data");
      emit(
          AppSyncCTGState(
            isFetchingMore: true,
            isFetching: false,
            isFetchSuccess: true,
            ctgs: this.appSyncRepository.records,
          )
      );
    }

    await this.appSyncRepository.getCTGs();
    emit(
      AppSyncCTGState(
        isFetchingMore: false,
        isFetching: false,
        isFetchSuccess: true,
        ctgs: this.appSyncRepository.records,
      )
    );
  }
}
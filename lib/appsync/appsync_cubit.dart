import 'package:flutter_amplify/appsync/appsync_ctg_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appsync_state.dart';
import 'appsync_repository.dart';

class AppSyncCTGCubit extends Cubit<AppSyncCTGState> {
  AppSyncRepository appSyncRepository = AppSyncRepository(records: []);
  AppSyncCTGCubit() : super(AppSyncCTGState(isFetching: false, isFetchSuccess: false, ctgs: []));

  Future<void> reset() async {
    appSyncRepository.reset();
    emit(AppSyncCTGState(isFetching: false, isFetchSuccess: false, ctgs: []));
  }

  Future<void> fetchFirstTimeCTG(String dataset) async {
    if ((dataset !=null) & (dataset != "")) {
      await fetchCTG(dataset);
    }
  }

  Future<void> fetchAllCTG(String dataset) async {
    print("fetch all $dataset");
    if ((dataset != null) & (dataset != ""))  {
      emit(
          AppSyncCTGState(
            query: dataset,
            isFetchingMore: false,
            isFetching: true,
            isFetchSuccess: false,
            ctgs: this.appSyncRepository.records,
          )
      );
      await this.appSyncRepository.fetchCTGs(dataset);
      print("$dataset has ${this.appSyncRepository.records.length} records");
      emit(
          AppSyncCTGState(
            query: dataset,
            isFetchingMore: false,
            isFetching: false,
            isFetchSuccess: true,
            ctgs: this.appSyncRepository.records,
          )
      );
    }
  }

  Future<void> fetchCTG(String dataset) async {
    if ((dataset != null) & (dataset != "")) {
      // first time fetch data
      if (this.appSyncRepository.records.length == 0){
        print("first time fetch $dataset");
        emit(
            AppSyncCTGState(
              query: dataset,
              isFetchingMore: false,
              isFetching: true,
              isFetchSuccess: false,
              ctgs: this.appSyncRepository.records,
            )
        );
      } else {
        print("fetch more data $dataset");
        emit(
            AppSyncCTGState(
              query: dataset,
              isFetchingMore: true,
              isFetching: false,
              isFetchSuccess: true,
              ctgs: this.appSyncRepository.records,
            )
        );
      }

      await this.appSyncRepository.getCTGs(dataset);
      emit(
          AppSyncCTGState(
            query: dataset,
            isFetchingMore: false,
            isFetching: false,
            isFetchSuccess: true,
            ctgs: this.appSyncRepository.records,
          )
      );
    }
  }
}
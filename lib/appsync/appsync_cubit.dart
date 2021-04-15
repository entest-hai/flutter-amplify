import 'package:flutter_amplify/appsync/appsync_ctg_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appsync_state.dart';
import 'appsync_repository.dart';

class AppSyncCTGCubit extends Cubit<AppSyncCTGState> {
  AppSyncRepository appSyncRepository = AppSyncRepository();
  AppSyncCTGCubit() : super(AppSyncCTGState(isFetching: false, isFetchSuccess: false, ctgs: []));

  Future<void> fetchCTG() async {
    emit(
      AppSyncCTGState(
        isFetching: true,
        isFetchSuccess: false,
        ctgs: []
      )
    );

    // Graphql queries to list all ctg records from DDB
    final ctgs =  await appSyncRepository.fetchCTGs();

    emit(
      AppSyncCTGState(
        isFetching: false,
        isFetchSuccess: true,
        ctgs: ctgs
      )
    );
  }
}
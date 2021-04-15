import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'appsync_item_state.dart';
import 'appsync_ctg_model.dart';

class AppSyncItemCubit extends Cubit<AppSyncItemState>{
  AppSyncItemCubit() : super(AppSyncItemState(ctgUrl: null));

  Future<void> fetchCtgUrl(CTGRecordModel ctg) async {
    final String key = "ctg/1004.csv.png";
    final StorageItem item = StorageItem(key: key);
    GetUrlResult url =  await Amplify.Storage.getUrl(key: item.key);
    emit(AppSyncItemState(ctgUrl: url.url));
  }
}

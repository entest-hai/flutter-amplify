import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'appsync_item_state.dart';
import 'appsync_ctg_model.dart';
import 'package:path_provider/path_provider.dart';

class AppSyncItemCubit extends Cubit<AppSyncItemState>{
  AppSyncItemCubit() : super(AppSyncItemDownloading());

  Future<void> fetchCtgUrl(CTGRecordModel ctg) async {
    emit(AppSyncItemDownloading());
    final String key = "ctg/" + ctg.ctgUrl.split("/").last;
    final StorageItem item = StorageItem(key: key);
    GetUrlResult url =  await Amplify.Storage.getUrl(key: item.key);
    emit(AppSyncItemDownloadedSuccess(
        ctgUrl: url.url,
        localCtgPath: null,
    )
    );
  }

  Future<void> downloadCtg(CTGRecordModel ctg) async {
    emit(AppSyncItemDownloading());
    final String key = "ctg/" + ctg.ctgUrl.split("/").last;
    final StorageItem item = StorageItem(key: key);
    final dir = await getApplicationDocumentsDirectory();
    try {
      GetUrlResult url =  await Amplify.Storage.getUrl(key: item.key);
      await Amplify.Storage.downloadFile(
          key: key,
          local: new File("${dir.path}/" + key)
      );
      print("downloaded file $key");
      emit(
        AppSyncItemDownloadedSuccess(
          ctgUrl: url.url,
          localCtgPath: File("${dir.path}/" + key)
        )
      );
    } on StorageException catch(e) {
      print(e.message);
    }
  }

}

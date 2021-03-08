import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amplify_flutter/amplify.dart';
import 'dart:io';
import 'package:flutter/material.dart';

// S3 List File View
class S3ListFileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<S3Cubit, S3UploadState>(
      builder: (context, state) {
        if (state is S3ListFilesSuccess) {
          return state.files.isEmpty
              ? _emptyView()
              : Column(
                  children: [
                    Expanded(child: _listFileView(state)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          color: Colors.blue,
                          icon: Icon(
                            Icons.cloud_upload,
                            size: 50,
                          ),
                          onPressed: () {
                            BlocProvider.of<S3Cubit>(context).uploadFile();
                          }),
                    ),
                  ],
                );
        } else if (state is S3ListFilesFailure) {
          return _exceptionView();
        } else {
          return _listingView();
        }
      },
    );
  }

  Widget _listingView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  ListView _listFileView(S3ListFilesSuccess state) {
    return ListView.builder(
      itemCount: state.files.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () => {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _getFileIcon(state.files[index].key.toString()),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(state.files[index].key.toString()),
                      ))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.cloud_download), onPressed: () {}),
                      IconButton(icon: Icon(Icons.delete), onPressed: () {})
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String name) {
    String extension = '.' + name.split(".").last;

    if ('.jpg, .jpeg, .png'.contains(extension)) {
      return Icon(
        Icons.image,
        color: Colors.blue,
      );
    }
    return Icon(Icons.archive);
  }

  Widget _emptyView() {
    return Center(
      child: Text("Not File Yet"),
    );
  }

  Widget _exceptionView() {
    return Center(
      child: Text("Exception"),
    );
  }
}

// S3 Repository
class S3Repository {
  void uploadFile() async {
    Map<String, String> metadata = <String, String>{};
    metadata['name'] = 'rawecg.csv';
    metadata['desc'] = 'a test file';
    S3UploadFileOptions options = S3UploadFileOptions(
        accessLevel: StorageAccessLevel.guest, metadata: metadata);
    final key = new DateTime.now().toString();
    // Pick a file
    FilePickerResult result = await FilePicker.platform.pickFiles();
    // Try to upload to S3
    if (result != null) {
      File file = File(result.files.single.path);
      try {
        UploadFileResult uploadResult = await Amplify.Storage.uploadFile(
            local: file,
            key: key + file.path.split("/").last,
            options: options);
        print("file: ${file.path} ${uploadResult.toString()}");
      } on StorageException catch (e) {
        print(e.message);
      }
    } else {}
  }

  Future<List<StorageItem>> listFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      List<StorageItem> items = res.items
          .where((element) => element.key.toString().isNotEmpty)
          .toList();
      return items;
    } on StorageException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<List<StorageItem>> listCsvFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      List<StorageItem> items = res.items
          .where((element) => element.key.toString().contains(".csv"))
          .toList();
      return items;
    } on StorageException catch (e) {
      print(e.message);
      return null;
    }
  }
}

// S3 State and Cubit
abstract class S3UploadState {}

class S3ListingFiles extends S3UploadState {}

class S3ListFilesFailure extends S3UploadState {}

class S3ListFilesSuccess extends S3UploadState {
  final List<StorageItem> files;
  S3ListFilesSuccess({this.files});
}

// Cubmit trigger
class S3Cubit extends Cubit<S3UploadState> {
  final _dataRepository = S3Repository();
  S3Cubit() : super(S3ListingFiles());

  void listFiles() async {
    if (state is S3ListFilesSuccess == false) {
      emit(S3ListingFiles());
    }
    try {
      final files = await _dataRepository.listFiles();
      emit(S3ListFilesSuccess(files: files));
    } catch (e) {
      emit(S3ListFilesFailure());
    }
  }

  void listCsvFiles() async {
    if (state is S3ListFilesSuccess == false) {
      emit(S3ListingFiles());
    }
    try {
      final files = await _dataRepository.listCsvFiles();
      emit(S3ListFilesSuccess(files: files));
    } catch (e) {
      emit(S3ListFilesFailure());
    }
  }

  Future<void> uploadFile() async {
    _dataRepository.uploadFile();
    listFiles();
  }
}

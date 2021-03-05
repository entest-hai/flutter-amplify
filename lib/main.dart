import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
// Generated in previous step 
import 'amplifyconfiguration.dart'; 
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override 
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false; 

  @override
  initState() {
    super.initState(); 
    _configureAmplify(); 
  }

  @override 
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UploadCubit()..listFiles(),
        child: _amplifyConfigured ? TodoView() : ListingView(),
      ),
    );
  }

  void _configureAmplify() async {
    if (!mounted) return;
    try {
      Amplify.addPlugins([ AmplifyAuthCognito(), AmplifyStorageS3()]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class TodoView extends StatefulWidget {
  @override 
  State<StatefulWidget> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  @override 
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("S3Upload"),),
      body: BlocBuilder<UploadCubit, UploadState>(builder: (context, state) {
        if (state is ListFilesSuccess) {
          return  state.files.isEmpty ? _emptyView() : ListView.builder(
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              return Card(
                child: InkWell(
                  onTap: () => {
                    showModalBottomSheet(
                        context: context,
                        builder: (context){
                          return _detailFileView(state.files[index]);
                        })
                  },
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _getFileIcon(state.files[index].key.toString()),
                          Expanded(child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(state.files[index].key.toString()),
                          ))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child:
                      Row(
                        children: [
                          IconButton(icon: Icon(Icons.cloud_download), onPressed: (){}),
                          IconButton(icon: Icon(Icons.delete), onPressed: (){})
                        ],),
                    )
                  ],
                ),
                ),
              );
            },
          );
        } else if (state is ListFilesFailure) {
          return _exceptionView();
        } else {
          return ListingView();
        }
      },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cloud_upload), onPressed: () {
          BlocProvider.of<UploadCubit>(context).uploadFile();
      },
      ),
    );
  }

  Widget _detailFileView(StorageItem item) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: BlocProvider.of<UploadCubit>(context).downloadFile(item),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Image.network(snapshot.data);
              } else {
                return Text("ERROR");
              }
          },
        ),
        ElevatedButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: Text("Back"))
      ],
    );
  }

  Widget _getFileIcon(String name){
    String extension = '.' + name.split(".").last;

    if ('.jpg, .jpeg, .png'.contains(extension)) {
      return Icon(Icons.image, color: Colors.blue,);
    }
    return Icon(Icons.archive);
  }

  Widget _emptyView() {
    return Center(child: Text("Not File Yet"),);
  }

  Widget _exceptionView(){
    return Center(
      child: Text("Exception"),
    );
  }
}

class ListingView extends StatelessWidget {
  @override
   Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Center(child: CircularProgressIndicator(),),
    );
  }
}

// Data Repository
class DataRepository {

  Future<GetUrlResult> downloadFile(StorageItem item) async {
    try {
      GetUrlResult result = await Amplify.Storage.getUrl(key: item.key);
      return result;

    } on StorageException catch (e) {
      print(e.message);
    }
  }

  void uploadFile() async {
    Map<String, String> metadata = <String, String>{};
    metadata['name'] = 'rawecg.csv';
    metadata['desc'] = 'a test file';
    S3UploadFileOptions options = S3UploadFileOptions(accessLevel: StorageAccessLevel.guest, metadata: metadata);
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
      }
      on StorageException catch (e) {
        print(e.message);
      }
    } else {

    }
  }

  Future<List<StorageItem>> listFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      List<StorageItem> items =  res.items.where((element) => element.key.toString().isNotEmpty).toList();
      return items;
    } on StorageException catch(e) {
      print(e.message);
    }
  }
}

// State
abstract class UploadState {}

class ListingFiles extends UploadState {

}

class ListFilesFailure extends UploadState {

}

class ListFilesSuccess extends UploadState {
  final List<StorageItem> files;
  ListFilesSuccess({this.files});
}

// UploadCubit
class UploadCubit extends Cubit<UploadState> {
  final _dataRepository = DataRepository();
  UploadCubit() : super(ListingFiles());

  void listFiles() async {
    if (state is ListFilesSuccess == false) {
      emit(ListingFiles());
    }
    try {
      final files = await _dataRepository.listFiles();
      emit(ListFilesSuccess(files: files));
    } catch (e) {
      emit(ListFilesFailure());
    }
  }

  void uploadFile() async {
    await _dataRepository.uploadFile();
    listFiles();
  }

  Future<String> downloadFile(StorageItem item) async {
    final GetUrlResult result = await _dataRepository.downloadFile(item);
    return result.url;
  }
}

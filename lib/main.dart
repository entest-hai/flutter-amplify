import 'dart:convert';
import 'dart:ffi';
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
import 'package:http/http.dart' as http;

// Constant
final sqiApiBaseUrl =
    "https://bln9cf30wj.execute-api.ap-southeast-1.amazonaws.com/default/pythontest?filename=s3://flutteramplify32917a364a1942d5b5203a9c772381ec102628-dev/public/";

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
        home: MultiBlocProvider(providers: [
      BlocProvider(create: (context) => UploadCubit()..listFiles()),
      BlocProvider(
        create: (context) => CTGCubit(),
      )
    ], child: _amplifyConfigured ? CTGNav() : ListingView()));
  }

  void _configureAmplify() async {
    if (!mounted) return;
    try {
      Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class CTGNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Navigator(
      pages: [
        MaterialPage(child: TodoView()),
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
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
      appBar: AppBar(
        title: Text("S3Upload"),
      ),
      body: BlocBuilder<UploadCubit, UploadState>(
        builder: (context, state) {
          if (state is ListFilesSuccess) {
            return state.files.isEmpty
                ? _emptyView()
                : ListView.builder(
                    itemCount: state.files.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () => {
                            BlocProvider.of<CTGCubit>(context)
                                .getCTG(state.files[index]),
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return CTGDetailView();
                                }).whenComplete(() {
                              BlocProvider.of<CTGCubit>(context)
                                  .popToDataList();
                            })
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    _getFileIcon(
                                        state.files[index].key.toString()),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                          state.files[index].key.toString()),
                                    ))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.cloud_download),
                                        onPressed: () {}),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {})
                                  ],
                                ),
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
        child: Icon(Icons.cloud_upload),
        onPressed: () {
          BlocProvider.of<UploadCubit>(context).uploadFile();
        },
      ),
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

class ListingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Data Repository
class DataRepository {
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
}

// State
abstract class UploadState {}

class ListingFiles extends UploadState {}

class ListFilesFailure extends UploadState {}

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
}

// CTGDetailView
class CTGDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<CTGCubit, CTGAPIState>(builder: (context, state) {
      if (state is LoadingCTG) {
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is LoadedCTGFailure) {
        return Container(
          child: Center(
            child: Text("Invalid Image File"),
          ),
        );
      } else if (state is ComputedSQISuccess) {
        return Container(
          child: Center(
            child: Text(state.sqi.summary),
          ),
        );
      } else if (state is LoadedCTGSuccess) {
        return Container(
          child: Center(
            child: Image.network(state.url.url),
          ),
        );
      } else {
        return Container(
          child: Center(
            child: Text("Exception"),
          ),
        );
      }
    });
  }
}

//  Parser
class SQI {
  final int pass;
  final String recordname;
  final double mSQICh1;
  final double mSQICh2;
  final double mSQICh3;
  final double mSQICh4;
  final double fSQICh1;
  final double fSQICh2;
  final double fSQICh3;
  final double fSQICh4;
  final int invertCh1;
  final int invertCh2;
  final int invertCh3;
  final int invertCh4;
  final String summary;

  SQI(
      {this.pass,
      this.recordname,
      this.mSQICh1,
      this.mSQICh2,
      this.mSQICh3,
      this.mSQICh4,
      this.fSQICh1,
      this.fSQICh2,
      this.fSQICh3,
      this.fSQICh4,
      this.invertCh1,
      this.invertCh2,
      this.invertCh3,
      this.invertCh4,
      this.summary});

  factory SQI.fromJson(Map<String, dynamic> json) {
    final recordname = json['recordname'];
    final summary = "recordname: " +
        json['recordname'] +
        "\n" +
        "pass: " +
        (json['pass'] as int).toString() +
        "\n" +
        "mSQICh1: " +
        (json['mSQI_ch1'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh2: " +
        (json['mSQI_ch2'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh3: " +
        (json['mSQI_ch3'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh4: " +
        (json['mSQI_ch4'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh1: " +
        (json['fSQI_ch1'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh1: " +
        (json['fSQI_ch2'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh2: " +
        (json['fSQI_ch3'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh3: " +
        (json['fSQI_ch4'] as double).toStringAsFixed(3) +
        "\n" +
        "invertedCh1: " +
        (json["Inverted_ch1"] as int).toString() +
        "\n" +
        "invertedCh2: " +
        (json["Inverted_ch2"] as int).toString() +
        "\n" +
        "invertedCh3: " +
        (json["Inverted_ch3"] as int).toString() +
        "\n" +
        "invertedCh4: " +
        (json["Inverted_ch4"] as int).toString();

    return SQI(
        pass: json['pass'],
        recordname: recordname,
        mSQICh1: json['mSQI_ch1'],
        mSQICh2: json['mSQI_ch2'],
        mSQICh3: json['mSQI_ch3'],
        mSQICh4: json['mSQI_ch4'],
        fSQICh1: json['fSQI_ch1'],
        fSQICh2: json['fSQI_ch2'],
        fSQICh3: json['fSQI_ch3'],
        fSQICh4: json['fSQI_ch4'],
        invertCh1: json['Inverted_ch1'],
        invertCh2: json['Inverted_ch2'],
        invertCh3: json['Inverted_ch3'],
        invertCh4: json['Inverted_ch4'],
        summary: summary);
  }
}

// CTG Repository
class CTGRepository {
  Future<GetUrlResult> getCTG(StorageItem item) async {
    try {
      GetUrlResult url = await Amplify.Storage.getUrl(key: item.key);
      return url;
    } on StorageException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<SQI> computeSQI(StorageItem item) async {
    final url = sqiApiBaseUrl + item.key.toString();
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return SQI.fromJson(json);
  }
}

// CTGCubit
abstract class CTGAPIState {}

class LoadingCTG extends CTGAPIState {}

class LoadedCTGSuccess extends CTGAPIState {
  GetUrlResult url;
  LoadedCTGSuccess({this.url});
}

class ComputedSQISuccess extends CTGAPIState {
  SQI sqi;
  ComputedSQISuccess({this.sqi});
}

class LoadedCTGFailure extends CTGAPIState {}

class CTGCubit extends Cubit<CTGAPIState> {
  final _ctgRepository = CTGRepository();
  CTGCubit() : super(LoadingCTG());

  void getCTG(StorageItem item) async {
    // Call sqiApi if data.csv
    String extension = '.' + item.key.toString().split(".").last;
    if ('.csv'.contains(extension)) {
      final sqi = await _ctgRepository.computeSQI(item);
      emit(ComputedSQISuccess(sqi: sqi));
    } else if ('.jpg, .jpeg, .png'.contains(extension)) {
      final url = await _ctgRepository.getCTG(item);
      emit(LoadedCTGSuccess(url: url));
    } else {
      emit(LoadedCTGFailure());
    }
  }

  void popToDataList() {
    emit(LoadingCTG());
  }
}

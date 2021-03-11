import 'dart:convert';
import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
// Generated in previous step
import 'amplifyconfiguration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ctg.dart';
import 's3.dart';

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
      ),
      BlocProvider(
        create: (context) => HeartRateCubit()..loadHeartRateFromFile(),
      ),
      BlocProvider(create: (context) => S3Cubit()..listCsvFiles()),
      BlocProvider(create: (context) => TodoCubit()..subscribeTodo()),
    ], child: _amplifyConfigured ? CTGNavTab() : CTGNavTab()));
  }

  void _configureAmplify() async {
    if (!mounted) return;
    try {
      Amplify.addPlugins(
          [AmplifyAuthCognito(), AmplifyStorageS3(), AmplifyAPI()]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class CTGNavTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CTGNavTabState();
  }
}

class _CTGNavTabState extends State<CTGNavTab> {
  int _currentIndex = 0;
  final tabs = [
    Center(
      child: SQIAppView(),
    ),
    Center(
      child: CTGAppOnly(),
    ),
    TodoDBView(),
    Center(
      child: Text("Setting"),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Navigator(
      pages: [
        MaterialPage(
            child: Scaffold(
          appBar: AppBar(title: Text("Amplify")),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "SQI",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: "CTG",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.data_usage),
                  label: "DB",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Setting",
                  backgroundColor: Colors.blue)
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body: tabs[_currentIndex],
        ))
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }
}

class TodoDBView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TodoDBState();
  }
}

class _TodoDBState extends State<TodoDBView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is LoadingTodo) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is LoadedTodoSuccess) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          title: Text(state.todos[index].name +
                              " " +
                              state.todos[index].description)),
                    );
                  },
                ),
              ),
              IconButton(
                  icon:
                      Icon(Icons.cloud_download, size: 50, color: Colors.blue),
                  onPressed: () {
                    BlocProvider.of<TodoCubit>(context).fetchTodo();
                  }),
              SizedBox(
                height: 10,
              ),
            ],
          );
          ;
        } else {
          return Container(
            child: Center(
              child: Text("Exception"),
            ),
          );
        }
      },
    );
  }
}

class SQIAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        if (state is ListFilesSuccess) {
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
                            BlocProvider.of<UploadCubit>(context).uploadFile();
                          }),
                    ),
                  ],
                );
        } else if (state is ListFilesFailure) {
          return _exceptionView();
        } else {
          return ListingView();
        }
      },
    );
  }

  ListView _listFileView(ListFilesSuccess state) {
    return ListView.builder(
      itemCount: state.files.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () => {
              BlocProvider.of<CTGCubit>(context).getCTG(state.files[index]),
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return CTGDetailView();
                  }).whenComplete(() {
                BlocProvider.of<CTGCubit>(context).popToDataList();
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

// Todo Data Modal
class Todo {
  final String name;
  final String description;
  Todo({this.name, this.description});

  factory Todo.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final description = json['description'];
    return Todo(name: name, description: description);
  }
}

// Todo Repository
class TodoRepository {
  Future<List<Todo>> fetchTodo() async {
    List<Todo> _todos = [];
    try {
      String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          name
          description
        }
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      var items = jsonDecode(response.data.toString())['listTodos']['items'];
      for (var item in items) {
        print(item['name']);
        _todos.add(Todo.fromJson(item));
      }

      return _todos;
    } on ApiException catch (e) {
      print('Query failed: $e');
      return _todos;
    }
  }
}

// Todo Cubit
abstract class TodoState {}

class LoadingTodo extends TodoState {}

class LoadedTodoSuccess extends TodoState {
  final List<Todo> todos;
  LoadedTodoSuccess({this.todos});
}

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository = TodoRepository();
  TodoCubit() : super(LoadingTodo());

  void fetchTodo() async {
    final todos = await _todoRepository.fetchTodo();
    emit(LoadedTodoSuccess(todos: todos));
  }

  void subscribeTodo() async {
    // load data
    final todos = await _todoRepository.fetchTodo();
    emit(LoadedTodoSuccess(todos: todos));
    // observe changes
    try {
      String graphQLDocument = '''subscription OnCreateTodo {
        onCreateTodo {
          id
          name
          description
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            // print('Subscription event data received: ${event.data}');
            todos.add(Todo.fromJson(
                jsonDecode(event.data.toString())['onCreateTodo']));
            emit(LoadedTodoSuccess(todos: todos));
          },
          onEstablished: () {
            print('Subscription established');
          },
          onError: (e) {
            print('Subscription failed with error: $e');
          },
          onDone: () {
            print('Subscription has been closed successfully');
          });
    } on ApiException catch (e) {
      print('Failed to establish subscription: $e');
    }
  }
}

import 'dart:convert';
import 'dart:async';
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
// Todo Cubit
import 'todo_view.dart';
import 'todo_cubit.dart';

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
      BlocProvider(create: (context) => BeatCubit()..fetchBeat()),
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
      child: BeatView(),
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

class BeatView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BeatState();
  }
}

class _BeatState extends State<BeatView> {
  Timer myTimer;
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<BeatCubit, BeatState>(builder: (context, state) {
      if (state is LoadingBeat) {
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is LoadedBeatSuccess) {
        return Column(
          children: [
            Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CustomPaint(
                    painter: CTGPaperPainter(mHR: state.mHR, fHR: state.fHR),
                    size: Size(MediaQuery.of(context).size.width * 3,
                        MediaQuery.of(context).size.height / 3),
                  ),
                )),
            Expanded(
                child: ListView.builder(
              itemCount: state.beats.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        "createdTime: ${state.beats.reversed.toList()[index].createdTime} mHR: ${state.beats.reversed.toList()[index].mHR.length} fHR: ${state.beats.reversed.toList()[index].fHR.length}"),
                  ),
                );
              },
            )),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: S3ListRawECGView(),
            ),
            IconButton(
                icon: Icon(Icons.cloud_upload, size: 50, color: Colors.blue),
                onPressed: () {
                  // BlocProvider.of<BeatCubit>(context).writeBeat();
                  startTimer();
                }),
            SizedBox(
              height: 10,
            ),
          ],
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

  void startTimer() {
    BlocProvider.of<BeatCubit>(context)
        .writeBeat(StorageItem(key: "1004_0_.csv"));

    setState(() {
      counter = counter + 1;
    });

    myTimer = Timer.periodic(Duration(seconds: 10), (myTimer) {
      if (counter > 30) {
        setState(() {
          counter = 0;
        });
      }
      print("Call FHR API");
      BlocProvider.of<BeatCubit>(context)
          .writeBeat(StorageItem(key: "1004_" + counter.toString() + "_.csv"));
      setState(() {
        counter = counter + 1;
      });
    });
  }
}

// CTGGrid
class CTGPaperPainter extends CustomPainter {
  List<double> mHR;
  List<double> fHR;
  CTGPaperPainter({this.mHR, this.fHR});

  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()..color = Colors.yellow.withOpacity(0.0);
    // Draw rect
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        backgroundPaint);
    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;
    // Draw rect
    canvas.drawRect(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), borderPaint);
    // Draw heart rate horizontal line x30bpm square
    final stickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 0.7;
    for (var i = 2; i < 8; i++) {
      var yOffset = heartRateToYAxis(i * 30.0, size.height - 20);
      canvas.drawLine(
          Offset(10.0, yOffset), Offset(size.width - 10, yOffset), stickPaint);
    }
    // Draw time vertical line x2minute square
    for (var i = 0; i < 30; i++) {
      var xOffset = 10.0 + i * (size.width - 20) / 30;
      canvas.drawLine(
          Offset(xOffset, 10.0), Offset(xOffset, size.height - 10), stickPaint);
    }
    // Draw time vertical line x10minute mark
    final tenMinutePain = Paint()..color = Colors.black.withOpacity(0.2);
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(
          Rect.fromLTWH(10.0 + i * (size.width - 20) / 6, 10,
              (size.width - 20) / 60, size.height - 20),
          tenMinutePain);
    }

    // Maternal heart rate paint
    final mHRPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 1.5;
    // Plot maternal heart rate
    var numHeartRate = 60 * 60 * 4;
    var dx = (size.width - 20) / numHeartRate;
    var dx1 = 0.0;
    var dx2 = 0.0;
    var dy1 = 0.0;
    var dy2 = 0.0;
    for (var i = 0; i < mHR.length - 1; i++) {
      dx1 = 10.0 + i * dx;
      dx2 = 10.0 + (i + 1) * dx;
      dy1 = heartRateToYAxis(mHR[i], size.height - 20);
      dy2 = heartRateToYAxis(mHR[i + 1], size.height - 20);
      if (mHR[i] > 0.0 && mHR[i + 1] > 0) {
        canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), mHRPaint);
      }
    }
    // Fetal heart rate paint
    final fHRPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 1.5;

    // Plot maternal heart rate
    dx1 = 0.0;
    dx2 = 0.0;
    dy1 = 0.0;
    dy2 = 0.0;
    for (var i = 0; i < fHR.length - 1; i++) {
      dx1 = 10.0 + i * dx;
      dx2 = 10.0 + (i + 1) * dx;
      dy1 = heartRateToYAxis(fHR[i], size.height - 20);
      dy2 = heartRateToYAxis(fHR[i + 1], size.height - 20);
      if (fHR[i] > 0.0 && fHR[i + 1] > 0.0) {
        canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), fHRPaint);
      }
    }
  }

  double heartRateToYAxis(double heartrate, double height) {
    final minHR = 30.0;
    final maxHR = 240.0;
    final dy = height / (maxHR - minHR);
    return 10.0 + (maxHR - heartrate) * dy;
  }

  @override
  bool shouldRepaint(CTGPaperPainter oldDelegate) {
    return mHR != oldDelegate.mHR;
  }
}

class S3ListRawECGView extends StatelessWidget {
  const S3ListRawECGView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<S3Cubit, S3UploadState>(builder: (context, state) {
      if (state is S3ListFilesSuccess) {
        return ListView.builder(
          itemCount: state.files.length,
          itemBuilder: (context, index) {
            return Card(
                child: InkWell(
              onTap: () {
                BlocProvider.of<BeatCubit>(context)
                    .writeBeat(state.files[index]);
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
            ));
          },
        );
      } else if (state is S3ListFilesFailure) {
        return Container(
          child: Center(
            child: Text("Exception"),
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    });
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

//
// Beat Model
class Beat {
  final int createdTime;
  final List<double> mHR;
  final List<double> fHR;
  Beat({this.createdTime, this.mHR, this.fHR});

  factory Beat.fromJson(Map<String, dynamic> json) {
    final List<double> mHR = [];
    final List<double> fHR = [];
    final createdTime = json['createdTime'] as int;
    final mBeats = json['mHR'];
    final fBeats = json['fHR'];

    for (var beat in mBeats) {
      mHR.add(double.parse('$beat'));
    }

    for (var beat in fBeats) {
      fHR.add(double.parse('$beat'));
    }

    return Beat(createdTime: createdTime, mHR: mHR, fHR: fHR);
  }
}

// Beat Repository
class BeatRepository {
  final _heartRateRepository = HeartRateRepository();
  Future<void> writeBeat(StorageItem item) async {
    // Call FHR API
    final res = await _heartRateRepository
        .getHeartRateFromAPI(StorageItem(key: item.key));

    // Parse return heart rate
    final int createdTime = DateTime.now().millisecondsSinceEpoch;

    // Write to DB
    try {
      print("write beat to db");
      String graphQLDocument = '''mutation CreateHeartRate {
      createHeartRate(input: {createdTime: $createdTime, fHR: ${res.fHR}, mHR: ${res.mHR}}) {
          createdTime
          fHR
          mHR
        }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      // print(response.data);
    } on ApiException catch (e) {
      print(e);
    }
  }

  Future<List<Beat>> fetchBeat() async {
    List<Beat> beats = [];

    try {
      String graphQLDocument = '''query ListHeartRates {
      listHeartRates {
        items {
          createdTime
          mHR
          fHR
        }
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      var items =
          jsonDecode(response.data.toString())['listHeartRates']['items'];
      for (var item in items) {
        beats.add(Beat.fromJson(item));
      }

      // sort beats by created time
      beats.sort((a, b) => a.createdTime.compareTo(b.createdTime));

      return beats;
    } on ApiException catch (e) {
      print('Query failed: $e');
      return null;
    }
  }
}

// Beat Cubit
abstract class BeatState {}

class LoadingBeat extends BeatState {}

class LoadedBeatSuccess extends BeatState {
  final List<Beat> beats;
  final List<double> mHR;
  final List<double> fHR;
  LoadedBeatSuccess({this.beats, this.mHR, this.fHR});
}

class BeatCubit extends Cubit<BeatState> {
  final _beatRepository = BeatRepository();
  BeatCubit() : super(LoadingBeat());

  Future<void> fetchBeat() async {
    List<double> mHR = [];
    List<double> fHR = [];
    final beats = await _beatRepository.fetchBeat();
    for (var beat in beats) {
      mHR += beat.mHR;
      fHR += beat.fHR;
    }
    emit(LoadedBeatSuccess(beats: beats, mHR: mHR, fHR: fHR));
  }

  Future<void> writeBeat(StorageItem item) async {
    List<double> mHR = [];
    List<double> fHR = [];
    await _beatRepository.writeBeat(item);
    final beats = await _beatRepository.fetchBeat();
    for (var beat in beats) {
      mHR += beat.mHR;
      fHR += beat.fHR;
    }
    // sort beats by createdTime
    emit(LoadedBeatSuccess(beats: beats, mHR: mHR, fHR: fHR));
  }
}

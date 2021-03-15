import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 's3.dart';
import 'ctg_cubit.dart';

class CTGGridApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CTGAppState();
  }
}

class _CTGAppState extends State<CTGGridApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(providers: [
        BlocProvider(
            create: (context) => HeartRateCubit()..loadHeartRateFromFile())
      ], child: CTGAppNavTab()),
    );
  }
}

class CTGAppNavTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CTGAppNavTabState();
  }
}

class _CTGAppNavTabState extends State<CTGAppNavTab> {
  int _currentIndex = 0;
  final tabs = [
    Center(
      child: CTGAppOnly(),
    ),
    Center(
      child: Text("SQI"),
    ),
    Center(
      child: Text("Profile"),
    ),
    Center(
      child: Text("Setting"),
    ),
  ];
  @override
  Widget build(BuildContext context) {
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
                  label: "CTG",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: "SQI",
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
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

class CTGAppOnly extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeartRateCubit, HeartRateState>(
      builder: (context, state) {
        if (state is LoadingHeartRate) {
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3.0,
                child: Center(child: CircularProgressIndicator()),
              ),
              Expanded(child: S3ListFileView())
            ],
          );
        } else if (state is LoadedHeartRateScucess) {
          return Column(
            children: [
              CTGGridView(
                mHR: state.mHR,
                fHR: state.fHR,
              ),
              Expanded(child: S3ListFileView())
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

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
            onTap: () => {
              // Call CTGAPI to get heart rate traces
              BlocProvider.of<HeartRateCubit>(context)
                  .getHeartRateFromAPI(state.files[index]),
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

class CTGAppNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
            child: Scaffold(
          appBar: AppBar(title: Text("CTG")),
          body: BlocBuilder<HeartRateCubit, HeartRateState>(
            builder: (context, state) {
              if (state is LoadedHeartRateScucess) {
                return Column(
                  children: [
                    CTGGridView(
                      mHR: state.mHR,
                      fHR: state.fHR,
                    )
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ))
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }
}

class SineWaveApp extends StatefulWidget {
  @override
  _SineWaveState createState() => _SineWaveState();
}

class _SineWaveState extends State<SineWaveApp> {
  var offset = 0.0;
  Timer myTimer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("SineWave"),
        ),
        body: Column(
          children: [
            Text("phase $offset"),
            CustomPaint(
              painter: SineWavePainter(offset: offset),
              child: Container(
                height: 300,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            startTimer();
          },
        ),
      ),
    );
  }

  void startTimer() {
    myTimer = Timer.periodic(Duration(seconds: 1), (myTimer) {
      print("offset $offset");
      setState(() {
        offset += math.pi / 10;
      });
    });
  }
}

class CustomPainterApp extends StatelessWidget {
  var offset = 0.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("CustomPainter"),
        ),
        body: Column(
          children: [
            Container(
              height: 100,
              color: Colors.green,
            ),
            Container(
              height: 300,
              color: Colors.blue,
            ),
            CustomPaint(
                painter: SineWavePainter(offset: 0.0),
                child: Container(
                  color: Colors.green.withOpacity(0.1),
                  // width: 15,
                  height: 300,
                  // child: Text("OK"),
                )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print("tap me $offset");
          },
        ),
      ),
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigo;

    //
    canvas.drawRect(
      Rect.fromLTWH(20, 30, 100, 100),
      paint,
    );

    //
    canvas.drawOval(Rect.fromLTWH(120, 40, 100, 100), paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}

class SineWavePainter extends CustomPainter {
  var offset;
  SineWavePainter({this.offset});
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black;

    // Draw Rect
    canvas.drawRect(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), paint);

    // Red painter
    final redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    // Draw sine wave
    var amp = (size.height - 20) / 2.0;
    var yoffset = 10.0 + (size.height - 20) / 2.0;
    var dx1 = 10.0;
    var dy1 = yoffset + amp * math.sin(offset + 0.0);
    var dx2 = 10.0 + (size.width - 20.0) / 100.0;
    var dy2 = yoffset + amp * math.sin(offset + 2.0 * math.pi / 100.0);

    for (var i = 0; i < 100; i++) {
      canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), redPaint);
      dx1 = 10.0 + i * (size.width - 20.0) / 100.0;
      dx2 = 10.0 + (i + 1) * (size.width - 20.0) / 100.0;
      dy1 = yoffset + amp * math.sin(offset + 2.0 * math.pi * i / 100.0);
      dy2 = yoffset + amp * math.sin(offset + 2.0 * math.pi * (i + 1) / 100.0);
    }
  }

  @override
  bool shouldRepaint(SineWavePainter oldDelegate) => false;
}

// Draw CTG with heart rate array
class CTGGridView extends StatefulWidget {
  final List<double> mHR;
  final List<double> fHR;
  CTGGridView({this.mHR, this.fHR});
  @override
  State<StatefulWidget> createState() {
    return _CTGGridState(mHR: mHR, fHR: fHR);
  }
}

class _CTGGridState extends State<CTGGridView> {
  final List<double> mHR;
  final List<double> fHR;
  _CTGGridState({this.mHR, this.fHR});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CustomPaint(
        painter: CTGGridPainter(mHR: mHR, fHR: fHR),
        size: Size(MediaQuery.of(context).size.width * 3,
            MediaQuery.of(context).size.height / 3),
      ),
    );
  }
}

// CTGGrid
class CTGGridPainter extends CustomPainter {
  List<double> mHR;
  List<double> fHR;
  CTGGridPainter({this.mHR, this.fHR});

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
  bool shouldRepaint(CTGGridPainter oldDelegate) => false;
}

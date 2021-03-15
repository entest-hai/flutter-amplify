import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 's3.dart';
import 'ctg_realtime_cubit.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class BeatView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BeatState();
  }
}

class _BeatState extends State<BeatView> {
  Timer myTimer;
  int counter = 0;
  @override
  Widget build(BuildContext context) {
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

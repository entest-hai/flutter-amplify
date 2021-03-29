import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// heartrate cubit
import 'heartrate_cubit.dart';
import 'heartrate_state.dart';
// acceleration
import 'acceleration.dart';
// deceleration
import 'deceleration.dart';
// annotation cubit
import 'annotation_cubit.dart';
// annotation state
import 'annotation_state.dart';

final macels = [
  Acceleration(start: 3, duration: 1.0),
  Acceleration(start: 7.2, duration: 1.5),
  Acceleration(start: 9.5, duration: 1.5),
  Acceleration(start: 11.2, duration: 1.0),
  Acceleration(start: 18.0, duration: 1.0),
  Acceleration(start: 21.0, duration: 2.0),
  Acceleration(start: 24.5, duration: 1.0),
];

final mdecels = [
  // Deceleration(start: 20, duration: 1.0),
  // Deceleration(start: 35, duration: 2.0),
  // Deceleration(start: 45, duration: 3.0),
  Deceleration(start: 55, duration: 1.0),
];

class CustomSliderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => HeartRateCubit()..loadHeartRateFromFile())
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("CTG View Slider"),
        ),
        body: CustomSliderView(
          onChanged: (value) {
            print("on change $value");
          },
          // acels: macels,
          // decels: mdecels,
        ),
      ),
    ));
  }
}

// Slidding Window and ACC Mark Painter
class CustomSliderView extends StatefulWidget {
  // final List<Acceleration> acels;
  // final List<Deceleration> decels;
  final int numMinute;
  final double sliderWidth;
  final double sliderHeight;
  final Color color;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  CustomSliderView({
    // this.acels,
    // this.decels,
    this.numMinute = 60,
    this.sliderWidth = 400.0,
    this.sliderHeight = 45.0,
    this.color = Colors.black,
    this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomSliderState();
  }
}

// Slidding Window and ACC Mark Painter
class _CustomSliderState extends State<CustomSliderView> {
  double _dragPosition = 0.0;
  double _dragPercentage = 0.0;

  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AnnotationCubit, AnnotationState>(
            builder: (context, state) {
          if (state is LoadingHeartRate) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AnnotationLoadedHeartRate) {
            return SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                // painter: CTGGridPainterTest(),
                painter: ACCGridPainter(
                    numMinuteLine: 60,
                    acels: state.accels,
                    decels: state.decels,
                    mHR: state.mHR,
                    fHR: state.fHR),
                size: Size(MediaQuery.of(context).size.width * 6, 300),
              ),
            );
          } else if (state is AnnotationAdded) {
            print(state.accels.length);
            return SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                // painter: CTGGridPainterTest(),
                painter: ACCGridPainter(
                    numMinuteLine: 60,
                    acels: state.accels,
                    decels: state.decels,
                    mHR: state.mHR,
                    fHR: state.fHR),
                size: Size(MediaQuery.of(context).size.width * 6, 300),
              ),
            );
          } else {
            return Container(
              child: Center(
                child: Text("Exception"),
              ),
            );
          }
        }),
        BlocBuilder<AnnotationCubit, AnnotationState>(
            builder: (context, state) {
          return GestureDetector(
            child: Stack(
              children: [
                CustomPaint(
                  painter: SliderPainter(
                      width: widget.sliderWidth / widget.numMinute * 10,
                      height: widget.sliderHeight + 6,
                      margin: 3,
                      maxWidth: widget.sliderWidth,
                      color: Colors.blue,
                      dragPercentage: _dragPercentage,
                      sliderPosition: _dragPosition),
                ),
                if (state is AnnotationAdded)
                  CustomPaint(
                    painter: CTGPainter(
                        acels: state.accels,
                        decels: state.decels,
                        numMinute: widget.numMinute,
                        width: widget.sliderWidth,
                        height: widget.sliderHeight),
                  )
                else
                  CustomPaint(
                    painter: CTGPainter(
                        acels: [],
                        decels: [],
                        numMinute: widget.numMinute,
                        width: widget.sliderWidth,
                        height: widget.sliderHeight),
                  ),
                Container(
                  color: Colors.grey.withOpacity(0.1),
                  height: widget.sliderHeight,
                  width: widget.sliderWidth,
                ),
              ],
            ),
            onHorizontalDragUpdate: (DragUpdateDetails update) =>
                _onDragUpdate(context, update),
            onHorizontalDragStart: (DragStartDetails start) =>
                _onDragStart(context, start),
            onHorizontalDragEnd: (DragEndDetails end) =>
                _onDragEnd(context, end),
          );
        })
      ],
    );
  }

  _handleChanged(double val, double ctgPaperWidth) {
    assert(widget.onChanged != null);
    widget.onChanged(val);

    //
    _scrollController.animateTo(_dragPercentage * ctgPaperWidth,
        duration: Duration(microseconds: 10), curve: Curves.ease);
  }

  _handleChangeStart(double val) {
    // assert(widget.onChangeStart != null);
    // widget.onChangeStart(val);
  }

  _handleChangeEnd(double val) {
    // assert(widget.onChangeEnd != null);
    // widget.onChangeEnd(val);
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(start.globalPosition);
    _updateDragPosition(offset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(update.globalPosition);
    _updateDragPosition(offset);
    _handleChanged(
        _dragPercentage, MediaQuery.of(context).size.width * 6.0 - 20.0);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    setState(() {});
    _handleChangeEnd(_dragPercentage);
  }

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0;
    if (val.dx <= 0) {
      newDragPosition = 0;
    } else if (val.dx >= widget.sliderWidth) {
      newDragPosition = widget.sliderWidth;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.sliderWidth;
    });
  }
}

// Slidding Window Painter
class SliderPainter extends CustomPainter {
  final double margin;
  final double width;
  final double height;
  final double maxWidth;
  final double sliderPosition;
  final double dragPercentage;
  final Color color;
  final Paint wavePainter;

  SliderPainter({
    this.margin,
    this.width,
    this.height,
    this.maxWidth,
    this.sliderPosition,
    this.dragPercentage,
    this.color,
  }) : wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBlock(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  _paintBlock(Canvas canvas, Size size) {
    Rect sliderRect = Offset(sliderPosition - width / 4, size.height - margin) &
        Size(width, height);
    canvas.drawRect(sliderRect, wavePainter);
  }
}

// ACC Mark Mark Painter
class CTGPainter extends CustomPainter {
  final List<Acceleration> acels;
  final List<Deceleration> decels;
  final int numMinute;
  final double width;
  final double height;
  CTGPainter(
      {this.acels, this.decels, this.numMinute, this.width, this.height});
  @override
  void paint(Canvas canvas, Size size) {
    //
    final minuteWidth = width / numMinute;

    final rectPainter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Draw rect
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), rectPainter);

    // Draw accelerations
    final acelPainter = Paint()
      ..color = Colors.green.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    for (var acel in acels) {
      canvas.drawRect(
          Rect.fromLTWH(
              acel.start * minuteWidth, 0, acel.duration * minuteWidth, height),
          acelPainter);
    }

    // Draw deceleration
    final decelPainter = Paint()
      ..color = Colors.red.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    for (var decel in decels) {
      canvas.drawRect(
          Rect.fromLTWH(decel.start * minuteWidth, 0,
              decel.duration * minuteWidth, height),
          decelPainter);
    }
  }

  @override
  bool shouldRepaint(CTGPainter oldDelegate) {
    return (acels != oldDelegate.acels) || (decels != oldDelegate.decels);
  }
}

// CTG Painter
class CTGGridPainterTest extends CustomPainter {
  final int numMinute;
  CTGGridPainterTest({this.numMinute = 60});
  @override
  void paint(Canvas canvas, Size size) {
    // Minute To Width
    final minuteWidth = size.width / numMinute;

    // Draw CTG Paper Border
    Paint rectPainter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), rectPainter);

    // Draw One Minute Mark
    Paint minutePainter = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    for (var i = 0; i < numMinute / 5; i++) {
      canvas.drawRect(
          Rect.fromLTWH(10 + i * 5.0 * minuteWidth, 10,
              size.width / (2 * numMinute), size.height - 20),
          minutePainter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//
// CTGGrid
class ACCGridPainter extends CustomPainter {
  final numMinuteLine;
  final List<Acceleration> acels;
  final List<Deceleration> decels;
  final List<double> mHR;
  final List<double> fHR;
  ACCGridPainter(
      {this.numMinuteLine = 60, this.acels, this.decels, this.mHR, this.fHR});

  void paint(Canvas canvas, Size size) {
    // minuteWidth
    final minuteWidth = (size.width - 20) / numMinuteLine;

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
    for (var i = 0; i < numMinuteLine; i++) {
      var xOffset = 10.0 + i * (size.width - 20) / numMinuteLine;
      canvas.drawLine(
          Offset(xOffset, 10.0), Offset(xOffset, size.height - 10), stickPaint);
    }

    // Draw time vertical line x10minute mark
    final tenMinutePain = Paint()..color = Colors.black.withOpacity(0.1);
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(
          Rect.fromLTWH(10.0 + i * (size.width - 20) / 6, 10,
              0.5 * (size.width - 20) / numMinuteLine, size.height - 20),
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
      if ((mHR[i] > 0) & (mHR[i + 1] > 0)) {
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
      if ((fHR[i] > 0) & (fHR[i + 1] > 0)) {
        canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), fHRPaint);
      }
    }

    // Accels Mark
    final acelPaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    for (var acel in acels) {
      canvas.drawRect(
          Rect.fromLTWH(10.0 + acel.start * minuteWidth, 10,
              acel.duration * minuteWidth, size.height - 20),
          acelPaint);
    }

    // Decels Mark
    final decelPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    for (var decel in decels) {
      canvas.drawRect(
          Rect.fromLTWH(10.0 + decel.start * minuteWidth, 10,
              decel.duration * minuteWidth, size.height - 20),
          decelPaint);
    }
  }

  double heartRateToYAxis(double heartrate, double height) {
    final minHR = 30.0;
    final maxHR = 240.0;
    final dy = height / (maxHR - minHR);
    return 10.0 + (maxHR - heartrate) * dy;
  }

  @override
  bool shouldRepaint(ACCGridPainter oldDelegate) {
    return true;
  }
}

// Accel and Decel Model

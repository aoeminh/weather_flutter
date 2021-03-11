import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';

import 'animated_state.dart';
const double _iconSunSize = 20;
const double _iconSunMargin = 8;
const double _height = 150;
const double _width = 300;

class SunPathWidget extends StatefulWidget {
  final int sunrise;
  final int sunset;

  const SunPathWidget({Key key, this.sunrise, this.sunset}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SunPathWidgetState();
}

class _SunPathWidgetState extends AnimatedState<SunPathWidget> {
  double _fraction = 0.0;
  List<double> _fractions = List();
  ImageInfo imageInfo;
  BehaviorSubject<ImageInfo> _behaviorSubject = BehaviorSubject();

  @override
  void initState() {
    super.initState();
    animateTween(duration: 5000);
    _fractions.add(_fraction);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() async{
    imageInfo = await getImageInfo();
    _behaviorSubject.add(imageInfo);
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageInfo>(
      stream: _behaviorSubject.stream,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return Stack(
            children: [
              Container(
                  margin: EdgeInsets.only(top: margin),
                  width: _width,
                  height: _height,
                  child: ClipPath(
                    child: Container(
                      color: Colors.yellow.withOpacity(0.6),
                      width: _width,
                      height: _height,
                    ),
                    clipper: _SunPathCliper(widget.sunrise, widget.sunset, _fraction),
                  )),
              Container(
                  margin: EdgeInsets.only(top: margin),
                  width: _width,
                  height: _height,
                  child: CustomPaint(
                    painter:
                    _SunPathPainter(widget.sunrise, widget.sunset, _fraction,snapshot.data),
                  )),
            ],
          );
        }
        return Container();
        }

    );
  }

  Future<ImageInfo> getImageInfo() async {
    AssetImage assetImage = AssetImage(mIconLittleSun);
    ImageStream stream =
    assetImage.resolve(createLocalImageConfiguration(context));
    Completer<ImageInfo> completer = Completer();
    stream.addListener(ImageStreamListener((imageInfo, _) {
      return completer.complete(imageInfo);
    }));
    return completer.future;
  }

  @override
  void dispose() {
    super.dispose();
    _behaviorSubject.close();
  }

  @override
  void onAnimatedValue(double value) {
    setState(() {
      _fraction = value;
    });
  }
}

class _SunPathPainter extends CustomPainter {
  final double fraction;
  final double pi = 3.14159;
  final int dayAsMs = 86400000;
  final int sunrise;
  final int sunset;
  final ImageInfo imageInfo;

  _SunPathPainter(this.sunrise, this.sunset, this.fraction, this.imageInfo);

  @override
  void paint(Canvas canvas, Size size) {
    Paint arcPaint = _getArcPaint();
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, true, arcPaint);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(_getPosition(fraction).dx-_iconSunMargin, _getPosition(fraction).dy-_iconSunMargin,
          _iconSunSize, _iconSunSize),
      image: imageInfo.image, // <- the loaded image
      filterQuality: FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_SunPathPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }

  Paint _getArcPaint() {
    Paint paint = Paint();
      paint..color = Colors.yellow[100];
      paint..strokeWidth = 0.5;
      paint..style = PaintingStyle.stroke;
    return paint;
  }

  Paint _getCirclePaint() {
    Paint circlePaint = Paint();
    circlePaint..color = Colors.yellow;
    return circlePaint;
  }


  Offset _getPosition(fraction) {
    int now = DateTime.now().millisecondsSinceEpoch;
    double difference = 0;
    difference = (now - sunrise) / (sunset - sunrise);
    var x = _width/2 * cos((1 + difference * fraction) * pi) + _width/2;
    var y = _height * sin((1 + difference * fraction) * pi) + _height;
    return Offset(x, y);
  }
}

class _SunPathCliper extends CustomClipper<Path> {
  final double fraction;
  final double pi = 3.14159;
  final int dayAsMs = 86400000;
  final int sunrise;
  final int sunset;

  _SunPathCliper(this.sunrise, this.sunset, this.fraction);

  @override
  Path getClip(Size size) {
    Path path = Path();
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    path.arcTo(rect, pi, (pi * _getDifferent() * fraction), true);
    path.lineTo(_getPosition(fraction).dx, size.height);
    path.lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(_SunPathCliper oldClipper) {
    return oldClipper.fraction != fraction;
  }

  double _getDifferent() {
    int now = DateTime.now().millisecondsSinceEpoch;
    return (now - sunrise) / (sunset - sunrise);
  }

  Offset _getPosition(fraction) {
    double difference = 0;
    difference = _getDifferent();
    var x = _width/2 * cos((1 + difference * fraction) * pi) + _width/2;
    var y = _height * sin((1 + difference * fraction) * pi) + _height;
    return Offset(x, y);
  }
}

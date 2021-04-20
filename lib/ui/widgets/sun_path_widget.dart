import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/constant.dart';

import 'animated_state.dart';

const double _iconSunSize = 20;
const double _iconSunMargin = 8;
const double _height = 150;
const double _width = 300;

class SunPathWidget extends StatefulWidget {
  final int sunrise;
  final int sunset;
  final int differentTime;

  const SunPathWidget({Key key, this.sunrise, this.sunset, this.differentTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SunPathWidgetState();
}

class _SunPathWidgetState extends AnimatedState<SunPathWidget> {
  ImageInfo imageInfo;
  BehaviorSubject<ImageInfo> _behaviorSubject = BehaviorSubject();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() async {
    imageInfo = await getImageInfo();
    _behaviorSubject.add(imageInfo);
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<ImageInfo>(
        stream: _behaviorSubject.stream,
        builder: (context, imageSnapshot) {
          if (imageSnapshot.hasData) {
            if(this.mounted){
              animateTween(duration: 3000);
            }
            return StreamBuilder<double>(
              stream: animatedStream,
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
                            clipper: _SunPathCliper(widget.sunrise, widget.sunset,
                                snapshot.data, widget.differentTime),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: margin),
                          width: _width,
                          height: _height,
                          child: CustomPaint(
                            painter: _SunPathPainter(widget.sunrise, widget.sunset,
                                snapshot.data, imageSnapshot.data, widget.differentTime),
                          )),
                    ],
                  );
                }
                return Container();
              }
            );

          }
          return Container();
        });
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

}

class _SunPathPainter extends CustomPainter {
  final double fraction;
  final double pi = 3.14159;
  final int dayAsMs = 86400000;
  final int sunrise;
  final int sunset;
  final int differentTime;
  final ImageInfo imageInfo;

  _SunPathPainter(this.sunrise, this.sunset, this.fraction, this.imageInfo,
      this.differentTime);

  @override
  void paint(Canvas canvas, Size size) {
    Paint arcPaint = _getArcPaint();
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, true, arcPaint);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
          _getPosition(fraction).dx - _iconSunMargin,
          _getPosition(fraction).dy - _iconSunMargin,
          _iconSunSize,
          _iconSunSize),
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

  Offset _getPosition(fraction) {
    int now = DateTime.now().millisecondsSinceEpoch +
        differentTime * oneHourMilli;

    double difference = 0;

    if (now < sunrise) {
      difference = 0;
    } else if (now > sunset) {
      difference = 1;
    } else {
      difference = (now - sunrise) / (sunset - sunrise);
    }

    var x = _width / 2 * cos((1 + difference * fraction) * pi) + _width / 2;
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
  final int differentTime;

  _SunPathCliper(this.sunrise, this.sunset, this.fraction, this.differentTime);

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
    int now = DateTime.now().millisecondsSinceEpoch +
        differentTime * oneHourMilli;
    if (now < sunrise) {
      return 0;
    } else if (now > sunset) {
      return 1;
    } else {
      return (now - sunrise) / (sunset - sunrise);
    }
  }

  Offset _getPosition(fraction) {
    double difference = 0;
    difference = _getDifferent();
    var x = _width / 2 * cos((1 + difference * fraction) * pi) + _width / 2;
    var y = _height * sin((1 + difference * fraction) * pi) + _height;
    return Offset(x, y);
  }
}

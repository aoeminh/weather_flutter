import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/setting_bloc.dart';
import '../../model/chart_data.dart';
import '../../model/chart_line.dart';
import '../../model/point.dart';
import '../../shared/image.dart';
import '../../utils/utils.dart';

import 'animated_state.dart';

const humidityIconWidth = 15;
const humidityIconHeight = 15;
const marginBottomTemp = 24;
const marginLeftTemp = 8;

const double _marginLeftHumidity = 16;
const double _iconHumiditySize = 14;

const double _marginLeftIconWeather = 15;
const double _marginTopIconWeather = -60;
const double _iconWeatherSize = 30;

const double _marginLeftDateTimes = 18;
const double _marginTopDateTimes = 80;
const double _textSize = 12;

class ChartWidget extends StatefulWidget {
  final ChartData chartData;

  const ChartWidget({Key key, this.chartData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  double _fraction = 0.0;
  ui.Image image;
  ImageInfo imageInfo;
  List<ImageInfo> weatherImagesInfo;
  BehaviorSubject<ImageInfo> humidityBehaviorSubject = BehaviorSubject();
  BehaviorSubject<List<ImageInfo>> weatherImageInfoSubject = BehaviorSubject();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    humidityBehaviorSubject.close();
    weatherImageInfoSubject.close();
  }

  @override
  void initState() {
    super.initState();
    init();
    settingBloc.settingStream.listen((event) {
      setState(() {
      });
    });
  }

  Future<Null> init() async {
    await Future.delayed(Duration(seconds: 1));
    imageInfo = await getImageInfo(context, mIcPrecipitationWhite);
    humidityBehaviorSubject.add(imageInfo);

    weatherImagesInfo = await getListIcon(widget.chartData.iconCode);
    weatherImageInfoSubject.add(weatherImagesInfo);
  }

  Future<List<ImageInfo>> getListIcon(List<String> iconCode) async {
    List<ImageInfo> list = [];
    for (String code in iconCode) {
      ImageInfo image = await getImageInfo(context, getIconForecastUrl(code));
      list.add(image);
    }
    return list;
  }


  Future<ImageInfo> getImageInfo(BuildContext context, String imagePath) async {
    AssetImage assetImage = AssetImage(imagePath);
    ImageStream stream =
        assetImage.resolve(createLocalImageConfiguration(context));
    Completer<ImageInfo> completer = Completer();
    stream.addListener(ImageStreamListener((imageInfo, _) {
      return completer.complete(imageInfo);
    }));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Widget chartWidget;
    if (widget.chartData.points.length < 3) {
      chartWidget = _getChartUnavailableWidget(context);
    } else {
      chartWidget = _getChartWidget();
    }

    return Container(
      key: Key("chart_widget_container"),
      width: widget.chartData.width,
      height: widget.chartData.height,
      child: chartWidget,
    );
  }

  Widget _getChartWidget() {
    return StreamBuilder<Object>(
        stream: Rx.combineLatest2(
            humidityBehaviorSubject.stream,
            weatherImageInfoSubject.stream,
            (ImageInfo humidity, List<ImageInfo> weatherIcons) =>
                ImageInfoWeather(humidity, weatherIcons)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ImageInfoWeather imageInfoWeather = snapshot.data;
            return Container(
              margin: EdgeInsets.only(top: 25),
              child: CustomPaint(
                  key: Key("chart_widget_custom_paint"),
                  painter: _ChartPainter(
                      widget.chartData.points,
                      widget.chartData.pointLabels,
                      widget.chartData.width,
                      widget.chartData.height,
                      widget.chartData.axes,
                      _fraction,
                      imageInfoWeather.humidityInfo,
                      widget.chartData.dateTimeLabels,
                      imageInfoWeather.weatherIconsInfo,
                      widget.chartData.maxTempIndex,
                      widget.chartData.minTempIndex)),
            );
          } else {
            return Container();
          }
        });
  }

  Widget _getChartUnavailableWidget(BuildContext context) {
    return Center(
        key: Key("chart_widget_unavailable"),
        child: Text('ssssss',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headline1));
  }



}

class _ChartPainter extends CustomPainter {
  _ChartPainter(
      this.points,
      this.pointLabels,
      this.width,
      this.height,
      this.axes,
      this.fraction,
      this.imageInfo,
      this.dateTimeLabels,
      this.iconImage,
      this.maxTempIndex,
      this.minTempIndex);

  final List<Point> points;
  final List<String> pointLabels;
  final double width;
  final double height;
  final List<ChartLine> axes;
  final double fraction;
  final ImageInfo imageInfo;
  final List<ImageInfo> iconImage;
  final List<String> dateTimeLabels;
  final int maxTempIndex;
  final int minTempIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (iconImage != null) {
      _drawIconList(canvas);
    }
    _drawDateTimes(canvas);
    for (int index = 0; index < points.length; index++) {
      Offset textOffset = Offset(
          points[index].x - marginLeftTemp, points[index].y - marginBottomTemp);
      _drawLine(canvas, index);
      if (index == maxTempIndex) {
        _drawTempText(canvas, textOffset, pointLabels[index],
             true,
            isMax: true);
      } else if (index == minTempIndex) {
        _drawTempText(canvas, textOffset, pointLabels[index],
             true,
            isMin: true);
      } else {
        _drawTempText(canvas, textOffset, pointLabels[index], true);
      }
    }
    if (fraction > 0.999) {
      Offset textOffset = Offset(points[points.length - 1].x - marginLeftTemp,
          points[points.length - 1].y - marginBottomTemp);
      _drawTempText(
          canvas, textOffset, pointLabels[points.length - 1], true);
    }
    _drawAxes(canvas);
  }

  _drawLine(Canvas canvas, int index){
    Paint paint = _getLinePaint(Colors.blue, 2);
    if(index<points.length-1){
      canvas.drawLine(_getOffsetFromPoint(points[index]),
          _getOffsetFromPoint(points[index+1]), paint);
    }
  }

  void _drawText(Canvas canvas, Offset offset, String text,
      double alphaFraction, bool textShadow) {
    TextStyle textStyle = _getTextStyle(alphaFraction, textShadow);
    TextSpan textSpan = TextSpan(style: textStyle, text: text);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  void _drawTempText(Canvas canvas, Offset offset, String text,
       bool textShadow,
      {bool isMax = false, bool isMin = false}) {
    _drawRectangle(canvas, offset, isMax: isMax, isMin: isMin);
    TextStyle textStyle =
        TextStyle(color: Colors.white, fontSize: _textSize, letterSpacing: 0);

    TextSpan textSpan = TextSpan(style: textStyle, text: text);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  _drawRectangle(Canvas canvas, Offset offset,
      {bool isMax = false, bool isMin = false}) {
    Color color;
    if (isMax) {
      color = Colors.orange;
    } else if (isMin) {
      color = Color(0xff638965);
    } else {
      color = Colors.green;
    }
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    //a rectangle
    var height = 18;
    var width = 24;
    var newDx = offset.dx - 4;
    var newDy = offset.dy - 2;
    var marginQuadraticBezier = 1;
    var marginConner = 2;

    var path = Path();
    path.moveTo(newDx, newDy + marginConner);
    path.lineTo(newDx, newDy + (height - marginConner));
    path.quadraticBezierTo(
        newDx + marginQuadraticBezier,
        newDy + (height - marginQuadraticBezier),
        newDx + marginConner,
        newDy + height);

    path.lineTo(newDx + (width / 2) - 4, newDy + height);
    path.lineTo(newDx + (width / 2), newDy + height + 4);
    path.lineTo(newDx + (width / 2) + 4, newDy + height);
    path.lineTo(newDx + (width - marginConner), newDy + height);

    path.quadraticBezierTo(
        newDx + (width - marginQuadraticBezier),
        newDy + (height - marginQuadraticBezier),
        newDx + width,
        newDy + (height - marginConner));
    path.lineTo(newDx + width, newDy + marginConner);
    path.quadraticBezierTo(newDx + (width - marginQuadraticBezier),
        newDy + marginQuadraticBezier, newDx + (width - marginConner), newDy);
    path.lineTo(newDx + marginConner, newDy);
    path.quadraticBezierTo(newDx + marginQuadraticBezier,
        newDy + marginQuadraticBezier, newDx, newDy + marginConner);

    canvas.drawPath(path, paint);
  }

  void _drawHumidity(Offset offset, Canvas canvas) async {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(offset.dx - _marginLeftHumidity, offset.dy,
          _iconHumiditySize, _iconHumiditySize),
      image: imageInfo.image, // <- the loaded image
      filterQuality: FilterQuality.high,
    );
  }

  void _drawIcon(Offset offset, Canvas canvas, ImageInfo image) async {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
          offset.dx, offset.dy, _iconWeatherSize, _iconWeatherSize),
      image: image.image, // <- the loaded image
      filterQuality: FilterQuality.high,
    );
  }

  void _drawIconList(Canvas canvas) {
    for (int i = 0; i < iconImage.length; i++) {
      Offset offset =
          Offset(points[i].x - _marginLeftIconWeather, _marginTopIconWeather);
      _drawIcon(offset, canvas, iconImage[i]);
    }
  }

  void _drawDateTimes(Canvas canvas) async {
    for (int index = 0; index < dateTimeLabels.length; index++) {
      Offset offset =
          Offset(points[index].x - _marginLeftDateTimes, -_marginTopDateTimes);
      TextStyle textStyle = _getTextStyle(1, false);
      TextSpan textSpan =
          TextSpan(style: textStyle, text: dateTimeLabels[index]);
      TextPainter textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }
  }

  TextStyle _getTextStyle(double alphaFraction, bool textShadow) {
    if (textShadow) {
      return new TextStyle(
        color: Colors.white,
        fontSize: _textSize,
        letterSpacing: 0,
      );
    } else {
      return new TextStyle(
          color: Colors.white, fontSize: _textSize, letterSpacing: 0);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return true;
  }

  Offset _getOffsetFromPoint(Point point) {
    return Offset(point.x, point.y);
  }

  void _drawAxes(Canvas canvas) async {
    Paint axesPaint = _getLinePaint(Colors.white30, 1);

    if (axes != null) {
      for (ChartLine lineAxis in axes) {
        var dashWidth = 3;
        var dashSpace = 3;
        double starty = lineAxis.lineStartOffset.dy;
        final space = (dashSpace + dashWidth);
        while (starty > lineAxis.lineEndOffset.dy) {
          canvas.drawLine(Offset(lineAxis.lineStartOffset.dx, starty),
              Offset(lineAxis.lineEndOffset.dx, starty - dashWidth), axesPaint);
          starty -= space;
        }
        _drawCirclePoint(canvas,
            Offset(lineAxis.lineStartOffset.dx, lineAxis.lineEndOffset.dy));
        _drawText(canvas, lineAxis.textOffset, lineAxis.label, 1, false);
        _drawHumidity(lineAxis.textOffset, canvas);
      }
      _buildBottomLine(canvas, axesPaint);
    }
  }

  _drawCirclePoint(Canvas canvas, Offset offset) {
    Paint whitePaint = Paint();
    whitePaint.color = Colors.white;
    whitePaint..strokeWidth = 1;
    whitePaint..style = PaintingStyle.stroke;
    canvas.drawCircle(offset, 2, whitePaint);
  }

  _buildBottomLine(Canvas canvas, Paint paint) {
    var dashWidth = 3;
    var dashSpace = 3;
    double startX = 0;
    final space = (dashSpace + dashWidth);
    while (startX < width) {
      canvas.drawLine(
          Offset(startX, height), Offset(startX + dashWidth, height), paint);
      startX += space;
    }
  }

  Paint _getLinePaint(Color color, double strokeWidth) {
    Paint paint = Paint();
    paint.color = color;
    paint..strokeWidth = strokeWidth;
    paint..style = PaintingStyle.stroke;
    return paint;
  }
}

class ImageInfoWeather {
  final ImageInfo humidityInfo;
  final List<ImageInfo> weatherIconsInfo;

  ImageInfoWeather(this.humidityInfo, this.weatherIconsInfo);
}

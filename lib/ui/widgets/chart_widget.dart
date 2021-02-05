import 'package:flutter/material.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/chart_line.dart';
import 'package:weather_app/model/point.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/utils/utils.dart';
import 'animated_state.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:image/image.dart' as images;

const humidityIconWidth = 15;
const humidityIconHeight = 15;
const marginBottomTemp = 20;
const marginLeftTemp = 5;

class ChartWidget extends StatefulWidget {
  final ChartData chartData;

  const ChartWidget({Key key, this.chartData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends AnimatedState<ChartWidget> {
  double _fraction = 0.0;
  ui.Image image;
  List<ui.Image> iconImage;

  @override
  void initState() {
    super.initState();
    init();
    animateTween(duration: 500, curve: Curves.linear);
  }

  bool isImageLoaded = false;
  bool isIconImageLoaded = false;

  Future<Null> init() async {
    image = await loadImage(
        mIcPrecipitationWhite, humidityIconWidth, humidityIconHeight);
    setState(() {
      isImageLoaded = true;
    });
    iconImage = await getListIcon(widget.chartData.iconCode);
    setState(() {
      isIconImageLoaded = true;
    });
  }

  Future<List<ui.Image>> getListIcon(List<String> iconCode) async {
    List<ui.Image> list = List();
    for (String code in iconCode) {
      ui.Image image = await loadImage(getIconForecastUrl(code), 20, 20);
      list.add(image);
    }
    return list;
  }

  Future<ui.Image> loadImage(String imageUrl, int width, int height) async {
    final ByteData data = await rootBundle.load(imageUrl);
    images.Image baseSizeImage =
        images.decodeImage(new Uint8List.view(data.buffer));
    images.Image resizeImage =
        images.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec =
        await ui.instantiateImageCodec(images.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
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
    return CustomPaint(
        key: Key("chart_widget_custom_paint"),
        painter: _ChartPainter(
          widget.chartData.points,
          widget.chartData.pointLabels,
          widget.chartData.width,
          widget.chartData.height,
          widget.chartData.axes,
          _fraction,
          isImageLoaded ? image : null,
          widget.chartData.dateTimeLabels,
          isIconImageLoaded ? iconImage : null,
        ));
  }

  Widget _getChartUnavailableWidget(BuildContext context) {
    return Center(
        key: Key("chart_widget_unavailable"),
        child: Text('ssssss',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headline1));
  }

  @override
  void onAnimatedValue(double value) {
    setState(() {
      _fraction = value;
    });
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
      this.image,
      this.dateTimeLabels,
      this.iconImage);

  final List<Point> points;
  final List<String> pointLabels;
  final double width;
  final double height;
  final List<ChartLine> axes;
  final double fraction;
  final ui.Image image;
  final List<ui.Image> iconImage;
  final List<String> dateTimeLabels;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = _getLinePaint(Colors.blue, 2);
    _drawAxes(canvas);
    if (iconImage != null) {
      _drawIconList(canvas);
    }
    _drawDateTimes(canvas);
    double fractionLinePerPoint = 1 / points.length;

    int pointsFraction = (points.length * fraction).ceil();
    double lastLineFraction =
        fraction - (pointsFraction - 1) * fractionLinePerPoint;
    double lastLineFractionPercentage = lastLineFraction / (1 / points.length);
    for (int index = 0; index < pointsFraction - 1; index++) {
      Offset textOffset = Offset(
          points[index].x - marginLeftTemp, points[index].y - marginBottomTemp);
      if (index == pointsFraction - 2) {
        Point startPoint = points[index];
        Point endPoint = points[index + 1];
        Offset startOffset = _getOffsetFromPoint(startPoint);

        double diffX = endPoint.x - startPoint.x;
        double diffY = endPoint.y - startPoint.y;

        Offset endOffset = Offset(
            startPoint.x + diffX * lastLineFractionPercentage,
            startPoint.y + diffY * lastLineFractionPercentage);
        canvas.drawLine(startOffset, endOffset, paint);
        _drawText(canvas, textOffset, pointLabels[index + 1],
            lastLineFractionPercentage, true);
      } else {
        canvas.drawLine(_getOffsetFromPoint(points[index]),
            _getOffsetFromPoint(points[index + 1]), paint);
        _drawText(canvas, textOffset, pointLabels[index], 1, true);
      }
    }
    if (fraction > 0.999) {
      Offset textOffset = Offset(
          points[points.length - 1].x - 5, points[points.length - 1].y - 15);
      _drawText(canvas, textOffset, pointLabels[points.length - 1], 1, true);
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

  void _drawHumidity(Offset offset, Canvas canvas) async {
    canvas.drawImage(image, Offset(offset.dx - 20, offset.dy), Paint());
  }

  void _drawIcon(Offset offset, Canvas canvas, ui.Image image) async {
    canvas.drawImage(image, Offset(offset.dx - 20, offset.dy), Paint());
    print('_drawIcon');
  }

  void _drawDateTimes(Canvas canvas) async {
    for (int index = 0; index < dateTimeLabels.length; index++) {
      Offset offset = Offset(points[index].x - 20, -80);
      TextStyle textStyle = _getTextStyle(1, false);
      TextSpan textSpan =
          TextSpan(style: textStyle, text: dateTimeLabels[index]);
      TextPainter textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }
  }

  void _drawIconList(Canvas canvas) {
    for (int i = 0; i < iconImage.length; i++) {
      print('_drawIconList ${iconImage.length}');
      Offset offset = Offset(points[i].x + 10, -50);
      _drawIcon(offset, canvas, iconImage[i]);
    }
  }

  TextStyle _getTextStyle(double alphaFraction, bool textShadow) {
    if (textShadow) {
      return new TextStyle(
        color: Colors.white,
        fontSize: 12,
        letterSpacing: 0,
      );
    } else {
      return new TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
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

        _drawText(canvas, lineAxis.textOffset, lineAxis.label, 1, false);

        if (image != null) {
          _drawHumidity(lineAxis.textOffset, canvas);
        }
      }
      _buildBottomLine(canvas, axesPaint);
    }
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

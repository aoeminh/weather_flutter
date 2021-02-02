import 'package:flutter/material.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/chart_line.dart';
import 'package:weather_app/model/point.dart';

import 'animated_state.dart';

class ChartWidget extends StatefulWidget {
  final ChartData chartData;

  const ChartWidget({Key key, this.chartData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends AnimatedState<ChartWidget> {
  double _fraction = 0.0;

  @override
  void initState() {
    super.initState();
    animateTween(duration: 500, curve: Curves.linear);
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
            _fraction));
  }

  Widget _getChartUnavailableWidget(BuildContext context) {
    return Center(
        key: Key("chart_widget_unavailable"),
        child: Text('ssssss',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.body1));
  }

  @override
  void onAnimatedValue(double value) {
    setState(() {
      _fraction = value;
    });
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.points, this.pointLabels, this.width, this.height,
      this.axes, this.fraction);

  final List<Point> points;
  final List<String> pointLabels;
  final double width;
  final double height;
  final List<ChartLine> axes;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = _getLinePaint(Colors.blue, 2);
    _drawAxes(canvas);

    double fractionLinePerPoint = 1 / points.length;

    int pointsFraction = (points.length * fraction).ceil();
    double lastLineFraction =
        fraction - (pointsFraction - 1) * fractionLinePerPoint;
    double lastLineFractionPercentage = lastLineFraction / (1 / points.length);
    print(
        'lastLineFraction $lastLineFraction pointsFraction: $pointsFraction lastLineFractionPercentage: $lastLineFractionPercentage points.length: ${points.length} fraction $fraction');
    for (int index = 0; index < pointsFraction - 1; index++) {
      Offset textOffset = Offset(points[index].x - 5, points[index].y - 15);
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
        print(
            'index $index startOffset ${_getOffsetFromPoint(points[index])} endOffset ${_getOffsetFromPoint(points[index + 1])}');
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

  TextStyle _getTextStyle(double alphaFraction, bool textShadow) {
    Color color = Color.fromARGB((220 * alphaFraction).floor(), 255, 255, 255);
    if (textShadow) {
      return new TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: 0,
          shadows: [
            Shadow(offset: Offset(-1.0, -1.0), color: Colors.black),
            Shadow(offset: Offset(1.0, -1.0), color: Colors.black),
            Shadow(offset: Offset(1.0, 1.0), color: Colors.black),
            Shadow(offset: Offset(-1.0, 1.0), color: Colors.black),
          ]);
    } else {
      return new TextStyle(color: color, fontSize: 10, letterSpacing: 0);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }

  Offset _getOffsetFromPoint(Point point) {
    return Offset(point.x, point.y);
  }

  void _drawAxes(Canvas canvas) {
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
      }
      canvas.drawLine(
          Offset(0, height ), Offset(width, height), axesPaint);
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

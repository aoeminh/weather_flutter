import 'dart:math';
import 'dart:ui';

import 'package:weather_app/model/point.dart';
import 'package:weather_app/shared/dimensions.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/weather_helper.dart';

import 'chart_line.dart';
import 'weather_forecast_holder.dart';
import 'weather_forecast_response.dart';

const double marginTopHourLabel = 10;
const double marginRightHourLabel = 10;

class ChartData {
  List<Point> _points;
  List<String> _pointLabels;
  List<String> _dateTimeLabels;
  List<String> _labelsPops;
  List<String> _iconCodes;
  double _width;
  double _height;
  List<ChartLine> _axes;

  ChartData(
      WeatherForecastHolder holder,
      List<WeatherForecastResponse> forecastList,
      ChartDataType type,
      double width,
      double height) {
    setupChartData(holder, forecastList, type, width, height);
  }

  void setupChartData(
      WeatherForecastHolder holder,
      List<WeatherForecastResponse> forecastList,
      ChartDataType chartDataType,
      double width,
      double height) {
    List<double> values = _getChartValues(holder, chartDataType);
    print(chartDataType.toString() + " Values: " + values.toString());
    double averageValue = _getChartAverageValue(holder, chartDataType);
    this._points = _getPoints(values, averageValue, width, height);
    this._pointLabels = _getPointLabels(values);
    this._labelsPops =
        _getPointPops(holder.pops);
    List<DateTime> dateTimes = _getDateTimes(forecastList);
    this._dateTimeLabels = _getListDateTimeString(dateTimes);
    String mainAxisText = _getMainAxisText(chartDataType, averageValue);
    this._axes = _getAxes(_points, labelPops, height, width, mainAxisText);
    this._width = width;
    this._height = height;
    this._iconCodes = _getIconCodes(forecastList);
  }

  List<double> _getChartValues(
      WeatherForecastHolder holder, ChartDataType chartDataType) {
    List<double> dataSet;
    switch (chartDataType) {
      case ChartDataType.temperature:
        dataSet = holder.temperatures;
        // if (!applicationBloc.isMetricUnits()){
        //   dataSet = dataSet.map( (value) => WeatherHelper.convertCelsiusToFahrenheit(value)).toList();
        // }
        break;
      case ChartDataType.wind:
        dataSet = holder.winds;
        dataSet = dataSet
            .map((value) =>
                WeatherHelper.convertMetersPerSecondToMilesPerHour(value))
            .toList();
        // if (applicationBloc.isMetricUnits()){
        //   dataSet = dataSet.map((value) => WeatherHelper.convertMetersPerSecondToKilometersPerHour(value)).toList();
        // } else {
        //   dataSet = dataSet.map((value) => WeatherHelper.convertMetersPerSecondToMilesPerHour(value)).toList();
        // }
        break;
      case ChartDataType.rain:
        dataSet = holder.rains;
        break;
      case ChartDataType.pressure:
        dataSet = holder.pressures;
        break;
    }
    return dataSet;
  }

  double _getChartAverageValue(
      WeatherForecastHolder holder, ChartDataType chartDataType) {
    double averageValue;
    switch (chartDataType) {
      case ChartDataType.temperature:
        averageValue = holder.averageTemperature;
        // if (!applicationBloc.isMetricUnits()){
        //   averageValue = WeatherHelper.convertCelsiusToFahrenheit(averageValue);
        // }
        break;
      case ChartDataType.wind:
        averageValue = holder.averageWind;
        averageValue =
            WeatherHelper.convertMetersPerSecondToMilesPerHour(averageValue);
        // if (applicationBloc.isMetricUnits()){
        //   averageValue = WeatherHelper.convertMetersPerSecondToKilometersPerHour(averageValue);
        // } else {
        //   averageValue = WeatherHelper.convertMetersPerSecondToMilesPerHour(averageValue);
        // }
        break;
      case ChartDataType.rain:
        averageValue = holder.averageRain;
        break;
      case ChartDataType.pressure:
        averageValue = holder.averagePressure;
        break;
    }
    return averageValue;
  }

  List<Point> _getPoints(
      List<double> values, double averageValue, double width, double height) {
    List<Point> points = List();
    double halfHeight = (height - Dimensions.chartPadding) / 2;
    double widthStep = width / (values.length - 1);
    double currentX = 0;

    List<double> averageDifferenceValues =
        _getAverageDifferenceValues(values, averageValue);
    double maxValue = _getAbsoluteMax(averageDifferenceValues);

    for (double averageDifferenceValue in averageDifferenceValues) {
      var y = halfHeight - (halfHeight * averageDifferenceValue / maxValue);
      if (y.isNaN) {
        y = halfHeight;
      }
      points.add(Point(currentX, y));
      currentX += widthStep;
    }
    return points;
  }

  List<double> _getAverageDifferenceValues(
      List<double> values, double averageValue) {
    List<double> calculatedValues = new List();
    for (double value in values) {
      calculatedValues.add(value - averageValue);
    }
    return calculatedValues;
  }

  double _getAbsoluteMax(List<double> values) {
    double maxValue = 0;
    for (double value in values) {
      maxValue = max(maxValue, value.abs());
    }
    return maxValue;
  }

  List<String> _getPointLabels(List<double> values) {
    List<String> points = List();
    for (double value in values) {
      points.add('${value.toStringAsFixed(0)}$degree');
    }
    return points;
  }

  List<String> _getPointPops(List<double> values) {
    List<String> points = List();
    for (double value in values) {
      points.add('${value.toStringAsFixed(0)}$percent');
    }
    return points;
  }

  List<DateTime> _getDateTimes(List<WeatherForecastResponse> forecastList) {
    List<DateTime> dateTimes = new List();
    for (WeatherForecastResponse response in forecastList) {
      dateTimes.add(response.dateTime);
    }
    return dateTimes;
  }

  List<String> _getListDateTimeString(List<DateTime> dateTimes){
    List<String> list = List();
    for(DateTime dateTime in dateTimes){
      list.add(_getDateTimeLabel(dateTime));
    }
    return list;
  }

  List<ChartLine> _getAxes(List<Point> points, List<String> pops,
      double height, double width, String mainAxisText) {
    List<ChartLine> list = new List();

    for (int index = 0; index < points.length; index++) {
      Point point = points[index];
      list.add(ChartLine(
          pops[index],
          Offset(point.x , height + marginTopHourLabel),
          Offset(point.x, height),
          Offset(point.x, point.y)));
    }
    return list;
  }

  String _getDateTimeLabel(DateTime dateTime) {
    int hour = dateTime.hour;
    String hourText = "";
    if (hour < 10) {
      hourText = "0${hour.toString()}";
    } else {
      hourText = hour.toString();
    }
    return "${hourText.toString()}:00";
  }

  String _getMainAxisText(ChartDataType chartDataType, double averageValue) {
    String text;
    switch (chartDataType) {
      case ChartDataType.temperature:
        var temperature = averageValue;
        text = WeatherHelper.formatTemperature(
            temperature: temperature,
            positions: 1,
            round: false,
            metricUnits: true);
        break;
      case ChartDataType.wind:
        text = WeatherHelper.formatWind(averageValue);
        break;
      case ChartDataType.rain:
        text = "${averageValue.toStringAsFixed(1)} mm/h";
        break;
      case ChartDataType.pressure:
        text = WeatherHelper.formatPressure(averageValue);
    }
    return text;
  }
  
  List<String> _getIconCodes(List<WeatherForecastResponse> forecastList){
    List<String> list = List();
    for(WeatherForecastResponse weatherForecastResponse in forecastList){
      list.add(weatherForecastResponse.overallWeatherData[0].icon);
    }
    return list;
  }

  List<ChartLine> get axes => _axes;

  double get height => _height;

  double get width => _width;

  List<String> get pointLabels => _pointLabels;

  List<String> get labelPops => _labelsPops;

  List<String> get dateTimeLabels => _dateTimeLabels;
  
  List<String> get iconCode => _iconCodes;

  List<Point> get points => _points;

}

enum ChartDataType { temperature, wind, rain, pressure }
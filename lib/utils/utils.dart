import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:weather_app/model/system.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/image.dart';
import 'package:intl/intl.dart';

Image getIconForecastImage(String iconCode) {
  switch (iconCode) {
    case mClear:
      return Image.asset(mIconClears);
    case mClearN:
      return Image.asset(mIconClearsNight);
    case mFewClouds:
      return Image.asset(mIconFewCloudsDay);
    case mFewCloudsN:
      return Image.asset(mIconFewCloudsNight);
    case mClouds:
    case mCloudsN:
    case mBrokenClouds:
    case mBrokenCloudsN:
      return Image.asset(mIconBrokenClouds);
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return Image.asset(mIconRainy);
    case mthunderstorm:
    case mthunderstormN:
      return Image.asset(mIconThunderstorm);
    case mSnow:
    case mSnowN:
      return Image.asset(mIconSnow);
    case mist:
    case mistN:
      return Image.asset(mIconFog);
    default:
      return Image.asset(mIconClears);
  }
}

String getIconForecastUrl(String iconCode) {
  switch (iconCode) {
    case mClear:
      return mIconClears;
    case mClearN:
      return mIconClearsNight;
    case mFewClouds:
    case mClouds:
      return mIconFewCloudsDay;
    case mFewCloudsN:
    case mCloudsN:
      return mIconFewCloudsNight;
    case mBrokenClouds:
    case mBrokenCloudsN:
      return mIconBrokenClouds;
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return mIconRainy;
    case mthunderstorm:
    case mthunderstormN:
      return mIconThunderstorm;
    case mSnow:
    case mSnowN:
      return mIconSnow;
    case mist:
    case mistN:
      return mIconFog;
    default:
      return mIconClears;
  }
}

String getTimeLabel(DateTime dateTime) {
  int hour = dateTime.hour;
  String hourText = "";
  if (hour < 10) {
    hourText = "0${hour.toString()}";
  } else {
    hourText = hour.toString();
  }
  return "${hourText.toString()}:00";
}

String formatDate(DateTime dateTime) {
  final df = new DateFormat('EEE MM/dd');
  String date = df.format(dateTime);
  return date;
}

Map<String, List<WeatherForecastResponse>> mapForecastsForSameDay(
    List<WeatherForecastResponse> forecastList) {
  Map<String, List<WeatherForecastResponse>> map = new LinkedHashMap();
  for (int i = 0; i < forecastList.length; i++) {
    WeatherForecastResponse response = forecastList[i];
    String dayKey = _getDayKey(response.dateTime);
    if (!map.containsKey(dayKey)) {
      map[dayKey] = List<WeatherForecastResponse>();
    }
    map[dayKey].add(response);
  }
  return map;
}

String _getDayKey(DateTime dateTime) {
  return "${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}";
}

String formatTemperature(
    {double temperature, int positions = 0, round = true, metricUnits = true}) {
  var unit = "°C";

  if (!metricUnits) {
    unit = "°F";
  }

  if (round) {
    temperature = temperature.floor().toDouble();
  }

  return "${temperature.toStringAsFixed(positions)} $unit";
}

double convertCelsiusToFahrenheit(double temperature) {
  return 32 + temperature * 1.8;
}

double convertMetersPerSecondToKilometersPerHour(double speed) {
  if (speed != null) {
    return speed * 3.6;
  } else {
    return 0;
  }
}

double convertMetersPerSecondToMilesPerHour(double speed) {
  if (speed != null) {
    return speed * 2.236936292;
  } else {
    return 0;
  }
}

double convertFahrenheitToCelsius(double temperature) {
  return (temperature - 32) * 0.55;
}

String formatPressure(double pressure) {
  String unit = "hPa";

  unit = "mbar";

  return "${pressure.toStringAsFixed(0)} $unit";
}

String formatRain(double rain) {
  return "${rain.toStringAsFixed(2)} mm/h";
}

String formatWind(double wind) {
  String unit = "km/h";

  unit = "mi/h";

  return "${wind.toStringAsFixed(1)} $unit";
}

String formatHumidity(double humidity) {
  return "${humidity.toStringAsFixed(0)}%";
}

int getDayMode(System system) {
  int sunrise = system.sunrise * 1000;
  int sunset = system.sunset * 1000;
  return getDayModeFromSunriseSunset(sunrise, sunset);
}

int getDayModeFromSunriseSunset(int sunrise, int sunset) {
  int now = DateTime.now().millisecondsSinceEpoch;
  if (now >= sunrise && now <= sunset) {
    return 0;
  } else if (now >= sunrise) {
    return 1;
  } else {
    return -1;
  }
}

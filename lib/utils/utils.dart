import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/system.dart';
import 'package:weather_app/model/temp.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';

Image getIconForecastImage(String iconCode, {double width, double height}) {
  switch (iconCode) {
    case mClear:
      return Image.asset(
        mIconClears,
        width: width,
        height: height,
      );
    case mClearN:
      return Image.asset(
        mIconClearsNight,
        width: width,
        height: height,
      );
    case mFewClouds:
      return Image.asset(
        mIconFewCloudsDay,
        width: width,
        height: height,
      );
    case mFewCloudsN:
      return Image.asset(
        mIconFewCloudsNight,
        width: width,
        height: height,
      );
    case mClouds:
    case mCloudsN:
    case mBrokenClouds:
    case mBrokenCloudsN:
      return Image.asset(
        mIconBrokenClouds,
        width: width,
        height: height,
      );
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return Image.asset(
        mIconRainy,
        width: width,
        height: height,
      );
    case mthunderstorm:
    case mthunderstormN:
      return Image.asset(
        mIconThunderstorm,
        width: width,
        height: height,
      );
    case mSnow:
    case mSnowN:
      return Image.asset(
        mIconSnow,
        width: width,
        height: height,
      );
    case mist:
    case mistN:
      return Image.asset(
        mIconFog,
        width: width,
        height: height,
      );
    default:
      return Image.asset(
        mIconClears,
        width: width,
        height: height,
      );
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

String getBgImagePath(String iconCode) {
  switch (iconCode) {
    case mClear:
      return mBgClear;
    case mClearN:
      return mBgClearN;
    case mFewClouds:
    case mClouds:
      return mBgAFewCloudy;
    case mFewCloudsN:
    case mCloudsN:
      return mBgAFewCloudyN;
    case mBrokenClouds:
    case mBrokenCloudsN:
      return mBgCloudy;
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return mBgRain;
    case mthunderstorm:
    case mthunderstormN:
      return mBgStorm;
    case mSnow:
    case mSnowN:
      return mBgSnow;
    case mist:
    case mistN:
      return mBgHazy;
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

String formatDateAndWeekDay(DateTime dateTime) {
  final df = new DateFormat('EEE MM/dd');
  String date = df.format(dateTime);
  return date;
}

String formatDate(DateTime dateTime) {
  final df = new DateFormat('M/dd');
  String date = df.format(dateTime);
  return date;
}

String formatWeekDayAndTime(DateTime dateTime) {
  final df = new DateFormat('EEE HH:mm');
  String date = df.format(dateTime);
  return date;
}

String formatTime(DateTime dateTime) {
  final df = new DateFormat('HH:mm');
  String date = df.format(dateTime);
  return date;
}

String formatWeekday(DateTime dateTime) {
  final df = new DateFormat('EEE');
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
      map[dayKey] = <WeatherForecastResponse>[];
    }
    map[dayKey].add(response);
  }
  return map;
}

String _getDayKey(DateTime dateTime) {
  return "${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}";
}

convertTemp(double temp, TempEnum tempEnum) {
  if (tempEnum == TempEnum.F) {
    temp = (temp * 1.8) + 32;
  }
  return temp;
}

String formatTemperature(
    {double temperature, int positions = 0, round = true, String unit=''}) {
  if (round) {
    temperature = temperature.floor().toDouble();
  }

  return "${temperature.toStringAsFixed(positions)}$degree$unit";
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
  double newWind = wind * 3.6;
  return "${newWind.toStringAsFixed(1)} $unit";
}

String formatVisibility(double visibility) {
  String unit = "km";
  double newVisibility = visibility / 1000;
  return "${newVisibility.toStringAsFixed(0)} $unit";
}

String getWindDirection(double degree) {
  final arr = [
    "N",
    "NNE",
    "NE",
    "ENE",
    "E",
    "ESE",
    "SE",
    "SSE",
    "S",
    "SSW",
    "SW",
    "WSW",
    "W",
    "WNW",
    "NW",
    "NNW"
  ];

  int value = (degree / 22.5 + 0.5).toInt();
  return arr[value % 16];
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

String getRiseAndSetTime(DateTime rise, DateTime set) {
  int sunMilli = rise.millisecondsSinceEpoch;
  int setMilli = set.millisecondsSinceEpoch;
  int sub = setMilli - sunMilli;
  double hour = sub / (60 * 60 * 1000);

  double minute = (sub / (60 * 60 * 100)) % 60;

  return '${hour.toStringAsFixed(0)} hour ${minute.toStringAsFixed(0)} minute';
}

int convertTimezoneToNumber(String timezone) {
  String value = timezone.substring(0, timezone.indexOf(':'));
  int valueInt = (int.parse(value) - 7);

  return valueInt;
}

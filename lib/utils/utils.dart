import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/system.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';

Image getIconForecastImage(String? iconCode,
    {double? width, double? height, String prefix = ''}) {
  switch (iconCode) {
    case mClear:
      return Image.asset(
        mIconClears1(prefix),
        width: width,
        height: height,
      );
    case mClearN:
      return Image.asset(
        mIconClearsNight1(prefix),
        width: width,
        height: height,
      );
    case mFewClouds:
      return Image.asset(
        mIconFewCloudsDay1(prefix),
        width: width,
        height: height,
      );
    case mFewCloudsN:
      return Image.asset(
        mIconFewCloudsNight1(prefix),
        width: width,
        height: height,
      );
    case mClouds:
    case mCloudsN:
    case mBrokenClouds:
    case mBrokenCloudsN:
      return Image.asset(
        mIconBrokenClouds1(prefix),
        width: width,
        height: height,
      );
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return Image.asset(
        mIconRainy1(prefix),
        width: width,
        height: height,
      );
    case mthunderstorm:
    case mthunderstormN:
      return Image.asset(
        mIconThunderstorm1(prefix),
        width: width,
        height: height,
      );
    case mSnow:
    case mSnowN:
      return Image.asset(
        mIconSnow1(prefix),
        width: width,
        height: height,
      );
    case mist:
    case mistN:
      return Image.asset(
        mIconFog1(prefix),
        width: width,
        height: height,
      );
    default:
      return Image.asset(
        mIconClears1(prefix),
        width: width,
        height: height,
      );
  }
}

String getIconForecastUrl(String? iconCode, {String prefix = 'p2_'}) {
  switch (iconCode) {
    case mClear:
      return mIconClears1(prefix);
    case mClearN:
      return mIconClearsNight;
    case mFewClouds:
    case mClouds:
      return mIconFewCloudsDay1(prefix);
    case mFewCloudsN:
    case mCloudsN:
      return mIconFewCloudsNight1(prefix);
    case mBrokenClouds:
    case mBrokenCloudsN:
      return mIconBrokenClouds1(prefix);
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return mIconRainy1(prefix);
    case mthunderstorm:
    case mthunderstormN:
      return mIconThunderstorm1(prefix);
    case mSnow:
    case mSnowN:
      return mIconSnow1(prefix);
    case mist:
    case mistN:
      return mIconFog1(prefix);
    default:
      return mIconClears1(prefix);
  }
}

String getBgImagePath(String? iconCode) {
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
      return mBgClear;
  }
}

String getBgAppbarPath(String? iconCode) {
  switch (iconCode) {
    case mClear:
      return bgAppbarClear;
    case mClearN:
      return bgAppbarClearN;
    case mFewClouds:
    case mClouds:
      return bgAppbarFewCloudy;
    case mFewCloudsN:
    case mCloudsN:
      return bgAppbarFewCloudyN;
    case mBrokenClouds:
    case mBrokenCloudsN:
      return bgAppbarCloudy;
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return bgAppbarRain;
    case mthunderstorm:
    case mthunderstormN:
      return bgAppbarStorm;
    case mSnow:
    case mSnowN:
      return bgAppbarSnow;
    case mist:
    case mistN:
      return bgAppbarHazy;
    default:
      return bgAppbarClear;
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

String formatDateAndWeekDay(DateTime dateTime, DateEnum dateEnum) {
  DateFormat df;

  switch (dateEnum) {
    case DateEnum.ddMMyyyyy:
      df = new DateFormat('EEE dd/M', Get.deviceLocale!.languageCode);
      break;
    case DateEnum.mmddyyyyy:
      df = new DateFormat('EEE M/dd', Get.deviceLocale!.languageCode);
      break;
    case DateEnum.yyyymmdd:
      df = new DateFormat('EEE M/dd', Get.deviceLocale!.languageCode);
      break;
    default:
      df = new DateFormat('EEE dd/M', Get.deviceLocale!.languageCode);
  }
  String date = df.format(dateTime);
  return date;
}

String formatDateAndMonth(DateTime dateTime, DateEnum dateEnum) {
  DateFormat df;
  switch (dateEnum) {
    case DateEnum.ddMMyyyyy:
      df = new DateFormat('dd/M', Get.deviceLocale!.languageCode);
      break;
    case DateEnum.mmddyyyyy:
      df = new DateFormat('M/dd', Get.deviceLocale!.languageCode);
      break;
    case DateEnum.yyyymmdd:
      df = new DateFormat('M/dd', Get.deviceLocale!.languageCode);
      break;
    default:
      df = new DateFormat('dd/M', Get.deviceLocale!.languageCode);
  }
  String date = df.format(dateTime);
  return date;
}

String formatWeekDayAndTime(DateTime? dateTime, TimeEnum timeEnum) {
  DateFormat df =
      new DateFormat('EEE HH:mm', settingBloc.languageEnum.languageCode);
  switch (timeEnum) {
    case TimeEnum.twelve:
      df = new DateFormat('EEE HH:mm a', settingBloc.languageEnum.languageCode);
      break;
    case TimeEnum.twentyFour:
      df = new DateFormat('EEE HH:mm', settingBloc.languageEnum.languageCode);
      break;
  }

  String date = df.format(dateTime!);
  return date;
}

String formatTime(DateTime dateTime, TimeEnum timeEnum) {
  late DateFormat df;
  switch (timeEnum) {
    case TimeEnum.twelve:
      df = new DateFormat('h:mm a', Get.deviceLocale!.languageCode);
      break;
    case TimeEnum.twentyFour:
      df = new DateFormat('HH:mm', Get.deviceLocale!.languageCode);
      break;
  }
  String date = df.format(dateTime);
  return date;
}

String formatWeekday(DateTime dateTime) {
  final df = new DateFormat('EEE', Get.deviceLocale!.languageCode);
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
    map[dayKey]!.add(response);
  }
  return map;
}

String _getDayKey(DateTime dateTime) {
  return "${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}";
}

double? convertTemp(double? temp, TempEnum tempEnum) {
  if (tempEnum == TempEnum.F) {
    return convertCelsiusToFahrenheit(temp!);
  }
  return temp;
}

double? convertWindSpeed(double? speed, WindEnum windEnum) {
  switch (windEnum) {
    case WindEnum.kmh:
      return speed;
    case WindEnum.mph:
      return convertKmHToMph(speed!);
    case WindEnum.ms:
      return convertKmHToMps(speed!);
    default:
      return speed;
  }
}

double? convertPressure(double? pressure, PressureEnum pressureEnum) {
  switch (pressureEnum) {
    case PressureEnum.mBar:
      return pressure;
    case PressureEnum.bar:
      return convertHpaToBar(pressure!);
    case PressureEnum.mmHg:
      return convertHpaTommHg(pressure!);
    case PressureEnum.psi:
      return convertHpaToPsi(pressure!);
    case PressureEnum.inHg:
      return convertHpaToinHg(pressure!);
    default:
      return pressure;
  }
}

double? convertVisibility(double? visibility, VisibilityEnum visibilityEnum) {
  switch (visibilityEnum) {
    case VisibilityEnum.km:
      return visibility;
    case VisibilityEnum.mile:
      return convertKmToMiles(visibility!);
    default:
      return visibility;
  }
}

double convertKmToMiles(double km) => km * 0.62137;

double convertHpaToBar(double hPa) => hPa / 1000;

double convertHpaTommHg(double hPa) => hPa * 0.75;

double convertHpaToPsi(double hPa) => hPa * 0.015;

double convertHpaToinHg(double hPa) => hPa * 0.0295;

double convertKmHToMph(double speed) => speed * 0.62;

double convertKmHToMps(double speed) => speed * 1000 / 3600;

String formatTemperature(
    {double? temperature, int positions = 0, round = true, String unit = ''}) {
  if (round) {
    temperature = temperature!.floor().toDouble();
  }

  return "${temperature!.toStringAsFixed(positions)}$degree$unit";
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

String formatPressure(double pressure, String unit) {
  return "${pressure.toStringAsFixed(0)} $unit";
}

String formatRain(double rain) {
  return "${rain.toStringAsFixed(2)} mm/h";
}

String formatWind(double wind, String unit) {
  return "${wind.toStringAsFixed(1)} $unit";
}

String formatVisibility(double visibility, String unit) {
  return "${visibility.toStringAsFixed(0)} $unit";
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
  int sunrise = system.sunrise! * 1000;
  int sunset = system.sunset! * 1000;
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

  return '${hour.toStringAsFixed(0)} ${'hour'.tr} ${minute.toStringAsFixed(0)} ${'minute'.tr}';
}

int convertTimezoneToNumber(String timezone) {
  String value = timezone.substring(0, timezone.indexOf(':'));
  int valueInt = (int.parse(value) - 7);
  return valueInt;
}

String formatNumber(int number) {
  var format = NumberFormat("#,###", "en_US");
  return format.format(number);
}

String getImageByIndex(int index) {
  if (index < 10) {
    return '0$index';
  } else {
    return '$index';
  }
}

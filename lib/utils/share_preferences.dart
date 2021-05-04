import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/model/city.dart';

const String _LIST_CITY_KEY = 'list_city_key';
const String _TEMP_SETTING_KEY = 'temp_setting_key';
const String _WIND_SETTING_KEY = 'wind_setting_key';
const String _PRESSURE_SETTING_KEY = 'pressure_setting_key';
const String _DATE_SETTING_KEY = 'date_setting_key';
const String _TIME_SETTING_KEY = 'time_setting_key';
const String _VISIBILITY_SETTING_KEY = 'visibility_setting_key';

class Preferences {
  static saveListCity(List<City> cities) async {
    if (cities.isNotEmpty) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setString(
          _LIST_CITY_KEY, jsonEncode(cities.map((e) => e.toJson()).toList()));
    }
  }

  static Future<List<City>> getListCityFromCache() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_LIST_CITY_KEY) != null
        ? (jsonDecode(preferences.getString(_LIST_CITY_KEY)) as List<dynamic>)
            .map((e) => City.fromJson(e))
            .toList()
        : [];
  }

  static saveTempSetting(String tempSetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_TEMP_SETTING_KEY, tempSetting);
  }

  static Future<String> getTempSetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_TEMP_SETTING_KEY);
  }

  static saveWindSetting(String windSetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_WIND_SETTING_KEY, windSetting);
  }

  static Future<String> getWindSetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_WIND_SETTING_KEY);
  }

  static savePressureSetting(String pressureSetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_PRESSURE_SETTING_KEY, pressureSetting);
  }

  static Future<String> getPressureSetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_PRESSURE_SETTING_KEY);
  }

  static saveDateSetting(String dateSetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_DATE_SETTING_KEY, dateSetting);
  }

  static Future<String> getDateSetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_DATE_SETTING_KEY);
  }

  static saveTimeSetting(String timeSetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_TIME_SETTING_KEY, timeSetting);
  }

  static Future<String> getTimeSetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_TIME_SETTING_KEY);
  }

  static saveVisibilitySetting(String visibilitySetting) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_VISIBILITY_SETTING_KEY, visibilitySetting);
  }

  static Future<String> getVisibilitySetting() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_VISIBILITY_SETTING_KEY);
  }
}

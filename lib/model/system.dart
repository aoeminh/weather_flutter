import 'package:weather_app/shared/constant.dart';

class System {
  final String? country;
  final int? sunrise;
  final int? sunset;

  System({this.country, this.sunrise, this.sunset});

  System.fromJson(Map<String, dynamic> json)
      : country = json["country"],
        sunrise = json["sunrise"] * 1000,
        sunset = json["sunset"] * 1000;

  static System withTimezone(System system, double differentTime) {
    return System(
        sunrise: (system.sunrise! + differentTime * oneHourMilli).toInt(),
        sunset: (system.sunset! + differentTime * oneHourMilli).toInt(),
        country: system.country);
  }

  Map<String, dynamic> toJson() =>
      {"country": country, "sunrise": sunrise, "sunset": sunset};
}

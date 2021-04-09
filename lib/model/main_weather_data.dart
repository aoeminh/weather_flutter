import '../utils/types_helper.dart';

class MainWeatherData {
  final double temp;
  final double pressure;
  final double humidity;
  final double tempMin;
  final double tempMax;
  final double pressureSeaLevel;
  final double pressureGroundLevel;
  final double feelsLike;

  MainWeatherData(this.temp, this.pressure, this.humidity, this.tempMin,
      this.tempMax, this.pressureSeaLevel, this.pressureGroundLevel,
      this.feelsLike);

  MainWeatherData.fromJson(Map<String, dynamic> json)
      : temp = TypesHelper.toDouble(json["temp"]),
        pressure = TypesHelper.toDouble(json["pressure"]),
        humidity = TypesHelper.toDouble(json["humidity"]),
        tempMin = TypesHelper.toDouble(json["temp_min"]),
        tempMax = TypesHelper.toDouble(json["temp_max"]),
        pressureSeaLevel = TypesHelper.toDouble(json["sea_level"]),
        pressureGroundLevel = TypesHelper.toDouble(json["ground_level"]),
        feelsLike = TypesHelper.toDouble(json["feels_like"]);

  Map<String, dynamic> toJson() =>
      {
        "temp": temp,
        "pressure": pressure,
        "humidity": humidity,
        "temp_min": tempMin,
        "temp_max": tempMax,
        "sea_level": pressureSeaLevel,
        "ground_level": pressureGroundLevel
      };

  MainWeatherData copyWith(
      {double temp, double pressure, double humidity, double tempMin,
        double tempMax, double pressureSeaLevel, double pressureGroundLevel, double feelsLike}) {
    return MainWeatherData(
        temp ?? this.temp,
        pressure ?? this.pressure,
        humidity ?? this.humidity,
        tempMin ?? this.tempMin,
        tempMax ?? this.tempMax,
        pressureSeaLevel ?? this.pressureSeaLevel,
        pressureGroundLevel ?? this.pressureGroundLevel,
        feelsLike ?? this.feelsLike);
  }

}

import 'package:weather_app/model/components_air_pollution.dart';
import 'package:weather_app/model/coordinates.dart';
import 'package:weather_app/model/main_air_pollution.dart';

class AirPollution {
  final int dt;
  final MainAirPollution mainAirPollution;
  final ComponentsAirPollution componentsAirPollution;

  AirPollution(this.dt, this.mainAirPollution, this.componentsAirPollution);

  AirPollution.fromJson(Map<String, dynamic> json)
      : this.dt = json['dt'],
        this.mainAirPollution = MainAirPollution.fromJson(json['main']),
        this.componentsAirPollution =
            ComponentsAirPollution.fromJson(json['components']);

  Map<String, dynamic> toJson() => {
        'dt': dt,
        'main': mainAirPollution,
        'components': componentsAirPollution
      };
}

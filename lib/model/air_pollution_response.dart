import 'package:weather_app/model/air_pollution.dart';

import 'application_error.dart';
import 'coordinates.dart';

class AirPollutionResponse {
  late Coordinates coordinates;
  late List<AirPollution> listAirPollution;
  ApplicationError? _errorCode;

  AirPollutionResponse.error(this._errorCode);

  AirPollutionResponse(this.coordinates, this.listAirPollution);

  AirPollutionResponse.fromJson(Map<String, dynamic> json)
      : this.coordinates = Coordinates.fromJson(json['coord']),
        this.listAirPollution = (json['list'] as List)
            .map((e) => AirPollution.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() =>
      {'coord': coordinates, 'list': listAirPollution};

  static AirPollutionResponse withErrorCode(ApplicationError errorCode) {
    return AirPollutionResponse.error(errorCode);
  }

  ApplicationError? get errorCode => _errorCode;
}

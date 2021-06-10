import 'package:weather_app/model/air_data.dart';

import 'application_error.dart';

class AirResponse {
  late AirData data;
  ApplicationError? _errorCode;

  AirResponse(this.data);

  AirResponse.error(this._errorCode);

  AirResponse.fromJson(Map<String, dynamic> json)
      : data = AirData.fromJson(json['data']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data.toJson();
    return data;
  }

  static AirResponse withErrorCode(ApplicationError errorCode) {
    return AirResponse.error(errorCode);
  }

  ApplicationError? get errorCode => _errorCode;
}

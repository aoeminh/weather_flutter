import '../utils/types_helper.dart';

class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates(this.longitude, this.latitude);

  Coordinates.fromJson(Map<String, dynamic> json)
      : longitude = TypesHelper.toDouble(json["lon"]),
        latitude = TypesHelper.toDouble(json["lat"]);

  Map<String, dynamic> toJson() =>
      {
        "lon": longitude,
        "lat": latitude
      };

  static Map<String, dynamic> convertJson(double lng, double lat) {
    return {
      "lon": lng,
      "lat": lat
    };
  }
}

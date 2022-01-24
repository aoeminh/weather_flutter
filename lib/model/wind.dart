import '../utils/types_helper.dart';

class Wind {
  final double speed;
  final double deg;
  final double? gust;

  Wind(this.speed, this.deg, {this.gust});

  Wind.fromJson(Map<String, dynamic> json)
      : speed = TypesHelper.toDouble(json["speed"]),
        deg = TypesHelper.toDouble(json["deg"]),
        gust = TypesHelper.toDouble(json["gust"]);

  Map<String, dynamic> toJson() => {
        "speed": speed,
        "deg": deg,
      };

  Wind copyWith({double? speed, double? deg}) {
    return Wind(speed ?? this.speed, deg ?? this.deg);
  }

  String getDegCode() {
    if (deg == null) {
      return "N";
    }
    if (deg >= 0 && deg < 45) {
      return "N";
    } else if (deg >= 45 && deg < 90) {
      return "NE";
    } else if (deg >= 90 && deg < 135) {
      return "E";
    } else if (deg >= 135 && deg < 180) {
      return "SE";
    } else if (deg >= 180 && deg < 225) {
      return "S";
    } else if (deg >= 225 && deg < 270) {
      return "SW";
    } else if (deg >= 270 && deg < 315) {
      return "W";
    } else if (deg >= 315 && deg <= 360) {
      return "NW";
    } else {
      return "N";
    }
  }
}

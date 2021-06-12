import 'iaqi.dart';

class AirData {
  final int aqi;
  final Iaqi iaqi;

  AirData(this.aqi, this.iaqi);

  AirData.fromJson(Map<String, dynamic> json)
      : aqi = json['aqi'],
        iaqi = Iaqi.fromJson(json['iaqi']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aqi'] = this.aqi;
    data['iaqi'] = this.iaqi.toJson();
    return data;
  }
}

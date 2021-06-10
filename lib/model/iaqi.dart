import 'air.dart';

class Iaqi {
  final Air co;
  final Air no2;
  final Air o3;
  final Air pm25;
  final Air so2;

  Iaqi(this.co, this.no2, this.o3, this.pm25, this.so2);

  Iaqi.fromJson(Map<String, dynamic> json)
      : co = Air.fromJson(json['co']),
        no2 = Air.fromJson(json['no2']),
        o3 = Air.fromJson(json['o3']),
        pm25 = Air.fromJson(json['pm25']),
        so2 = Air.fromJson(json['so2']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['co'] = this.co.toJson();

    data['no2'] = this.no2.toJson();

    data['o3'] = this.o3.toJson();
    data['pm25'] = this.pm25.toJson();
    data['so2'] = this.so2.toJson();
    return data;
  }
}

import 'air.dart';

class Iaqi {
  final Air co;
  final Air no2;
  final Air o3;
  final Air pm25;
  final Air so2;

  Iaqi(this.co, this.no2, this.o3, this.pm25, this.so2);

  Iaqi.fromJson(Map<String, dynamic> json)
      : co = Air.fromJson(json['co'] ?? {'v': 0.1}),
        no2 = Air.fromJson(json['no2'] ?? {'v': 7.8}),
        o3 = Air.fromJson(json['o3'] ?? {'v': 7.8}),
        pm25 = Air.fromJson(json['pm25'] ?? {'v': 78}),
        so2 = Air.fromJson(json['so2'] ?? {'v': 5.8});

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

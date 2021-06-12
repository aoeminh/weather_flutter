class ComponentsAirPollution {
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final double nh3;

  ComponentsAirPollution.fromJson(Map<String, dynamic> json)
      : this.co = json['co'],
        this.no = json['no'],
        this.no2 = json['no2'],
        this.o3 = json['o3'],
        this.so2 = json['so2'],
        this.pm25 = json['pm2_5'],
        this.pm10 = json['pm10'],
        this.nh3 = json['nh3'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['co'] = this.co;
    data['no'] = this.no;
    data['no2'] = this.no2;
    data['o3'] = this.o3;
    data['so2'] = this.so2;
    data['pm2_5'] = this.pm25;
    data['pm10'] = this.pm10;
    data['nh3'] = this.nh3;
    return data;
  }
}

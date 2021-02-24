class Temp {
  double day;
  double min;
  double max;
  double night;
  double eve;
  double morn;

  Temp({this.day, this.min, this.max, this.night, this.eve, this.morn});

  Temp.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    min = json['min'];
    max = json['max'];
    night = json['night'];
    eve = json['eve'];
    morn = json['morn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['min'] = this.min;
    data['max'] = this.max;
    data['night'] = this.night;
    data['eve'] = this.eve;
    data['morn'] = this.morn;
    return data;
  }
}

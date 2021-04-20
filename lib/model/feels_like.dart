class FeelsLike {
  double day;
  double night;
  double eve;
  double morn;

  FeelsLike({this.day, this.night, this.eve, this.morn});

  FeelsLike.fromJson(Map<String, dynamic> json) {
    day = json['day'].toDouble();
    night = json['night'].toDouble();
    eve = json['eve'].toDouble();
    morn = json['morn'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['night'] = this.night;
    data['eve'] = this.eve;
    data['morn'] = this.morn;
    return data;
  }

  FeelsLike copyWith({double day,
    double night,
    double eve,
    double morn}) {
    return FeelsLike(day: day ?? this.day,
        night: night ?? this.night,
        eve: eve ?? this.eve,
        morn: morn ?? this.morn);
  }
}

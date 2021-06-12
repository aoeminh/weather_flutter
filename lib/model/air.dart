class Air {
  final double v;

  Air(this.v);

  Air.fromJson(Map<String, dynamic> json) : v = json['v'].toDouble();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['v'] = this.v;
    return data;
  }
}

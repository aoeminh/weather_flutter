class MainAirPollution {
  final int aqi;

  MainAirPollution(this.aqi);

  MainAirPollution.fromJson(Map<String, dynamic> json) : this.aqi = json['aqi'];

  Map<String, dynamic> toJson() => {'aqi': aqi};
}

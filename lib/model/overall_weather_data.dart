class Weather {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;

  Weather(this.id, this.main, this.description, this.icon);

  Weather.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        main = json["main"],
        description = json["description"],
        icon = json["icon"];

  Map<String, dynamic> toJson() =>
      {"id": id, "main": main, "description": description, "icon": icon};

  @override
  String toString() {
    return toJson().toString();
  }
}

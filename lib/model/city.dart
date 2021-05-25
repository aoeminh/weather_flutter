import 'coordinates.dart';

class City {
  final double? id;
  final String? name;
   Coordinates? coordinates;
  final String? country;
  bool isHome;

  City(
      {this.id,
      this.name,
      this.coordinates,
      this.country,
      this.isHome = false});

  City.fromJson(Map<String, dynamic> json)
      : id = json["id"].toDouble(),
        name = json["name"],
        coordinates = Coordinates.fromJson(json['coord']),
        country = json['country'],
        isHome = json['isHome']?? false;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        'coord': coordinates!.toJson(),
        'country': country,
        'isHome': isHome
      };
}

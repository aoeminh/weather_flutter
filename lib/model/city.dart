import 'coordinates.dart';

class City {
  final double id;
  final String name;
  final Coordinates coordinates;
  final String country;

  City(this.id, this.name, this.coordinates, this.country);

  City.fromJson(Map<String, dynamic> json)
      : id = json["id"].toDouble(),
        name = json["name"],
        coordinates = Coordinates.fromJson(json['coord']),
        country = json['country'];

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

import 'coordinates.dart';

class City {
  final double? id;
  final String? name;
  Coordinates? coordinates;
  bool isHome;
  final String? cityAscii;
  final String? country;
  final String? iso2;
  final String? iso3;
  final String? province;

  City(
      {this.id,
      this.name,
      this.coordinates,
      this.isHome = false,
      this.cityAscii,
      this.country,
      this.iso2,
      this.iso3,
      this.province,});

  City.fromJson(Map<String, dynamic> json)
      : id = json["id"].toDouble(),
        name = json["name"],
        coordinates = Coordinates.fromJson(json['coord']),
        isHome = json['isHome'] ?? false,
        cityAscii = json['city_ascii'],
        country = json['country'],
        iso2 = json['iso2'].toString(),
        iso3 = json['iso3'].toString(),
        province = json['province'];


  City.fromAssetJson(Map<String, dynamic> json)
      : id = 0,
        name = json["city"],
        coordinates = Coordinates.fromJson(Coordinates.convertJson(
            json['lng'].toDouble(), json['lat'].toDouble())),
        isHome = json['isHome'] ?? false,
        cityAscii = json['city_ascii'],
        country = json['country'],
        iso2 = json['iso2'].toString(),
        iso3 = json['iso3'].toString(),
        province = json['province'];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        'coord': coordinates!.toJson(),
        'country': country,
        'isHome': isHome
      };
}

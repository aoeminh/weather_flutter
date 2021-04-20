import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/model/coordinates.dart';

class PositionBloc extends BlocBase {
  BehaviorSubject<City> _behaviorSubject = BehaviorSubject();
  Position _position;

  determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    _position = await Geolocator.getCurrentPosition();
    // add the first city
    _behaviorSubject.add(City(coordinates: Coordinates(_position.latitude,_position.longitude)));

  }

  Stream get positionStream => _behaviorSubject.stream;

  @override
  void dispose() {
    _behaviorSubject.close();
  }
}

final positionBloc = PositionBloc();

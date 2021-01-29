import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';

class PositionBloc extends BlocBase{

  BehaviorSubject<Position> _behaviorSubject = BehaviorSubject();

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
    Position position = await Geolocator.getCurrentPosition();
    _behaviorSubject.add(position);

  }

  Stream get positionStream => _behaviorSubject.stream;
  @override
  void dispose() {
    _behaviorSubject.close();
  }

}
 final positionBloc = PositionBloc();

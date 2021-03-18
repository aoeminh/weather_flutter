import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';

class PageBloc extends BlocBase {
  List<Position> positions = [];

  BehaviorSubject<List<Position>> _behaviorPosition = BehaviorSubject();
  BehaviorSubject<int> currentPage = BehaviorSubject();

  addPage(double lat, double lon) {
    int index = positions.indexWhere(
        (element) => (element.latitude == lat && element.longitude == lon));
    if(index == -1){
      positions.add(Position(latitude: lat, longitude: lon));
      _behaviorPosition.add(positions);
      currentPage.add(positions.length);
    }else{
      currentPage.add(index);
    }

  }

  Stream get pageStream => _behaviorPosition.stream;

  @override
  void dispose() {
    _behaviorPosition.close();
    currentPage.close();
  }
}

final pageBloc = PageBloc();

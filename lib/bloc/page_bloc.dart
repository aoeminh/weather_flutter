
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';

class PageBloc extends BlocBase{
  List<Position> positions = [];

  BehaviorSubject<List<Position>> _behaviorPosition = BehaviorSubject();

  addPage(double lat, double lon){
    positions.add(Position(latitude: lat,longitude: lon));
    _behaviorPosition.add(positions);
  }


  Stream get pageStream => _behaviorPosition.stream;
  @override
  void dispose() {
    _behaviorPosition.close();
  }}

  final pageBloc = PageBloc();
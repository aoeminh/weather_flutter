import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'weather_screen.dart';

class HomePage extends StatefulWidget {
  final Position position;

  const HomePage({Key key, this.position}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Position> positions = [];

  @override
  void initState() {
    super.initState();
    pageBloc.addPage(widget.position.latitude,widget.position.longitude);
    pageBloc.pageStream.listen((event) {
      positions.addAll(event);
      setState(() {});
    });
  }

  final controller = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: positions
            .map((data) =>
                WeatherScreen(lat: data.latitude, lon: data.longitude))
            .toList(),
        onPageChanged: (page) {},
      ),
    );
  }

}

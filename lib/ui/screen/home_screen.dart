import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/bloc/city_bloc.dart';
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
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    cityBloc.getListCity();
    pageBloc.addPage(widget.position.latitude, widget.position.longitude);
    pageBloc.currentPage.listen((event) {
      if (controller.hasClients) {
        controller.jumpToPage(event);
        setState(() {});
      }
    });
  }

  final controller = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Position>>(
        stream: pageBloc.pageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: snapshot.data
                  .map((data) =>
                      WeatherScreen(lat: data.latitude, lon: data.longitude))
                  .toList(),
              onPageChanged: (page) {},
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

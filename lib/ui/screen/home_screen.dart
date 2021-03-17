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
    pageBloc.addPage(widget.position.latitude,widget.position.longitude);
    pageBloc.pageStream.listen((event) {
      List<Position> positionss = event as  List<Position>;
      positions.add(positionss.last);
      currentPage = positions.length;
      controller.jumpToPage(currentPage);
      setState(() {});
    });
  }

  final controller = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: pageBloc.pageStream,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return  PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: positions
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

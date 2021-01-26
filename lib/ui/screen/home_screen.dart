import 'package:flutter/material.dart';
import 'package:weather_app/ui/screen/weather_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: [WeatherScreen()],
        onPageChanged: (page) {},
      ),
    );
  }
}

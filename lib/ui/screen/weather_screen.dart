import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hanoi'),
        leading: Icon(Icons.menu, color: Colors.white),
        actions: [
          Icon(
            Icons.add,
            color: Colors.white,
          )
        ],
      ),
      body: _body(),
    );
  }

  _body(){
    return Stack(
      children: [],
    );
  }
}

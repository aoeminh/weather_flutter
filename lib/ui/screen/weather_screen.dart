import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/widgets/smarr_refresher.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(mBgCloudy), fit: BoxFit.cover)),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'Hanoi',
                  style: textTitleH2WhiteBold,
                ),
                Text('13:14', style: textSecondaryGrey),
              ],
            ),
            leading: Icon(Icons.menu, color: Colors.white),
            actions: [
              Icon(
                Icons.add,
                color: Colors.white,
              )
            ],
          ),
          body: _body(),
        )
      ],
    );
  }

  _body() {
    return Container(
      child: SingleChildScrollView(
        child: SmartRefresher(
          children: [
            Container(
              child: Column(
                children: [],
              ),
            )
          ],
          onRefresh: get,
        ),
      ),
    );
  }

  _currentWeather(){

    return Column(
      children: [
        Text('')
      ],
    );

  }

  Future<void> get() async {
    await Future.delayed(Duration(seconds: 2));
    return;
  }
}

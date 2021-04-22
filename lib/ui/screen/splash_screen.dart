import 'package:flutter/material.dart';
import 'package:weather_app/bloc/app_bloc.dart';

import '../../bloc/city_bloc.dart';
import '../../shared/image.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  @override
  void initState() {
    super.initState();
    appBloc.determinePosition().then((city) {
      if (city != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      city: city,
                    )),
            (Route<dynamic> route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _body() {
    return Container(
      decoration: BoxDecoration(
          image:
              DecorationImage(image: AssetImage(bgSplashBlur), fit: BoxFit.fill)),
    );
  }
}

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import '../../bloc/setting_bloc.dart';

import '../../bloc/app_bloc.dart';
import '../../model/city.dart';
import '../../shared/image.dart';
import 'home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FutureGroup futureGroup = FutureGroup();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  @override
  void initState() {
    super.initState();
    loadAppWithCache();
    settingBloc.getSetting();
  }

  firstLoadApp() {
    appBloc.determinePosition().then((city) {
      if (city != null) {
        print(
            'city ${city.coordinates!.latitude}  ${city.coordinates!.longitude}');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      listCity: [city],
                    )),
            (Route<dynamic> route) => false);
      }
    });
  }

  loadAppWithCache() {
    var futureCaches = Future.wait(
        {appBloc.determinePosition(), appBloc.getListCityFromCache()});
    futureCaches.then((value) {
      var listCity = value[1] as List<City>;
      var city = value[0] as City;
      if (listCity.isNotEmpty) {
        print('list city ${listCity.length}');

        var index = listCity.indexWhere((element) {
          return element.isHome;
        });
        listCity[index].coordinates = city.coordinates;
      } else {
        listCity.add(city);
      }
      print('list city ${listCity.length}');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    listCity: listCity,
                  )),
          (Route<dynamic> route) => false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    futureGroup.close();
  }

  _body() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(bgSplashBlur), fit: BoxFit.fill)),
      child: Center(
        child: SpinKitWave(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}

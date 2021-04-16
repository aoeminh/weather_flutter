import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/model/coordinates.dart';
import '../../model/city.dart';
import '../../bloc/city_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../main.dart';
import '../../model/weather_response.dart';
import '../../shared/strings.dart';

import 'weather_screen.dart';

class HomePage extends StatefulWidget {
  final City city;

  const HomePage({Key key, this.city}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    settingBloc.notificationStream.listen((event) {
      event ? _showNotification() : _closeNotification();
    });
    cityBloc.getListCity();
    cityBloc.getListTimezone();
    pageBloc.addNewCity(City(
        coordinates: Coordinates(widget.city.coordinates.latitude,
            widget.city.coordinates.longitude)));
    pageBloc.currentPage.listen((event) {
      if (controller.hasClients) {
        int index = event;
        controller.jumpToPage(index);
      }
    });
  }

  _showNotification() async {
    WeatherResponse weatherResponse = settingBloc.weatherResponse;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('id', 'name', 'description',
            importance: Importance.defaultImportance,
            autoCancel: false,
            color: Colors.blue,
            enableVibration: false,
            visibility: NotificationVisibility.public,
            enableLights: true,
            icon: 'ic_little_sun',
            largeIcon: DrawableResourceAndroidBitmap('ic_little_sun'),
            priority: Priority.defaultPriority,
            ongoing: true,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String title =
        '${weatherResponse.mainWeatherData.temp}$degreeC at ${weatherResponse.name} ';
    String body =
        'Feels like ${weatherResponse.mainWeatherData.feelsLike}$degreeC . ${weatherResponse.overallWeatherData[0].description} ';

    await flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: 'payload');
  }

  _closeNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  final controller = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<City>>(
        stream: pageBloc.pageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: snapshot.data
                  .map((data) => WeatherScreen(
                index: snapshot.data.indexOf(data),
                      lat: data.coordinates.latitude,
                      lon: data.coordinates.longitude))
                  .toList(),
              onPageChanged: (page) {},
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

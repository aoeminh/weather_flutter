import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/utils/utils.dart';
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
    settingBloc.notificationStream.listen((event) {
      event ? _showNotification() : _closeNotification();
    });
    cityBloc.getListCity();
    cityBloc.getListTimezone();
    pageBloc.addPage(widget.position.latitude, widget.position.longitude);
    pageBloc.currentPage.listen((event) {
      if (controller.hasClients) {
        controller.jumpToPage(event);
        setState(() {});
      }
    });
  }

  _showNotification() async {
    WeatherResponse weatherResponse = settingBloc.weatherResponse;
    String largeIconPath = '';
    largeIconPath =
        getIconForecastUrl(weatherResponse.overallWeatherData[0].icon)
            .substring(
                0,
                getIconForecastUrl(weatherResponse.overallWeatherData[0].icon)
                    .indexOf('.'));
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

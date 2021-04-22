import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weather_app/shared/image.dart';

import '../../bloc/app_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../main.dart';
import '../../model/application_error.dart';
import '../../model/city.dart';
import '../../model/coordinates.dart';
import '../../model/weather_response.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../shared/strings.dart';
import '../../shared/text_style.dart';
import 'weather_screen.dart';

class HomePage extends StatefulWidget {
  final City city;

  const HomePage({Key key, this.city}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    appBloc.getListCity();
    appBloc.getListTimezone();
    settingBloc.notificationStream.listen((event) {
      event ? _showNotification() : _closeNotification();
    });
    appBloc.errorStream.listen((event) {
      if (!isShowingDialog) _showErrorDialog(event);
    });
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

  _showErrorDialog(ApplicationError error) {
    isShowingDialog = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: Container(
              height: 150,
              width: 300,
              color: backgroundColor,
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Error',
                    style: textTitleWhite,
                  ),
                  const SizedBox(
                    height: marginSmall,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        isShowingDialog = false;
                      },
                      child: Text(
                        'OK',
                        style: textTitleOrange,
                      ))
                ],
              ),
            ),
          );
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
          return Container(
            decoration: BoxDecoration(
                image:
                DecorationImage(image: AssetImage(bgSplash), fit: BoxFit.fill)),
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:system_settings/system_settings.dart';

import '../../bloc/app_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../main.dart';
import '../../model/application_error.dart';
import '../../model/city.dart';
import '../../model/weather_response.dart';
import '../../shared/colors.dart';
import '../../shared/image.dart';
import '../../shared/text_style.dart';
import '../../utils/utils.dart';
import 'weather_screen.dart';

class HomePage extends StatefulWidget {
  final List<City>? listCity;

  const HomePage({Key? key, this.listCity}) : super(key: key);

  static _HomePageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late StreamSubscription subscription;
  int? currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    WidgetsBinding.instance!.addObserver(this);
    appBloc.getListCity();
    appBloc.getListSuggestCity();
    _listenConnectNetWork();
    _listenNotification();
    _checkNetWork();
    _listenAppError();
    _listenCurrentPage();
  }

  _checkNetWork() {
    appBloc.checkNetWork().then((isNetWorkAvailable) {
      pageBloc.addListCity(widget.listCity!);
      if (!isNetWorkAvailable) {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  _listenAppError() {
    appBloc.errorStream.listen((event) {
      switch (event) {
        case ApplicationError.apiError:
          break;
        case ApplicationError.connectionError:
          _showNetWorkErrorDialog();
          break;
        case ApplicationError.locationNotSelectedError:
          // TODO: Handle this case.
          break;
      }
    });
  }

  _showNetWorkErrorDialog() {
      _showErrorDialog(
          content: 'network_error'.tr,
          callback: () {
            SystemSettings.wifi();
            Navigator.pop(context);
          });

  }

  _listenCurrentPage() {
    pageBloc.currentPage.listen((event) {
      if (controller.hasClients) {
        int index = event;
        controller.jumpToPage(index);
      }
    });
  }

  _listenConnectNetWork() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
      } else {
        _showNetWorkErrorDialog();
      }
    });
  }

  _listenNotification() {
    settingBloc.notificationStream.listen((event) {
      event ? _showNotification() : _closeNotification();
    });
  }

  _showErrorDialog({String? content, VoidCallback? callback}) {
    if (!Get.isDialogOpen!) {
      Get.dialog(
          AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(content!,
              style: textSecondaryWhite70,),
            actions: [
              TextButton(
                  onPressed: callback,
                  child: Text(
                    'OK',
                    style: textTitleOrange,
                  )),
            ],
          ),
          barrierDismissible: false);
    }
  }

  _showNotification() async {
    WeatherResponse weatherResponse = settingBloc.weatherResponse!;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('id', 'name', 'description',
            importance: Importance.defaultImportance,
            autoCancel: false,
            color: Colors.blue,
            enableVibration: false,
            visibility: NotificationVisibility.public,
            enableLights: true,
            icon: 'ic_little_sun',
            priority: Priority.defaultPriority,
            ongoing: true,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    String title =
        '${formatTemperature(temperature: weatherResponse.mainWeatherData!.temp)} at ${weatherResponse.name} ';
    String body =
        '${'feels_like_'.tr} ${formatTemperature(temperature: weatherResponse.mainWeatherData!.feelsLike)} . ${weatherResponse.overallWeatherData![0].description} ';

    await flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: 'payload');
  }

  _closeNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<City>>(
        stream: pageBloc.pageStream as Stream<List<City>>?,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: snapshot.data!
                  .map((data) => WeatherScreen(
                      index: snapshot.data!.indexOf(data),
                      lat: data.coordinates!.latitude,
                      lon: data.coordinates!.longitude))
                  .toList(),
              onPageChanged: (page) {
                currentPage = page;
              },
            );
          }
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(bgSplash), fit: BoxFit.fill)),
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        await appBloc.saveListCity(pageBloc.currentCityList);
        await settingBloc.saveSetting();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    appBloc.dispose();
    pageBloc.dispose();
    settingBloc.dispose();
    subscription.cancel();
  }
}

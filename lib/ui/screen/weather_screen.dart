import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:rxdart/subjects.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/ui/screen/page/drawer/drawer.dart';
import 'package:weather_app/ui/widgets/air_pollution_widget.dart';
import 'package:weather_app/ui/widgets/current_weather_widget.dart';
import 'package:weather_app/ui/widgets/daily_forecast_widget.dart';
import 'package:weather_app/ui/widgets/detail_weather_widget.dart';
import 'package:weather_app/ui/widgets/hourly_forecast_widget.dart';
import 'package:weather_app/ui/widgets/pressure_and_wind.dart';

import '../../bloc/api_service_bloc.dart';
import '../../bloc/base_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../model/air_response.dart';
import '../../model/current_daily_weather.dart';
import '../../model/daily.dart';
import '../../model/weather_forcast_daily.dart';
import '../../model/weather_forecast_list_response.dart';
import '../../model/weather_response.dart';
import '../../shared/colors.dart';
import '../../shared/constant.dart';
import '../../shared/dimens.dart';
import '../../shared/image.dart';
import '../../shared/text_style.dart';
import '../../ui/screen/add_city_screen.dart';
import '../../ui/screen/daily_forecast_screen.dart';
import '../../ui/screen/hourly_forecast_screen.dart';
import '../../ui/widgets/smarr_refresher.dart';
import '../../ui/widgets/sun_path_widget.dart';
import '../../utils/utils.dart';
import '../widgets/air_pollution_widget.dart';
import 'detail_daily_forecast.dart';

const double _mainWeatherHeight = 240;

const String _exclude7DayForecast = 'minutely,hourly';

const double _ratioBlurBg = 1 / 150;
const double _ratioBlurImageBg = 1 / 10;
const double _oneHour = 3600000;

class WeatherScreen extends StatefulWidget {
  final double? lat;
  final double? lon;
  final int? index;

  const WeatherScreen({Key? key, this.lat, this.lon, this.index});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final ApiServiceBloc bloc = ApiServiceBloc();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  WeatherResponse? weatherResponse;
  WeatherForecastListResponse? weatherForecastListResponse;
  WeatherForecastDaily? weatherForecastDaily;
  WeatherData? weatherData;
  BehaviorSubject<DateTime> timeSubject = BehaviorSubject();
  BehaviorSubject<double> _scrollSubject = BehaviorSubject.seeded(0);
  ScrollController _scrollController = ScrollController();
  int currentTime = 0;
  double differentTime = 0;
  bool isOnNotification = false;
  int listLocationLength = 0;
  bool isShowMore = false;

  @override
  void initState() {
    super.initState();
    if (this.mounted) {
      print('test1');
      print('test2');
      print('test3');
      _listenListCityChange();
      _listenChangeSetting();
      appBloc.createInterstitialAd();
      _scrollController.addListener(() {
        _scrollSubject.add(_scrollController.offset);
      });
    }
  }

  _createTime(DateTime dateTime) {
    if (currentTime <= dateTime.millisecondsSinceEpoch) {
      currentTime = dateTime.millisecondsSinceEpoch;
      Timer.periodic(
          Duration(milliseconds: 1000),
          (t) => {
                if (!timeSubject.isClosed) {_addTime()}
              });
    }
  }

  _addTime() {
    currentTime += 1000;
    timeSubject.add(DateTime.fromMillisecondsSinceEpoch(
        (DateTime.now().millisecondsSinceEpoch + differentTime * oneHourMilli)
            .toInt()));
  }

  getData({double? lat, double? lon}) {
    bloc.fetchWeatherForecast7Day(
        lat ?? widget.lat, lon ?? widget.lon, _exclude7DayForecast);
    bloc.fetchWeather(lat ?? widget.lat, lon ?? widget.lon);
    bloc.fetchWeatherForecastResponse(lat ?? widget.lat, lon ?? widget.lon);
    bloc.getAirPollution(lat ?? widget.lat, lon ?? widget.lon);
  }


  _listenListCityChange() {
    pageBloc.currentCitiesStream.listen((event) {
      if (this.mounted) {
        getData(
            lat: event[widget.index].coordinates.latitude,
            lon: event[widget.index].coordinates.longitude);
      }
    });
  }

  _listenChangeSetting() {
    settingBloc.settingStream.listen((event) {
      if (this.mounted) {
        setState(() {
          if (event == SettingEnum.Language) {
            getData();
          }
          convertDataAndFormatTime();
        });
        settingBloc.saveSetting();
      }
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    _scrollController.dispose();
    timeSubject.close();
    _scrollSubject.close();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeatherData?>(
      stream: rx.Rx.combineLatest3(
          bloc.weatherStream,
          bloc.weatherForecastStream,
          bloc.weatherForecastDailyStream, (dynamic a, dynamic b, dynamic c) {
        if (a is WeatherStateSuccess &&
            b is WeatherForecastStateSuccess &&
            c is WeatherForecastDailyStateSuccess) {
          differentTime = _getDifferentTime(c.weatherResponse.timezoneOffset!);
          return WeatherData(
              weatherResponse: WeatherResponse.formatWithTimezone(
                  a.weatherResponse, differentTime),
              weatherForecastListResponse: b.weatherResponse.withTimezone(
                  list: b.weatherResponse, differentTime: differentTime),
              weatherForecastDaily: WeatherForecastDaily.withTimezone(
                  c.weatherResponse, differentTime));
        }
        return null;
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          weatherData = snapshot.data;
          convertDataAndFormatTime();
          pageBloc.removeItemWhenFirstLoadApp(
              weatherData!.weatherForecastListResponse!.city);
          _createTime(DateTime.fromMillisecondsSinceEpoch(
              weatherData!.weatherForecastDaily!.current!.dt!));
        }
        // keep old data when request fail
        return weatherData != null
            ? Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(bgSplash), fit: BoxFit.fill)),
                    ),
                    StreamBuilder<double>(
                        stream: _scrollSubject.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaY: (snapshot.data! *
                                            _ratioBlurImageBg),
                                        sigmaX: (snapshot.data! *
                                            _ratioBlurImageBg)),
                                    child: Image.asset(
                                      getBgImagePath(weatherData!
                                          .weatherResponse!
                                          .overallWeatherData![0]
                                          .icon),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(
                                      snapshot.data! * _ratioBlurBg),
                                ),
                              ],
                            );
                          }
                          return Container();
                        }),
                    _body(weatherData!)
                  ],
                ),
                drawer: DrawerWidget(
                  weatherData!,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(bgSplash), fit: BoxFit.fill)),
              );
      },
    );
  }

  convertDataAndFormatTime() {
    WeatherResponse weatherResponse = weatherData!.weatherResponse!;
    WeatherForecastListResponse weatherForecastListResponse =
        weatherData!.weatherForecastListResponse!;
    WeatherForecastDaily weatherForecastDaily =
        weatherData!.weatherForecastDaily!;
    weatherData = weatherData!.copyWith(
        weatherResponse: weatherResponse.copyWithSettingData(
            settingBloc.tempEnum,
            settingBloc.windEnum,
            settingBloc.pressureEnum),
        weatherForecastListResponse: weatherForecastListResponse.copyWith(
            settingBloc.tempEnum,
            settingBloc.windEnum,
            settingBloc.pressureEnum),
        weatherForecastDaily: weatherForecastDaily.copyWith(
            settingBloc.tempEnum,
            settingBloc.visibilityEnum,
            settingBloc.windEnum,
            settingBloc.pressureEnum));
  }

  double _getDifferentTime(double timezoneOffset) {
    return (timezoneOffset - DateTime.now().timeZoneOffset.inMilliseconds) /
        _oneHour;
  }

  String getTimezone(String timezone) {
    print(
        '${timezone.substring(timezone.indexOf('/') + 1, timezone.length).toLowerCase()}');
    return timezone
        .substring(timezone.indexOf('/') + 1, timezone.length)
        .toLowerCase();
  }

  _body(WeatherData weatherData) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          pinned: true,
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(getBgAppbarPath(weatherData
                            .weatherResponse!.overallWeatherData![0].icon)),
                        fit: BoxFit.fill)),
              ),
              StreamBuilder<double>(
                  stream: _scrollSubject.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        color: Colors.black
                            .withOpacity(snapshot.data! * _ratioBlurBg),
                      );
                    }
                    return Container();
                  })
            ],
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCityScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ))
          ],
          title: _titleAppbar(weatherData.weatherResponse),
        ),
      ],
      body: SmartRefresher(
        refreshIndicatorKey: _refreshIndicatorKey,
        children: Container(
          child: Column(
            children: [
              _currentWeather(weatherData.weatherResponse),
              _buildHourlyForecast(weatherData.weatherForecastListResponse),
              _buildDailyForecast(weatherData.weatherForecastDaily),
              _buildDetail(weatherData.weatherForecastDaily),
              _buildWindAndPressure(weatherData.weatherResponse),
              _buildAriPollution(),
              _buildSunTime(weatherData.weatherResponse)
            ],
          ),
        ),
        onRefresh: refresh,
      ),
    );
  }

  _titleAppbar(WeatherResponse? weatherResponse) {
    return Column(
      children: [
        const SizedBox(
          height: marginSmall,
        ),
        weatherResponse != null ? Text('${weatherResponse.name}') : Container(),
        const SizedBox(
          height: marginSmall,
        ),
        StreamBuilder<DateTime>(
            stream: timeSubject.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    '${formatWeekDayAndTime(snapshot.data, settingBloc.timeEnum)}',
                    style: textSecondaryWhite70);
              }
              return Text('');
            }),
        const SizedBox(
          height: marginSmall,
        ),
      ],
    );
  }

  _currentWeather(WeatherResponse? weatherResponse) {
    return CurrentWeatherWidget(
      weatherResponse: weatherResponse,
      unitValue: settingBloc.tempEnum.value.substring(1),
    );
  }

  _buildHourlyForecast(
      WeatherForecastListResponse? weatherForecastListResponse) {
    return weatherForecastListResponse != null
        ? _buildBodyHourlyForecast(weatherForecastListResponse)
        : Container(
            height: _mainWeatherHeight,
          );
  }

  _buildBodyHourlyForecast(
      WeatherForecastListResponse weatherForecastListResponse) {
    return Column(
      children: [
        _buildRowTitle('hour_forecast'.tr, 'more'.tr, () {
          appBloc.showInterstitialAd();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HourlyForecastScreen(
                        weatherForecastListResponse:
                            weatherForecastListResponse,
                      )));
        }),
        HourlyForecastWidget(
          weatherForecastListResponse: weatherForecastListResponse,
        )
      ],
    );
  }

  _buildRowTitle(String title1, String title2, VoidCallback voidCallback) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title1,
            style: textTitleWhite,
          ),
          GestureDetector(
            onTap: voidCallback,
            child: Text(
              title2,
              style: textTitleUnderlineWhite,
            ),
          )
        ],
      ),
    );
  }

  _buildDailyForecast(WeatherForecastDaily? weatherForecastDaily) {
    return weatherForecastDaily != null
        ? _buildBodyDailyForecast(weatherForecastDaily)
        : Container();
  }

  _buildBodyDailyForecast(WeatherForecastDaily weatherForecastDaily) {
    return Column(
      children: [
        _buildRowTitle('daily_forecast'.tr, 'more'.tr, () {
          appBloc.showInterstitialAd();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyForecastScreen(
                        weatherForecastDaily: weatherForecastDaily,
                      )));
        }),
        DailyForecastWidget(
          weatherForecastDaily: weatherForecastDaily,
          differentTime: differentTime,
        ),
      ],
    );
  }

  _buildDetail(WeatherForecastDaily? weatherForecastDaily) {
    return weatherForecastDaily != null
        ? _buildBodyDetail(
            weatherForecastDaily.daily![0], weatherForecastDaily.current!)
        : Container();
  }

  _buildBodyDetail(Daily daily, CurrentDailyWeather currentDailyWeather) {
    return Column(
      children: [
        _buildRowTitle(
            'detail'.tr,
            'more'.tr,
            weatherData != null
                ? () {
                    appBloc.showInterstitialAd();
                    gotoDailyDetailScreen();
                  }
                : () {}),
        DetailWeatherWidget(
          weatherData: weatherData,
          daily: daily,
        )
      ],
    );
  }

  _buildWindAndPressure(WeatherResponse? weatherResponse) {
    return weatherResponse != null
        ? _bodyWindAndPressure(weatherResponse)
        : Container();
  }

  _buildAriPollution() {
    return StreamBuilder<WeatherState>(
        stream: bloc.airPollutionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data is AirStateSuccess) {
            AirStateSuccess state = snapshot.data! as AirStateSuccess;
            return _airPollutionBody(state.airResponse);
          }
          return Container();
        });
  }

  _bodyWindAndPressure(WeatherResponse weatherResponse) {
    return Column(
      children: [
        _buildRowTitle(
            '${'wind'.tr} & ${'pressure'.tr}',
            'more'.tr,
            weatherData != null
                ? () {
                    appBloc.showInterstitialAd();
                    gotoDailyDetailScreen();
                  }
                : () {}),
        PressureAndWind(
          weatherData: weatherData,
          weatherResponse: weatherResponse,
        )
      ],
    );
  }

  _airPollutionBody(AirResponse airResponse) {
    return Column(
      children: [
        _buildRowTitle(
            'air_quality'.tr,
            'more'.tr,
            weatherData != null
                ? () {
                    appBloc.showInterstitialAd();
                    gotoDailyDetailScreen();
                  }
                : () {}),
        GestureDetector(
            onTap: weatherData != null
                ? () {
                    appBloc.showInterstitialAd();
                    gotoDailyDetailScreen();
                  }
                : () {},
            child: AirPollutionWidget(airResponse.data))
      ],
    );
  }

  _buildSunTime(WeatherResponse? weatherResponse) {
    return weatherResponse != null
        ? _buildSunTimeBody(weatherResponse)
        : Container();
  }

  _buildSunTimeBody(WeatherResponse weatherResponse) {
    return Column(
      children: [
        _buildRowTitle(
            '${'sun'.tr} & ${'moon'.tr}',
            'more'.tr,
            weatherData != null
                ? () {
                    appBloc.showInterstitialAd();
                    gotoDailyDetailScreen();
                  }
                : () {}),
        Container(
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.symmetric(vertical: margin, horizontal: padding),
          decoration: BoxDecoration(
              color: transparentBg,
              borderRadius: BorderRadius.circular(radiusSmall),
              border: Border.all(color: Colors.grey, width: 0.5)),
          child: Column(
            children: [
              GestureDetector(
                  onTap: weatherData != null
                      ? () {
                          appBloc.showInterstitialAd();
                          gotoDailyDetailScreen();
                        }
                      : () {},
                  child: RepaintBoundary(
                    child: SunPathWidget(
                      sunrise: weatherResponse.system!.sunrise,
                      sunset: weatherResponse.system!.sunset,
                      differentTime: differentTime,
                    ),
                  )),
              Container(
                margin: EdgeInsets.symmetric(vertical: margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system!.sunrise!), settingBloc.timeEnum)}',
                      style: textSecondaryWhite70,
                    ),
                    Text(
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system!.sunset!), settingBloc.timeEnum)}',
                      style: textSecondaryWhite70,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> refresh() async {
    getData();
    appBloc.showInterstitialAd();
  }

  gotoDailyDetailScreen() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailDailyForecast(
                currentIndex: 0,
                weatherForecastDaily: weatherData!.weatherForecastDaily,
              )));
}

class WeatherData {
  final WeatherResponse? weatherResponse;
  final WeatherForecastListResponse? weatherForecastListResponse;
  final WeatherForecastDaily? weatherForecastDaily;
  final WeatherStateError? error;

  WeatherData(
      {this.weatherResponse,
      this.weatherForecastListResponse,
      this.weatherForecastDaily,
      this.error});

  WeatherData copyWith(
      {WeatherResponse? weatherResponse,
      WeatherForecastListResponse? weatherForecastListResponse,
      WeatherForecastDaily? weatherForecastDaily,
      WeatherStateError? error}) {
    return WeatherData(
        weatherResponse: weatherResponse ?? this.weatherResponse,
        weatherForecastListResponse:
            weatherForecastListResponse ?? this.weatherForecastListResponse,
        weatherForecastDaily: weatherForecastDaily ?? this.weatherForecastDaily,
        error: error ?? this.error);
  }
}

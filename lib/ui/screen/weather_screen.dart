import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:rxdart/subjects.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/ui/widgets/air_pollution_widget.dart';

import '../../bloc/api_service_bloc.dart';
import '../../bloc/base_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../model/air_response.dart';
import '../../model/chart_data.dart';
import '../../model/city.dart';
import '../../model/current_daily_weather.dart';
import '../../model/daily.dart';
import '../../model/weather_forcast_daily.dart';
import '../../model/weather_forecast_holder.dart';
import '../../model/weather_forecast_list_response.dart';
import '../../model/weather_response.dart';
import '../../shared/colors.dart';
import '../../shared/constant.dart';
import '../../shared/dimens.dart';
import '../../shared/image.dart';
import '../../shared/strings.dart';
import '../../shared/text_style.dart';
import '../../ui/screen/add_city_screen.dart';
import '../../ui/screen/daily_forecast_screen.dart';
import '../../ui/screen/edit_location_screen.dart';
import '../../ui/screen/hourly_forecast_screen.dart';
import '../../ui/widgets/chart_widget.dart';
import '../../ui/widgets/smarr_refresher.dart';
import '../../ui/widgets/sun_path_widget.dart';
import '../../utils/utils.dart';
import '../widgets/air_pollution_widget.dart';
import 'detail_daily_forecast.dart';

const double _mainWeatherHeight = 240;
const double _mainWeatherWidth = 2000;
const double _chartHeight = 30;
const double _dailySectionHeight = 520;
const String _exclude7DayForecast = 'minutely,hourly';

const double _bigIconSize = 16;
const double _smallIconSize = _bigIconSize;
const double _iconWindPathSize = 50;
const double _iconWindPillarHeight = 60;
const double _iconWindPillarWidth = 50;
const double _iconWindPathSmallSize = 30;
const double _iconWindPillarSmallHeight = 40;
const double _iconWindPillarSmallWidth = 30;
const double _iconDrawerSize = 30;
const int _defaultDisplayNumberLocation = 4;
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
  AnimationController? _controller;
  AnimationController? _controller2;
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
      _listenListCityChange();
      _listenChangeSetting();
      _initAnim();
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

  _initAnim() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
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
    _controller?.dispose();
    _controller2?.dispose();
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
                drawer: _drawer(),
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

  _drawer() => Drawer(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [_drawerBody(), _drawerHeader()],
          ),
        ),
      );

  _drawerHeader() => Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: margin),
                Text('app_name'.tr, style: textTitleH1White),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white70),
        ],
      );

  _drawerBody() => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _listLocation(),
            Divider(height: 1, color: Colors.grey),
            _buildItemDrawer(
                mIconSettingNotify,
                'notification'.tr,
                Switch(
                  value: settingBloc.isOnNotification,
                  onChanged: (isOn) {
                    isOnNotification = isOn;
                    _showNotification(
                        isOnNotification, weatherData!.weatherResponse);
                  },
                ), () {
              isOnNotification = !isOnNotification;
              _showNotification(isOnNotification, weatherData!.weatherResponse);
            }),
            _buildItemUnit(
                mIconSettingTemp,
                'temp_unit'.tr,
                settingBloc.tempEnum.value,
                () => showSettingDialog(SettingEnum.TempEnum)),
            _buildItemUnit(
                mIconWind,
                'wind_unit'.tr,
                settingBloc.windEnum.value,
                () => showSettingDialog(SettingEnum.WindEnum)),
            _buildItemUnit(
                mIconSettingPressure,
                'pressure_unit'.tr,
                settingBloc.pressureEnum.value,
                () => showSettingDialog(SettingEnum.PressureEnum)),
            _buildItemUnit(
                mIconSettingVisibility,
                'visibility_unit'.tr,
                settingBloc.visibilityEnum.value,
                () => showSettingDialog(SettingEnum.VisibilityEnum)),
            _buildItemUnit(
                imSettingTime,
                'time_format'.tr,
                settingBloc.timeEnum.value,
                () => showSettingDialog(SettingEnum.TimeEnum)),
            _buildItemUnit(
                imSettingDate,
                'date_format'.tr,
                settingBloc.dateEnum.value,
                () => showSettingDialog(SettingEnum.DateEnum)),
            InkWell(
              onTap: () => showLanguageDialog(SettingEnum.Language),
              child: Container(
                padding: EdgeInsets.only(
                    left: padding, right: paddingSmall, bottom: padding),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.language,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: padding),
                    Text('setting_language'.tr, style: textTitleWhite),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey),
            InkWell(
              onTap: () {
                launch(appUrl);
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: padding, right: paddingSmall, top: padding),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.system_update,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: padding),
                    Text('check_update'.tr, style: textTitleWhite),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  _listLocation() {
    return StreamBuilder<List<City>>(
        stream: pageBloc.currentCitiesStream as Stream<List<City>>?,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: padding, right: paddingSmall, bottom: padding),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          appBloc.showInterstitialAd();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditLocationScreen()));
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              mIconEditingLocation,
                              width: _iconDrawerSize,
                              height: _iconDrawerSize,
                            ),
                            const SizedBox(width: padding),
                            Text('edit_location'.tr, style: textTitleWhite),
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.length >
                                  _defaultDisplayNumberLocation
                              ? isShowMore
                                  ? snapshot.data!.length
                                  : _defaultDisplayNumberLocation
                              : snapshot.data!.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _itemLocation(snapshot.data![index], index);
                          }),
                      _showMoreLocation(snapshot.data!.length)
                    ],
                  ),
                ),
              ],
            );
          }

          return Container();
        });
  }

  _itemLocation(City city, int index) {
    return InkWell(
      onTap: () => pageBloc.jumpToPage(index),
      child: Container(
        padding: EdgeInsets.only(top: padding),
        child: Row(
          children: [
            Image.asset(
              mIconSettingLocation,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text('${city.name}', style: textTitleWhite),
          ],
        ),
      ),
    );
  }

  _showMoreLocation(int locationLength) {
    if (locationLength > _defaultDisplayNumberLocation) {
      return InkWell(
        onTap: () => setState(() {
          isShowMore = !isShowMore;
        }),
        child: Container(
          padding: EdgeInsets.only(top: padding),
          child: Row(
            children: [
              Image.asset(
                mIconMoreHoriz,
                width: _iconDrawerSize,
                height: _iconDrawerSize,
              ),
              const SizedBox(width: padding),
              Text(
                isShowMore
                    ? 'collapse'.tr
                    : '${'show_more'.tr} ${locationLength - _defaultDisplayNumberLocation}',
                style: textTitleWhite,
              ),
              Expanded(child: Container()),
              Icon(
                isShowMore
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
                size: _iconDrawerSize,
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _showNotification(bool isOn, WeatherResponse? response) {
    settingBloc.onOffNotification(isOn, response);
    setState(() {});
  }

  _buildItemDrawer(
      String imagePath, String title, Widget widget, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding:
            EdgeInsets.only(left: padding, right: paddingSmall, top: padding),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              color: Colors.white,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text(title, style: textTitleWhite),
            Expanded(child: Container()),
            widget
          ],
        ),
      ),
    );
  }

  _buildItemUnit(
      String imagePath, String title, String unit, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.only(
            left: padding, right: paddingSmall, bottom: padding),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              color: Colors.white,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text(title, style: textTitleWhite),
            Expanded(child: Container()),
            Text(unit, style: textSecondaryUnderlineBlue)
          ],
        ),
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
    return Container(
        height: _mainWeatherHeight,
        margin: EdgeInsets.symmetric(vertical: margin),
        child: weatherResponse != null
            ? _buildBodyCurrentWeather(weatherResponse)
            : Container());
  }

  _buildBodyCurrentWeather(WeatherResponse weatherResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${weatherResponse.overallWeatherData![0].description}',
          style: textTitleH1White,
        ),
        const SizedBox(
          height: marginLarge,
        ),
        _buildTempRow(weatherResponse.mainWeatherData!.temp),
        const SizedBox(height: margin),
        _buildFeelsLike(weatherResponse.mainWeatherData!.feelsLike,
            weatherResponse.mainWeatherData!.humidity),
        const SizedBox(height: margin),
        _buildMaxMinTemp(weatherResponse.mainWeatherData!.tempMax,
            weatherResponse.mainWeatherData!.tempMin)
      ],
    );
  }

  _buildTempRow(double temp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatTemperature(temperature: temp),
          style: textMainTemp,
        ),
        Text(
          settingBloc.tempEnum.value.substring(1),
          style: textTitleH1White,
        )
      ],
    );
  }

  _buildFeelsLike(double temp, double humidity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'feels_like_'.tr,
          style: textTitleH1White,
        ),
        Text(
          formatTemperature(temperature: temp),
          style: textTitleH1White,
        ),
        SizedBox(
          width: marginLarge,
        ),
        Image.asset(
          mHomePrecipitation,
          width: 14,
          height: 20,
        ),
        Text(
          ' ${humidity.toInt()}%',
          style: textTitleH1White,
        ),
      ],
    );
  }

  _buildMaxMinTemp(double maxTemp, double minTemp) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            mIconHigh,
            height: 20,
          ),
          const SizedBox(
            width: marginSmall,
          ),
          Text(formatTemperature(temperature: maxTemp),
              style: textTitleH1White),
          const SizedBox(
            width: marginLarge,
          ),
          Image.asset(
            mIconLow,
            height: 20,
          ),
          const SizedBox(
            width: marginSmall,
          ),
          Text(formatTemperature(temperature: minTemp),
              style: textTitleH1White),
        ],
      );

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
        GestureDetector(
          onTap: () {
            appBloc.showInterstitialAd();
             Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HourlyForecastScreen(
                        weatherForecastListResponse:
                            weatherForecastListResponse,
                      )));
          },
          child: Container(
            margin: EdgeInsets.all(margin),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                color: transparentBg,
                borderRadius: BorderRadius.circular(radiusSmall)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: _mainWeatherHeight,
                width: _mainWeatherWidth,
                margin:
                    EdgeInsets.only(left: marginXLarge, right: marginXLarge),
                child: Center(
                  child: ChartWidget(
                    chartData: WeatherForecastHolder(
                      weatherForecastListResponse.list!,
                    ).setupChartData(ChartDataType.temperature,
                        _mainWeatherWidth, _chartHeight),
                  ),
                ),
              ),
            ),
          ),
        ),
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
        Container(
          height: _dailySectionHeight,
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.only(bottom: padding),
          decoration: BoxDecoration(
              color: transparentBg,
              borderRadius: BorderRadius.circular(radiusSmall),
              border: Border.all(color: Colors.grey, width: 0.5)),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(paddingLarge),
                  child: Text(
                    "${weatherForecastDaily.daily![0].weather![0].description}",
                    style: textTitleH1White,
                  )),
              Divider(
                height: 1,
                color: Colors.white,
              ),
              Expanded(child: _buildDailyRow(weatherForecastDaily))
            ],
          ),
        ),
      ],
    );
  }

  _buildDailyRow(WeatherForecastDaily data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: data.daily!.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          DateFormat dayFormat =
              DateFormat("MM/dd", Get.deviceLocale!.languageCode);
          DateFormat weekDayFormat =
              DateFormat("E", Get.deviceLocale!.languageCode);
          String day = dayFormat.format(
              DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!));
          String weekday = DateTime.fromMillisecondsSinceEpoch(
                          (DateTime.now().millisecondsSinceEpoch +
                                  differentTime * _oneHour)
                              .toInt())
                      .day ==
                  DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!)
                      .day
              ? 'today'.tr
              : weekDayFormat.format(
                  DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!));
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailDailyForecast(
                          weatherForecastDaily: data,
                          currentIndex: index,
                        ))),
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: marginSmall, horizontal: margin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekday,
                          style: textTitleWhite,
                        ),
                        Text(
                          day,
                          style: textSmallWhite70,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: getIconForecastImage(
                          data.daily![index].weather![0].icon,
                          width: 30,
                          height: 30)),
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(left: margin),
                        child: Text(
                          '${data.daily![index].weather![0].description}',
                          style: textTitleWhite70,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(left: marginLarge),
                        child: Text(
                          '${data.daily![index].temp!.min!.toInt()}$degree - '
                          '${data.daily![index].temp!.max!.toInt()}$degree',
                          style: textTitleWhite,
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(left: marginLarge),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white54,
                          size: 20,
                        )),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey,
        ),
      ),
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
        GestureDetector(
          onTap: weatherData != null
              ? () {
                  appBloc.showInterstitialAd();
                  gotoDailyDetailScreen();
                }
              : () {},
          child: Container(
            margin: EdgeInsets.all(margin),
            padding: EdgeInsets.symmetric(
                vertical: paddingLarge, horizontal: padding),
            decoration: BoxDecoration(
                color: transparentBg,
                borderRadius: BorderRadius.circular(radiusSmall),
                border: Border.all(color: Colors.grey, width: 0.5)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('precipitation'.tr,
                          mIcPrecipitation, formatHumidity(daily.pop!)),
                    ),
                    _verticalDivider(),
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('humidity'.tr, mIconHumidity,
                          formatHumidity(daily.humidity!.toDouble())),
                    ),
                    _verticalDivider(),
                    Expanded(
                        flex: 1,
                        child: _buildItemDetail(
                          'uv_index'.tr,
                          mIconUVIndex,
                          daily.uvi!.toStringAsFixed(0),
                        ))
                  ],
                ),
                const SizedBox(
                  height: margin,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail(
                          'visibility'.tr,
                          mIconVisibility,
                          formatVisibility(currentDailyWeather.visibility!,
                              settingBloc.visibilityEnum.value)),
                    ),
                    _verticalDivider(),
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('dew_point'.tr, mIconDewPoint,
                          formatTemperature(temperature: daily.dewPoint)),
                    ),
                    _verticalDivider(),
                    Expanded(
                        flex: 1,
                        child: _buildItemDetail(
                          'cloud_cover'.tr,
                          mIconCloudCover,
                          formatHumidity(daily.clouds!.toDouble()),
                        ))
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _verticalDivider() => Container(
        height: 40,
        width: 1,
        color: Colors.grey,
      );

  _buildItemDetail(String tittle, String iconPath, String content) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: _bigIconSize,
                height: _bigIconSize,
              ),
              SizedBox(
                width: marginSmall,
              ),
              Expanded(
                child: Text(
                  tittle,
                  style: textSmallWhite70,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          SizedBox(
            height: margin,
          ),
          Text(
            '$content',
            style: textTitleWhite,
          )
        ],
      );

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
        GestureDetector(
          onTap: weatherData != null
              ? () {
                  appBloc.showInterstitialAd();
                  gotoDailyDetailScreen();
                }
              : () {},
          child: Container(
            margin: EdgeInsets.all(margin),
            padding: EdgeInsets.symmetric(
                vertical: paddingLarge, horizontal: padding),
            decoration: BoxDecoration(
                color: transparentBg,
                borderRadius: BorderRadius.circular(radiusSmall),
                border: Border.all(color: Colors.grey, width: 0.5)),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            AnimatedBuilder(
                                animation: _controller!,
                                builder: (context, _child) {
                                  return Transform.rotate(
                                      angle: _controller!.value * 2 * math.pi,
                                      child: _child);
                                },
                                child: Image.asset(
                                  mIconWindPath,
                                  width: _iconWindPathSize,
                                  height: _iconWindPathSize,
                                )),
                            Container(
                                margin:
                                    EdgeInsets.only(top: _iconWindPathSize / 2),
                                child: Image.asset(
                                  mIconWindPillar,
                                  width: _iconWindPillarWidth,
                                  height: _iconWindPillarHeight,
                                ))
                          ],
                        ),
                        Stack(
                          children: [
                            AnimatedBuilder(
                                animation: _controller2!,
                                builder: (context, _child) {
                                  return Transform.rotate(
                                      angle: _controller2!.value * 2 * math.pi,
                                      child: _child);
                                },
                                child: Image.asset(
                                  mIconWindPath,
                                  width: _iconWindPathSmallSize,
                                  height: _iconWindPathSmallSize,
                                )),
                            Container(
                                margin: EdgeInsets.only(
                                    top: _iconWindPathSmallSize / 2),
                                child: Image.asset(
                                  mIconWindPillar,
                                  width: _iconWindPillarSmallWidth,
                                  height: _iconWindPillarSmallHeight,
                                ))
                          ],
                        )
                      ],
                    )),
                const SizedBox(
                  width: margin,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            mIconWind,
                            width: _bigIconSize,
                            height: _bigIconSize,
                          ),
                          const SizedBox(
                            width: marginSmall,
                          ),
                          Text(
                            'wind'.tr,
                            style: textSmallWhite70,
                          )
                        ],
                      ),
                      Text(
                        '${formatWind(weatherResponse.wind!.speed, settingBloc.windEnum.value)} ${getWindDirection(weatherResponse.wind!.deg)}',
                        style: textTitleWhite,
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: marginSmall,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                mIconDownArrow,
                                width: _bigIconSize,
                                height: _bigIconSize,
                                color: Colors.white,
                              ),
                              Image.asset(
                                mIconDownArrow,
                                width: _bigIconSize,
                                height: _smallIconSize,
                                color: Colors.white,
                              ),
                              Text(
                                'pressure'.tr,
                                style: textSmallWhite70,
                              )
                            ],
                          ),
                          Text(
                            '${formatPressure(weatherResponse.mainWeatherData!.pressure, settingBloc.pressureEnum.value)}',
                            style: textTitleWhite,
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
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

  showSettingDialog(SettingEnum settingEnum) {
    List<String> settings = [];
    String groupValue = '';
    String title = '';
    switch (settingEnum) {
      case SettingEnum.TempEnum:
        TempEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'temp_unit'.tr;
        groupValue = settingBloc.tempEnum.value;
        break;
      case SettingEnum.WindEnum:
        WindEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'wind_unit'.tr;
        groupValue = settingBloc.windEnum.value;
        break;
      case SettingEnum.PressureEnum:
        PressureEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'pressure_unit'.tr;
        groupValue = settingBloc.pressureEnum.value;
        break;
      case SettingEnum.VisibilityEnum:
        VisibilityEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'visibility_unit'.tr;
        groupValue = settingBloc.visibilityEnum.value;
        break;
      case SettingEnum.TimeEnum:
        TimeEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'time_format'.tr;
        groupValue = settingBloc.timeEnum.value;
        break;
      case SettingEnum.DateEnum:
        DateEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'date_format'.tr;
        groupValue = settingBloc.dateEnum.value;
        break;
      case SettingEnum.Language:
        // TODO: Handle this case.
        break;
    }

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: textTitleBold,
                        )),
                    ...settings.map((e) {
                      return Container(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: InkWell(
                            onTap: () {
                              _changeSetting(e, settingEnum);
                            },
                            child: ListTile(
                              title: Text(e),
                              leading: Radio<String>(
                                value: e,
                                groupValue: groupValue,
                                onChanged: (String? value) {
                                  _changeSetting(value, settingEnum);
                                },
                              ),
                            ),
                          ));
                    })
                  ],
                ),
              ),
            ),
          );
        });
  }

  showLanguageDialog(SettingEnum settingEnum) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'setting_language'.tr,
                          style: textTitleBold,
                        )),
                    ...LanguageEnum.values.toList().map((e) {
                      return Container(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: InkWell(
                            onTap: () {
                              _changeLanguageSetting(e);
                            },
                            child: ListTile(
                              title: Text(e.value),
                              leading: Radio<LanguageEnum>(
                                value: e,
                                groupValue: settingBloc.languageEnum,
                                onChanged: (LanguageEnum? value) {
                                  print(value);
                                  _changeLanguageSetting(value);
                                },
                              ),
                            ),
                          ));
                    })
                  ],
                ),
              ),
            ),
          );
        });
  }

  _changeSetting(String? value, SettingEnum settingEnum) {
    Navigator.pop(context);
    settingBloc.changeSetting(value, settingEnum);
  }

  _changeLanguageSetting(LanguageEnum? value) {
    Navigator.pop(context);
    settingBloc.changeLanguageSetting(value);
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

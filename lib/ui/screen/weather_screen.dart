import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/api_service_bloc.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/base_bloc.dart';
import '../../bloc/page_bloc.dart';
import '../../bloc/setting_bloc.dart';
import '../../model/chart_data.dart';
import '../../model/city.dart';
import '../../model/current_daily_weather.dart';
import '../../model/daily.dart';
import '../../model/timezone.dart';
import '../../model/weather_forecast_7_day.dart';
import '../../model/weather_forecast_holder.dart';
import '../../model/weather_forecast_list_response.dart';
import '../../model/weather_forecast_response.dart';
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

class WeatherScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final int index;

  const WeatherScreen({Key key, this.lat, this.lon, this.index});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final ApiServiceBloc bloc = ApiServiceBloc();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  WeatherResponse weatherResponse;
  WeatherForecastListResponse weatherForecastListResponse;
  WeatherForecastDaily weatherForecastDaily;
  WeatherData weatherData;
  BehaviorSubject<DateTime> timeSubject =
      BehaviorSubject.seeded(DateTime.now());
  BehaviorSubject<double> _scrollSubject = BehaviorSubject.seeded(0);
  AnimationController _controller;
  AnimationController _controller2;
  ScrollController _scrollController = ScrollController();
  int currentTime = 0;
  String timezone = '';
  int differentTime = 0;
  bool isOnNotification = false;
  int listLocationLength = 0;
  bool isShowMore = false;

  @override
  void initState() {
    super.initState();
    print('initState ${widget.index}');
    _listenListCityChange();
    _listenChangeSetting();
    _initAnim();
    _scrollController.addListener(() {
      _scrollSubject.add(_scrollController.offset);
    });
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
        DateTime.now().millisecondsSinceEpoch + differentTime * oneHourMilli));
  }

  getData({double lat, double lon}) {
    print('getdata');
    bloc.fetchWeatherForecast7Day(
        lat ?? widget.lat, lon ?? widget.lon, _exclude7DayForecast);
    bloc.fetchWeather(lat ?? widget.lat, lon ?? widget.lon);
    bloc.fetchWeatherForecastResponse(lat ?? widget.lat, lon ?? widget.lon);
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

  _listenChangeSetting(){
    settingBloc.settingStream.listen((event) {
      if (this.mounted) {
        setState(() {
          convertDataAndFormatTime();
        });
      }
    });
  }
  @override
  void dispose() {
    print('dispose ${widget.index}');
    _controller.dispose();
    _controller2.dispose();
    timeSubject.close();
    _scrollSubject.close();
    bloc.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return StreamBuilder<WeatherData>(
      stream: Rx.combineLatest3(bloc.weatherStream, bloc.weatherForecastStream,
          bloc.weatherForecastDailyStream, (a, b, c) {
        if (a is WeatherStateSuccess &&
            b is WeatherForecastStateSuccess &&
            c is WeatherForecastDailyStateSuccess) {
          differentTime = _getDifferentTime(c.weatherResponse.timezone);
          return WeatherData(
              weatherResponse: a.weatherResponse,
              weatherForecastListResponse: b.weatherResponse,
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
              weatherData.weatherForecastListResponse.city);
          _createTime(DateTime.fromMillisecondsSinceEpoch(
              weatherData.weatherForecastDaily.current.dt));
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
                                        sigmaY:
                                            (snapshot.data * _ratioBlurImageBg),
                                        sigmaX: (snapshot.data *
                                            _ratioBlurImageBg)),
                                    child: Image.asset(
                                      getBgImagePath(weatherData.weatherResponse
                                          .overallWeatherData[0].icon),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(
                                      snapshot.data * _ratioBlurBg),
                                ),
                              ],
                            );
                          }
                          return Container();
                        }),
                    _body(weatherData)
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
    WeatherResponse weatherResponse = weatherData.weatherResponse;
    WeatherForecastListResponse weatherForecastListResponse =
        weatherData.weatherForecastListResponse;
    WeatherForecastDaily weatherForecastDaily =
        weatherData.weatherForecastDaily;
    weatherData = weatherData.copyWith(
        weatherResponse: weatherResponse.copyWith(
            dt: weatherResponse.dt + differentTime * oneHourMilli,
            wind: weatherResponse.wind.copyWith(
                speed: convertWindSpeed(
                    weatherResponse.wind.speed, settingBloc.windEnum)),
            mainWeatherData: weatherResponse.mainWeatherData.copyWith(
                pressure: convertPressure(
                    weatherResponse.mainWeatherData.pressure,
                    settingBloc.pressureEnum),
                temp: convertTemp(
                    weatherResponse.mainWeatherData.temp, settingBloc.tempEnum),
                tempMin: convertTemp(weatherResponse.mainWeatherData.tempMin,
                    settingBloc.tempEnum),
                tempMax: convertTemp(weatherResponse.mainWeatherData.tempMax,
                    settingBloc.tempEnum),
                feelsLike: convertTemp(
                    weatherResponse.mainWeatherData.feelsLike,
                    settingBloc.tempEnum))),
        weatherForecastListResponse: weatherForecastListResponse.copyWith(
            list: _convertForecastListResponse(weatherForecastListResponse)),
        weatherForecastDaily: weatherForecastDaily.copyWith(
            daily: _convertListDaily(weatherForecastDaily.daily),
            current: weatherForecastDaily.current.copyWith(
                visibility: convertVisibility(weatherForecastDaily.current.visibility, settingBloc.visibilityEnum),
                feelsLike: convertTemp(weatherForecastDaily.current.feelsLike, settingBloc.tempEnum),
                temp: convertTemp(weatherForecastDaily.current.temp, settingBloc.tempEnum))));
  }

  List<WeatherForecastResponse> _convertForecastListResponse(
      WeatherForecastListResponse weatherForecastListResponse) {
    List<WeatherForecastResponse> list =
        weatherForecastListResponse.list.map((e) {
      return e.copyWith(
          dt: e.dt + differentTime * oneHourMilli,
          wind: e.wind.copyWith(
              speed: convertWindSpeed(e.wind.speed, settingBloc.windEnum)),
          mainWeatherData: e.mainWeatherData.copyWith(
              pressure: convertPressure(
                  e.mainWeatherData.pressure, settingBloc.pressureEnum),
              temp: convertTemp(e.mainWeatherData.temp, settingBloc.tempEnum),
              feelsLike: convertTemp(
                  e.mainWeatherData.feelsLike, settingBloc.tempEnum),
              tempMax:
                  convertTemp(e.mainWeatherData.tempMax, settingBloc.tempEnum),
              tempMin: convertTemp(
                  e.mainWeatherData.tempMin, settingBloc.tempEnum)));
    }).toList();
    return list;
  }

  _convertListDaily(List<Daily> dailies) {
    return dailies
        .map((e) => e.copyWith(
            windSpeed: convertWindSpeed(e.windSpeed, settingBloc.windEnum),
            dewPoint: convertTemp(e.temp.day, settingBloc.tempEnum),
            pressure: convertPressure(e.pressure, settingBloc.pressureEnum),
            temp: e.temp.copyWith(
                day: convertTemp(e.temp.day, settingBloc.tempEnum),
                eve: convertTemp(e.temp.eve, settingBloc.tempEnum),
                max: convertTemp(e.temp.max, settingBloc.tempEnum),
                min: convertTemp(e.temp.min, settingBloc.tempEnum),
                morn: convertTemp(e.temp.morn, settingBloc.tempEnum),
                night: convertTemp(e.temp.night, settingBloc.tempEnum)),
            feelsLike: e.feelsLike.copyWith(
                day: convertTemp(e.temp.day, settingBloc.tempEnum),
                eve: convertTemp(e.feelsLike.eve, settingBloc.tempEnum),
                morn: convertTemp(e.feelsLike.morn, settingBloc.tempEnum),
                night: convertTemp(e.feelsLike.night, settingBloc.tempEnum))))
        .toList();
  }

  int _getDifferentTime(String timezone) {
    String value = '';
    for (Timezone time in appBloc.timezones) {
      if (time.value.contains(getTimezone(timezone))) {
        value = getTimezone(time.name);
      }
    }
    return value == '' ? 0 : convertTimezoneToNumber(value);
  }

  String getTimezone(String timezone) =>
      timezone.substring(timezone.indexOf('/') + 1, timezone.length);

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
                            .weatherResponse.overallWeatherData[0].icon)),
                        fit: BoxFit.fill)),
              ),
              StreamBuilder<double>(
                  stream: _scrollSubject.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        color: Colors.black
                            .withOpacity(snapshot.data * _ratioBlurBg),
                      );
                    }
                    return Container();
                  })
            ],
          ),
          actions: [
            GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddCityScreen())),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
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
              _buildSunTime(weatherData.weatherResponse,
                  weatherData.weatherForecastDaily.timezone)
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
                Text('Weather', style: textTitleH2White),
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
                'Notification',
                Switch(
                  value: settingBloc.isOnNotification,
                  onChanged: (isOn) {
                    isOnNotification = isOn;
                    _showNotification(
                        isOnNotification, weatherData.weatherResponse);
                  },
                ), () {
              isOnNotification = !isOnNotification;
              _showNotification(isOnNotification, weatherData.weatherResponse);
            }),
            _buildItemUnit(
                mIconSettingTemp,
                'Temp Unit',
                settingBloc.tempEnum.value,
                () => showSettingDialog(SettingEnum.TempEnum)),
            _buildItemUnit(mIconWind, 'Wind Unit', settingBloc.windEnum.value,
                () => showSettingDialog(SettingEnum.WindEnum)),
            _buildItemUnit(
                mIconSettingPressure,
                'Pressure Unit',
                settingBloc.pressureEnum.value,
                () => showSettingDialog(SettingEnum.PressureEnum)),
            _buildItemUnit(mIconSettingVisibility, 'Visibility Unit', 'km',
                () => showSettingDialog(SettingEnum.VisibilityEnum)),
            _buildItemUnit(
                mIconSettingTemp,
                'Time Format',
                settingBloc.timeEnum.value,
                () => showSettingDialog(SettingEnum.TimeEnum)),
            _buildItemUnit(
                mIconSettingTemp,
                'Date Format',
                settingBloc.dateEnum.value,
                () => showSettingDialog(SettingEnum.DateEnum)),
          ],
        ),
      );

  _listLocation() {
    return StreamBuilder<List<City>>(
        stream: pageBloc.currentCitiesStream,
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
                          Navigator.pop(context);
                          return Navigator.push(
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
                            Text('Edit Location', style: textTitleWhite),
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data.length >
                                  _defaultDisplayNumberLocation
                              ? isShowMore
                                  ? snapshot.data.length
                                  : _defaultDisplayNumberLocation
                              : snapshot.data.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _itemLocation(snapshot.data[index], index);
                          }),
                      _showMoreLocation(snapshot.data.length)
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
          print('isShowMore $isShowMore');
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
                    ? 'Collapse'
                    : 'Show more ${locationLength - _defaultDisplayNumberLocation}',
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

  _showNotification(bool isOn, WeatherResponse response) {
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
    return GestureDetector(
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

  _titleAppbar(WeatherResponse weatherResponse) {
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

  _currentWeather(WeatherResponse weatherResponse) {
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
          '${weatherResponse.overallWeatherData[0].main}',
          style: textTitleH1White,
        ),
        const SizedBox(
          height: marginLarge,
        ),
        _buildTempRow(weatherResponse.mainWeatherData.temp),
        const SizedBox(height: margin),
        _buildFeelsLike(weatherResponse.mainWeatherData.feelsLike,
            weatherResponse.mainWeatherData.humidity),
        const SizedBox(height: margin),
        _buildMaxMinTemp(weatherResponse.mainWeatherData.tempMax,
            weatherResponse.mainWeatherData.tempMin)
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
          'Feels like: ',
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
          '${humidity.toInt()}%',
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
      WeatherForecastListResponse weatherForecastListResponse) {
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
        _buildRowTitle(
            'Hourly Forecast',
            'More',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HourlyForecastScreen(
                          weatherForecastListResponse:
                              weatherForecastListResponse,
                        )))),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HourlyForecastScreen(
                        weatherForecastListResponse:
                            weatherForecastListResponse,
                      ))),
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
                      weatherForecastListResponse.list,
                      weatherForecastListResponse.city,
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

  _buildDailyForecast(WeatherForecastDaily weatherForecastDaily) {
    return weatherForecastDaily != null
        ? _buildBodyDailyForecast(weatherForecastDaily)
        : Container();
  }

  _buildBodyDailyForecast(WeatherForecastDaily weatherForecastDaily) {
    return Column(
      children: [
        _buildRowTitle(
            'Daily Forecast',
            'More',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DailyForecastScreen(
                          weatherForecastDaily: weatherForecastDaily,
                        )))),
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
                    "${weatherForecastDaily.daily[0].weather[0].description}",
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
        itemCount: data.daily.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          DateFormat dayFormat = DateFormat("MM/dd");
          DateFormat weekDayFormat = DateFormat("E");
          String day = dayFormat.format(
              DateTime.fromMillisecondsSinceEpoch(data.daily[index].dt));
          String weekday = DateTime.now().day ==
                  DateTime.fromMillisecondsSinceEpoch(data.daily[index].dt).day
              ? 'Today'
              : weekDayFormat.format(
                  DateTime.fromMillisecondsSinceEpoch(data.daily[index].dt));
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
                          data.daily[index].weather[0].icon,
                          width: 30,
                          height: 30)),
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(left: margin),
                        child: Text(
                          '${data.daily[index].weather[0].description}',
                          style: textTitleWhite70,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(left: marginLarge),
                        child: Text(
                          '${data.daily[index].temp.min.toInt()}$degree - '
                          '${data.daily[index].temp.max.toInt()}$degree',
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

  _buildDetail(WeatherForecastDaily weatherForecastDaily) {
    return weatherForecastDaily != null
        ? _buildBodyDetail(
            weatherForecastDaily.daily[0], weatherForecastDaily.current)
        : Container();
  }

  _buildBodyDetail(Daily daily, CurrentDailyWeather currentDailyWeather) {
    return Column(
      children: [
        _buildRowTitle(
            'Detail',
            'More',
            weatherData != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily:
                                  weatherData.weatherForecastDaily,
                            )))
                : () {}),
        GestureDetector(
          onTap: weatherData != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            currentIndex: 0,
                            weatherForecastDaily:
                                weatherData.weatherForecastDaily,
                          )))
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
                      child: _buildItemDetail(
                          'Pop', mIcPrecipitation, formatHumidity(daily.pop)),
                    ),
                    _verticalDivider(),
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('Humidity', mIconHumidity,
                          formatHumidity(daily.humidity.toDouble())),
                    ),
                    _verticalDivider(),
                    Expanded(
                        flex: 1,
                        child: _buildItemDetail(
                          'UV Index',
                          mIconUVIndex,
                          daily.uvi.toStringAsFixed(0),
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
                          'Visibility',
                          mIconVisibility,
                          formatVisibility(currentDailyWeather.visibility,
                              settingBloc.visibilityEnum.value)),
                    ),
                    _verticalDivider(),
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('Dew Point', mIconDewPoint,
                          formatTemperature(temperature: daily.dewPoint)),
                    ),
                    _verticalDivider(),
                    Expanded(
                        flex: 1,
                        child: _buildItemDetail(
                          'Cloud Cover',
                          mIconCloudCover,
                          formatHumidity(daily.clouds.toDouble()),
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
              Text(
                tittle,
                style: textSmallWhite70,
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

  _buildWindAndPressure(WeatherResponse weatherResponse) {
    return weatherResponse != null
        ? _bodyWindAndPressure(weatherResponse)
        : Container();
  }

  _bodyWindAndPressure(WeatherResponse weatherResponse) {
    return Column(
      children: [
        _buildRowTitle(
            'Wind & Pressure',
            'More',
            weatherData != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily:
                                  weatherData.weatherForecastDaily,
                            )))
                : () {}),
        GestureDetector(
          onTap: weatherData != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            currentIndex: 0,
                            weatherForecastDaily:
                                weatherData.weatherForecastDaily,
                          )))
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
                                animation: _controller,
                                builder: (context, _child) {
                                  return Transform.rotate(
                                      angle: _controller.value * 2 * math.pi,
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
                                animation: _controller2,
                                builder: (context, _child) {
                                  return Transform.rotate(
                                      angle: _controller2.value * 2 * math.pi,
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
                            'Wind',
                            style: textSmallWhite70,
                          )
                        ],
                      ),
                      Text(
                        '${formatWind(weatherResponse.wind.speed, settingBloc.windEnum.value)} ${getWindDirection(weatherResponse.wind.deg)}',
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
                                'Pressure',
                                style: textSmallWhite70,
                              )
                            ],
                          ),
                          Text(
                            '${formatPressure(weatherResponse.mainWeatherData.pressure, settingBloc.pressureEnum.value)}',
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

  _buildSunTime(WeatherResponse weatherResponse, String timezone) {
    return weatherResponse != null
        ? _buildSunTimeBody(weatherResponse, timezone)
        : Container();
  }

  _buildSunTimeBody(WeatherResponse weatherResponse, String timezone) {
    return Column(
      children: [
        _buildRowTitle(
            'Sun & Moon',
            'More',
            weatherData != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily:
                                  weatherData.weatherForecastDaily,
                            )))
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
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailDailyForecast(
                                    currentIndex: 0,
                                    weatherForecastDaily:
                                        weatherData.weatherForecastDaily,
                                  )))
                      : () {},
                  child: SunPathWidget(
                    sunrise: weatherResponse.system.sunrise,
                    sunset: weatherResponse.system.sunset,
                    differentTime: _getDifferentTime(timezone),
                  )),
              Container(
                margin: EdgeInsets.symmetric(vertical: margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system.sunrise), settingBloc.timeEnum)}',
                      style: textSecondaryWhite70,
                    ),
                    Text(
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system.sunset), settingBloc.timeEnum)}',
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
        title = 'Temp Unit';
        groupValue = settingBloc.tempEnum.value;
        break;
      case SettingEnum.WindEnum:
        WindEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Wind speed Unit';
        groupValue = settingBloc.windEnum.value;
        break;
      case SettingEnum.PressureEnum:
        PressureEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Wind speed Unit';
        groupValue = settingBloc.pressureEnum.value;
        break;
      case SettingEnum.VisibilityEnum:
        VisibilityEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Visibility Unit';
        groupValue = settingBloc.visibilityEnum.value;
        break;
      case SettingEnum.TimeEnum:
        TimeEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Time Format';
        groupValue = settingBloc.timeEnum.value;
        break;
      case SettingEnum.DateEnum:
        DateEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Date Format';
        groupValue = settingBloc.dateEnum.value;
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
                                onChanged: (String value) {
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

  _changeSetting(String value, SettingEnum settingEnum) {
    print('_changeSetting');
    settingBloc.changeSetting(value, settingEnum);
    Navigator.pop(context);
  }

  Future<void> refresh() async {
    getData();
  }
}

class WeatherData {
  final WeatherResponse weatherResponse;
  final WeatherForecastListResponse weatherForecastListResponse;
  final WeatherForecastDaily weatherForecastDaily;
  final WeatherStateError error;

  WeatherData(
      {this.weatherResponse,
      this.weatherForecastListResponse,
      this.weatherForecastDaily,
      this.error});

  WeatherData copyWith(
      {WeatherResponse weatherResponse,
      WeatherForecastListResponse weatherForecastListResponse,
      WeatherForecastDaily weatherForecastDaily,
      WeatherStateError error}) {
    return WeatherData(
        weatherResponse: weatherResponse ?? this.weatherResponse,
        weatherForecastListResponse:
            weatherForecastListResponse ?? this.weatherForecastListResponse,
        weatherForecastDaily: weatherForecastDaily ?? this.weatherForecastDaily,
        error: error ?? this.error);
  }
}

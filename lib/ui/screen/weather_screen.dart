import 'dart:async';
import 'dart:core';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_forecast_bloc.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/current_daily_weather.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/model/timezone.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_holder.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/colors.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/add_city_screen.dart';
import 'package:weather_app/ui/screen/daily_forecast_screen.dart';
import 'package:weather_app/ui/screen/hourly_forecast_screen.dart';
import 'package:weather_app/ui/widgets/chart_widget.dart';
import 'package:weather_app/ui/widgets/smarr_refresher.dart';
import 'package:weather_app/ui/widgets/sun_path_widget.dart';
import 'package:weather_app/utils/utils.dart';

import 'detail_daily_forecast.dart';

const double _mainWeatherHeight = 220;
const double _mainWeatherWidth = 2000;
const double _chartHeight = 30;
const double _dailySectionHeight = 520;
const String _exclude7DayForecast = 'minutely,hourly';

const double bigIconSize = 16;
const double smallIconSize = bigIconSize;
const double iconWindPathSize = 50;
const double iconWindPillarHeight = 60;
const double iconWindPillarWidth = 50;
const double iconWindPathSmallSize = 30;
const double iconWindPillarSmallHeight = 40;
const double iconWindPillarSmallWidth = 30;
const double iconDrawerSize = 30;
const int defaultDisplayNumberLocation = 4;

class WeatherScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherScreen({Key key, this.lat, this.lon});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final WeatherBloc bloc = WeatherBloc();
  final WeatherForecastBloc weatherForecastBloc = WeatherForecastBloc();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  WeatherResponse weatherResponse;
  WeatherForecastListResponse weatherForecastListResponse;
  WeatherForecastDaily weatherForecastDaily;
  WeatherData weatherData;
  BehaviorSubject<DateTime> timeSubject =
      BehaviorSubject.seeded(DateTime.now());
  AnimationController _controller;
  AnimationController _controller2;
  int currentTime = 0;
  String timezone = '';
  int differentTime = 0;
  bool isOnNotification = false;
  int listLocationLength = 0;
  bool isShowMore = false;

  @override
  void initState() {
    super.initState();
    getData();
    _initAnim();
    _listenChangeSetting();
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
    timeSubject.add(DateTime.fromMillisecondsSinceEpoch(currentTime));
  }

  getData() {
    weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
    bloc.fetchWeather(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecastResponse(widget.lat, widget.lon);
  }

  _initAnim() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
  }

  _listenChangeSetting() {
    settingBloc.settingStream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
    timeSubject.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeatherData>(
      stream: Rx.combineLatest3(
          bloc.weatherStream,
          weatherForecastBloc.weatherForecastStream,
          weatherForecastBloc.weatherForecastDailyStream, (a, b, c) {
        if (a is WeatherStateSuccess &&
            b is WeatherForecastStateSuccess &&
            c is WeatherForecastDailyStateSuccess) {
          differentTime = _getDifferentTime(c.weatherResponse.timezone);

          return WeatherData(
              weatherResponse: WeatherResponse.formatWithTimezone(
                  a.weatherResponse, differentTime),
              weatherForecastListResponse: b.weatherResponse,
              weatherForecastDaily: WeatherForecastDaily.withTimezone(
                  c.weatherResponse, differentTime));
        }
        return null;
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          weatherData = snapshot.data;
          pageBloc.addCityName(weatherData.weatherResponse.name);
          _createTime(DateTime.fromMillisecondsSinceEpoch(
              weatherData.weatherForecastDaily.current.dt));
        }
        // keep old data when request fail
        return weatherData != null
            ? Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(getBgImagePath(weatherData
                                .weatherResponse.overallWeatherData[0].icon)),
                            fit: BoxFit.cover)),
                  ),
                  _body(weatherData)
                ],
              )
            : Scaffold(
                body: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
      },
    );
  }

  int _getDifferentTime(String timezone) {
    String value = '';
    for (Timezone time in cityBloc.timezones) {
      if (time.value.contains(getTimezone(timezone))) {
        value = getTimezone(time.name);
      }
    }
    return value == '' ? 0 : convertTimezoneToNumber(value);
  }

  String getTimezone(String timezone) =>
      timezone.substring(timezone.indexOf('/') + 1, timezone.length);

  _body(WeatherData weatherData) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            pinned: true,
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
        // _body(),
      ),
      drawer: _drawer(),
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
                mIconSettingTemp, 'Temp Unit', settingBloc.tempEnum.value, () {
              showSettingDialog(SettingEnum.TempEnum);
            }),
            _buildItemUnit(mIconWind, 'Wind Unit', 'km/h', () {}),
            _buildItemUnit(
                mIconSettingPressure, 'Pressure Unit', 'mBar', () {}),
            _buildItemUnit(
                mIconSettingVisibility, 'Visibility Unit', 'km', () {}),
            _buildItemUnit(
                mIconSettingTemp, 'Time Format', '12-hour clock', () {}),
            _buildItemUnit(
                mIconSettingTemp, 'Date Format', 'dd/mm/yyyy', () {}),
          ],
        ),
      );

  _listLocation() {
    return StreamBuilder<List<String>>(
        stream: pageBloc.citiesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: padding, right: paddingSmall, bottom: padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            mIconEditingLocation,
                            width: iconDrawerSize,
                            height: iconDrawerSize,
                          ),
                          const SizedBox(width: padding),
                          Text('Edit Location', style: textTitleWhite),
                        ],
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: isShowMore
                              ? defaultDisplayNumberLocation
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

  _itemLocation(String name, int index) {
    return InkWell(
      onTap: () => pageBloc.jumpToPage(index),
      child: Container(
        padding: EdgeInsets.only(top: padding),
        child: Row(
          children: [
            Image.asset(
              mIconSettingLocation,
              width: iconDrawerSize,
              height: iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text(name, style: textTitleWhite),
          ],
        ),
      ),
    );
  }

  _showMoreLocation(int locationLength) {
    if (locationLength >= defaultDisplayNumberLocation) {
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
                width: iconDrawerSize,
                height: iconDrawerSize,
              ),
              const SizedBox(width: padding),
              Text(
                isShowMore
                    ? 'Show more ${locationLength - defaultDisplayNumberLocation}'
                    : 'Collapse',
                style: textTitleWhite,
              ),
              Expanded(child: Container()),
              Icon(
                isShowMore
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.white,
                size: iconDrawerSize,
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
              width: iconDrawerSize,
              height: iconDrawerSize,
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
              width: iconDrawerSize,
              height: iconDrawerSize,
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
                return Text('${formatWeekDayAndTime(snapshot.data)}',
                    style: textSecondaryWhite70);
              }
              return Text('');
            }),
      ],
    );
  }

  _currentWeather(WeatherResponse weatherResponse) {
    return Container(
        height: _mainWeatherHeight,
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
          formatTemperature(temperature: temp, tempEnum: settingBloc.tempEnum),
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
          formatTemperature(temperature: temp, tempEnum: settingBloc.tempEnum),
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
          Text(
              formatTemperature(
                  temperature: maxTemp, tempEnum: settingBloc.tempEnum),
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
          Text(
              formatTemperature(
                  temperature: minTemp, tempEnum: settingBloc.tempEnum),
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
   List<WeatherForecastResponse> list = weatherForecastListResponse.list.map((e) {
      return e.copyWith(
          mainWeatherData: e.mainWeatherData.copyWith(
              temp: convertTemp(e.mainWeatherData.temp, settingBloc.tempEnum),
              feelsLike: convertTemp(
                  e.mainWeatherData.feelsLike, settingBloc.tempEnum),
              tempMax:
                  convertTemp(e.mainWeatherData.tempMax, settingBloc.tempEnum),
              tempMin: convertTemp(
                  e.mainWeatherData.tempMin, settingBloc.tempEnum)));
    }).toList();

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
                      list,
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
                          formatVisibility(
                              currentDailyWeather.visibility.toDouble())),
                    ),
                    _verticalDivider(),
                    Expanded(
                      flex: 1,
                      child: _buildItemDetail('Dew Point', mIconDewPoint,
                          '${daily.dewPoint.toStringAsFixed(0)}$degree'),
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
                width: bigIconSize,
                height: bigIconSize,
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
                                  width: iconWindPathSize,
                                  height: iconWindPathSize,
                                )),
                            Container(
                                margin:
                                    EdgeInsets.only(top: iconWindPathSize / 2),
                                child: Image.asset(
                                  mIconWindPillar,
                                  width: iconWindPillarWidth,
                                  height: iconWindPillarHeight,
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
                                  width: iconWindPathSmallSize,
                                  height: iconWindPathSmallSize,
                                )),
                            Container(
                                margin: EdgeInsets.only(
                                    top: iconWindPathSmallSize / 2),
                                child: Image.asset(
                                  mIconWindPillar,
                                  width: iconWindPillarSmallWidth,
                                  height: iconWindPillarSmallHeight,
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
                            width: bigIconSize,
                            height: bigIconSize,
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
                        '${formatWind(weatherResponse.wind.speed)} ${getWindDirection(weatherResponse.wind.deg)}',
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
                                width: bigIconSize,
                                height: bigIconSize,
                                color: Colors.white,
                              ),
                              Image.asset(
                                mIconDownArrow,
                                width: bigIconSize,
                                height: smallIconSize,
                                color: Colors.white,
                              ),
                              Text(
                                'Pressure',
                                style: textSmallWhite70,
                              )
                            ],
                          ),
                          Text(
                            '${formatPressure(weatherResponse.mainWeatherData.pressure)}',
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
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system.sunrise))}',
                      style: textTitleWhite,
                    ),
                    Text(
                      '${formatTime(DateTime.fromMillisecondsSinceEpoch(weatherResponse.system.sunset))}',
                      style: textTitleWhite,
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
    String title = '';
    switch (settingEnum) {
      case SettingEnum.TempEnum:
        TempEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'Temp Unit';
        break;
      case SettingEnum.WindEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.PressureEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.VisibilityEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.TimeEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.DateEnum:
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
                                groupValue: settingBloc.tempEnum.value,
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
    settingBloc.changeSetting(value, settingEnum);
    Navigator.pop(context);
  }

  Future<void> refresh() async {
    await bloc.fetchWeather(widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecastResponse(
        widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
    return;
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
}

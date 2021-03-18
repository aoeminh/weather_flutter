import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_forecast_bloc.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/current_daily_weather.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_holder.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
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
import 'dart:math' as math;

import 'detail_daily_forecast.dart';

const double _mainWeatherHeight = 220;
const double _mainWeatherWidth = 2000;
const double _chartHeight = 30;
const double _dailySectionHeight = 480;
const String _exclude7DayForecast = 'minutely,hourly';

const double bigIconSize = 16;
const double smallIconSize = bigIconSize;
const double iconWindPathSize = 50;
const double iconWindPillarHeight = 60;
const double iconWindPillarWidth = 50;
const double iconWindPathSmallSize = 30;
const double iconWindPillarSmallHeight = 40;
const double iconWindPillarSmallWidth = 30;

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
  BehaviorSubject<DateTime> timeSubject =
      BehaviorSubject.seeded(DateTime.now());
  AnimationController _controller;
  AnimationController _controller2;
  int currentTime;

  @override
  void initState() {
    super.initState();
    getData();
    _createTime();
    _initAnim();
  }

  _createTime() {
    bloc.weatherStream.listen((event) {
      if (event is WeatherStateSuccess) {
        WeatherResponse weatherResponse = event.weatherResponse;
        currentTime = weatherResponse.dt;
        setState(() {
          
        });
      }
    });

    Timer.periodic(
        Duration(seconds: 1),
        (t) => {
              if (!timeSubject.isClosed) {_addTime()}
            });
  }

  _addTime() {
    currentTime += 1000;
    timeSubject.add(DateTime.fromMillisecondsSinceEpoch(currentTime));
  }

  getData() {
    bloc.fetchWeather(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecastResponse(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
  }

  _initAnim() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
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
    return Stack(
      children: [
        StreamBuilder(
          stream: bloc.weatherStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              WeatherState state = snapshot.data;
              if (state is WeatherStateSuccess) {
                WeatherResponse data = state.weatherResponse;
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              getBgImagePath(data.overallWeatherData[0].icon)),
                          fit: BoxFit.cover)),
                );
              }
            }
            return weatherResponse != null
                ? Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(getBgImagePath(
                                weatherResponse.overallWeatherData[0].icon)),
                            fit: BoxFit.cover)),
                  )
                : Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
          },
        ),
        Scaffold(
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
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddCityScreen())),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ))
                ],
                title: Column(
                  children: [
                    const SizedBox(
                      height: marginSmall,
                    ),
                    StreamBuilder(
                        stream: bloc.weatherStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data is WeatherStateSuccess) {
                              WeatherStateSuccess weatherStateSuccess =
                                  snapshot.data;
                              weatherResponse =
                                  weatherStateSuccess.weatherResponse;
                              return Text('${weatherResponse.name}');
                            }
                            return weatherResponse != null
                                ? Text('${weatherResponse.name}')
                                : Container();
                          } else {
                            return Container();
                          }
                        }),
                    const SizedBox(
                      height: marginSmall,
                    ),
                    StreamBuilder<DateTime>(
                        stream: timeSubject.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                                '${formatWeekDayAndTime(snapshot.data)}',
                                style: textSecondaryWhite70);
                          }
                          return Text('');
                        }),
                  ],
                ),
              ),
            ],
            body: _body(),
            // _body(),
          ),
        )
      ],
    );
  }

  _titleAppbar() {
    return StreamBuilder(
        stream: bloc.weatherStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is WeatherStateSuccess) {
              WeatherStateSuccess weatherStateSuccess = snapshot.data;
              weatherResponse = weatherStateSuccess.weatherResponse;
              return Text('${weatherResponse.name}');
            }
            if (weatherResponse != null) {
              return Column(
                children: [
                  const SizedBox(
                    height: marginSmall,
                  ),
                  Text('${weatherResponse.name}'),
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
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }

  _body() {
    return SmartRefresher(
      refreshIndicatorKey: _refreshIndicatorKey,
      children: Container(
        child: Column(
          children: [
            _currentWeather(),
            _buildHourlyForecast(),
            _buildDailyForecast(),
            _buildDetail(),
            _buildWindAndPressure(),
            _buildSunTime()
          ],
        ),
      ),
      onRefresh: refresh,
    );
  }

  _currentWeather() {
    return Container(
      height: _mainWeatherHeight,
      child: StreamBuilder<WeatherState>(
          stream: bloc.weatherStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is WeatherStateSuccess) {
                WeatherStateSuccess weatherStateSuccess = snapshot.data;
                weatherResponse = weatherStateSuccess.weatherResponse;
                return _buildBodyCurrentWeather(weatherResponse);
              }

              if (snapshot.data is WeatherStateError) {
                WeatherStateError weatherStateError = snapshot.data;
                return Center(
                    child: Text('${weatherStateError.error.toString()}'));
              }

              return weatherResponse != null
                  ? _buildBodyCurrentWeather(weatherResponse)
                  : Container();
            } else {
              return weatherResponse != null
                  ? _buildBodyCurrentWeather(weatherResponse)
                  : Container();
            }
          }),
    );
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
        SizedBox(
          height: marginLarge,
        ),
        _buildTempRow(weatherResponse.mainWeatherData.temp.toInt()),
        _buildFeelsLike(weatherResponse.mainWeatherData.feelsLike,
            weatherResponse.mainWeatherData.humidity),
        SizedBox(height: margin),
        _buildMaxMinTemp(weatherResponse.mainWeatherData.tempMax.toInt(),
            weatherResponse.mainWeatherData.tempMin.toInt())
      ],
    );
  }

  _buildTempRow(int temp) {
    print('_buildTempRow $temp');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$temp',
          style: textMainTemp,
        ),
        Text(
          '°C',
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
          '${temp.toInt()}°',
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

  _buildMaxMinTemp(int maxTemp, int minTemp) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            mIconHigh,
            height: 20,
          ),
          SizedBox(
            width: marginSmall,
          ),
          Text('$maxTemp°', style: textTitleH1White),
          SizedBox(
            width: marginLarge,
          ),
          Image.asset(
            mIconLow,
            height: 20,
          ),
          SizedBox(
            width: marginSmall,
          ),
          Text('$minTemp°', style: textTitleH1White),
        ],
      );

  _buildHourlyForecast() {
    return StreamBuilder<WeatherState>(
        stream: weatherForecastBloc.weatherForecastStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is WeatherForecastStateSuccess) {
              WeatherForecastStateSuccess weatherForecastStateSuccess =
                  snapshot.data;
              weatherForecastListResponse =
                  weatherForecastStateSuccess.weatherResponse;
              return _buildBodyHourlyForecast(weatherForecastListResponse);
            }
          }
          return weatherForecastListResponse != null
              ? _buildBodyHourlyForecast(weatherForecastListResponse)
              : Container(
                  height: _mainWeatherHeight,
                );
        });
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

  _buildDailyForecast() {
    return StreamBuilder<WeatherState>(
        stream: weatherForecastBloc.weatherForecastDailyStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WeatherState weatherState = snapshot.data;
            if (weatherState is WeatherForecastDailyStateSuccess) {
              weatherForecastDaily = weatherState.weatherResponse;
              return _buildBodyDailyForecast(weatherForecastDaily);
            }
          }
          return weatherForecastDaily != null
              ? _buildBodyDailyForecast(weatherForecastDaily)
              : Container();
        });
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
                          '${data.daily[index].temp.min.toInt()}$degree - ${data.daily[index].temp.max.toInt()}$degree',
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

  _buildDetail() {
    return StreamBuilder<WeatherState>(
        stream: weatherForecastBloc.weatherForecastDailyStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WeatherState state = snapshot.data;
            if (state is WeatherForecastDailyStateSuccess) {
              weatherForecastDaily = state.weatherResponse;
              return _buildBodyDetail(
                  weatherForecastDaily.daily[0], weatherForecastDaily.current);
            }
          }
          return weatherForecastDaily != null
              ? _buildBodyDetail(
                  weatherForecastDaily.daily[0], weatherForecastDaily.current)
              : Container();
        });
  }

  _buildBodyDetail(Daily daily, CurrentDailyWeather currentDailyWeather) {
    return Column(
      children: [
        _buildRowTitle(
            'Detail',
            'More',
            weatherForecastDaily != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily: weatherForecastDaily,
                            )))
                : () {}),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailDailyForecast(
                        currentIndex: 0,
                        weatherForecastDaily: weatherForecastDaily,
                      ))),
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

  _buildWindAndPressure() {
    return StreamBuilder<WeatherState>(
        stream: bloc.weatherStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WeatherState weatherState = snapshot.data;
            if (weatherState is WeatherStateSuccess) {
              WeatherResponse weatherResponse = weatherState.weatherResponse;
              return _bodyWindAndPressure(weatherResponse);
            }
          }
          return weatherResponse != null
              ? _bodyWindAndPressure(weatherResponse)
              : Container();
        });
  }

  _bodyWindAndPressure(WeatherResponse weatherResponse) {
    return Column(
      children: [
        _buildRowTitle(
            'Wind & Pressure',
            'More',
            weatherForecastDaily != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily: weatherForecastDaily,
                            )))
                : () {}),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailDailyForecast(
                        currentIndex: 0,
                        weatherForecastDaily: weatherForecastDaily,
                      ))),
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

  _buildSunTime() {
    return Column(
      children: [
        _buildRowTitle(
            'Sun & Moon',
            'More',
            weatherForecastDaily != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDailyForecast(
                              currentIndex: 0,
                              weatherForecastDaily: weatherForecastDaily,
                            )))
                : () {}),
        StreamBuilder<WeatherState>(
            stream: bloc.weatherStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                WeatherState weatherState = snapshot.data;
                if (weatherState is WeatherStateSuccess) {
                  WeatherResponse weatherResponse =
                      weatherState.weatherResponse;

                  return _buildSunTimeBody(weatherResponse);
                }
              }
              return weatherResponse != null
                  ? _buildSunTimeBody(weatherResponse)
                  : Container();
            }),
      ],
    );
  }

  _buildSunTimeBody(WeatherResponse weatherResponse) {
    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.symmetric(vertical: margin, horizontal: padding),
      decoration: BoxDecoration(
          color: transparentBg,
          borderRadius: BorderRadius.circular(radiusSmall),
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Column(
        children: [
          GestureDetector(
              onTap: weatherForecastDaily != null
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailDailyForecast(
                                currentIndex: 0,
                                weatherForecastDaily: weatherForecastDaily,
                              )))
                  : () {},
              child: SunPathWidget(
                sunrise: weatherResponse.system.sunrise,
                sunset: weatherResponse.system.sunset,
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
    );
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

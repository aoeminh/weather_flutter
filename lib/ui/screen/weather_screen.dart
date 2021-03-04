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
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_holder.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/colors.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/daily_forecast_screen.dart';
import 'package:weather_app/ui/screen/hourly_forecast_screen.dart';
import 'package:weather_app/ui/widgets/chart_widget.dart';
import 'package:weather_app/ui/widgets/smarr_refresher.dart';
import 'package:weather_app/utils/utils.dart';

import 'detail_daily_forecast.dart';

const double _mainWeatherHeight = 200;
const double _mainWeatherWidth = 2000;
const double _chartHeight = 30;
const double _dailySectionHeight = 480;
const String _exclude7DayForecast = 'current,minutely,hourly';

class WeatherScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherScreen({Key key, this.lat, this.lon});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherBloc bloc = WeatherBloc();
  final WeatherForecastBloc weatherForecastBloc = WeatherForecastBloc();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  WeatherResponse weatherResponse;
  WeatherForecastListResponse weatherForecastListResponse;
  BehaviorSubject<DateTime> timeSubject =
      BehaviorSubject.seeded(DateTime.now());

  @override
  void initState() {
    super.initState();
    bloc.fetchWeather(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecastResponse(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
    Timer.periodic(
        Duration(seconds: 1), (t) => {timeSubject.add(DateTime.now())});
  }

  @override
  void dispose() {
    super.dispose();
    timeSubject.close();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(mBgCloudy), fit: BoxFit.cover)),
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
                title: Column(
                  children: [
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
                    StreamBuilder<DateTime>(
                        stream: timeSubject.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                                '${formatWeekDayAndTime(snapshot.data)}',
                                style: textSecondaryGrey);
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

  _body() {
    return SmartRefresher(
      refreshIndicatorKey: _refreshIndicatorKey,
      children: Container(
        child: Column(
          children: [
            _currentWeather(),
            _buildHourlyForecast(),
            _buildDailyForecast()
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
        Container(
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
              margin: EdgeInsets.only(left: marginXLarge, right: marginXLarge),
              child: Center(
                child: ChartWidget(
                  chartData: WeatherForecastHolder(
                    weatherForecastListResponse.list,
                    weatherForecastListResponse.city,
                  ).setupChartData(ChartDataType.temperature, _mainWeatherWidth,
                      _chartHeight),
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
              WeatherForecastDaily data = weatherState.weatherResponse;
              return Column(
                children: [
                  _buildRowTitle(
                      'Daily Forecast',
                      'More',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyForecastScreen(
                                    weatherForecastDaily: data,
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
                              "${data.daily[0].weather[0].description}",
                              style: textTitleH1White,
                            )),
                        Divider(
                          height: 1,
                          color: Colors.white,
                        ),
                        Expanded(child: _buildDailyRow(data))
                      ],
                    ),
                  ),
                ],
              );
            }
          }

          return Container();
        });
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
                          style: textSecondaryGrey,
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
                          style: textTitleGrey,
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

  Future<void> refresh() async {
    await bloc.fetchWeather(widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecastResponse(
        widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
    return;
  }
}

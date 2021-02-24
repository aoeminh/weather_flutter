import 'dart:core';

import 'package:flutter/material.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_forecast_bloc.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/weather_forecast_holder.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/hourly_forecast_screen.dart';
import 'package:weather_app/ui/widgets/chart_widget.dart';
import 'package:weather_app/ui/widgets/smarr_refresher.dart';

const double _mainWeatherHeight = 200;
const String _exclude7DayForecast = 'current,minutely,hourly';

class WeatherScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherScreen({Key key, this.lat, this.lon}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherBloc bloc = WeatherBloc();
  final WeatherForecastBloc weatherForecastBloc = WeatherForecastBloc();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  WeatherResponse weatherResponse;

  @override
  void initState() {
    super.initState();
    bloc.fetchWeather(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecastResponse(widget.lat, widget.lon);
    weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'Hanoi',
                  style: textTitleH2WhiteBold,
                ),
                Text('13:14', style: textSecondaryGrey),
              ],
            ),
            leading: Icon(Icons.menu, color: Colors.white),
            actions: [
              Icon(
                Icons.add,
                color: Colors.white,
              )
            ],
          ),
          body: _body(),
        )
      ],
    );
  }

  _body() {
    return Container(
      child: SingleChildScrollView(
        child: SmartRefresher(
          refreshIndicatorKey: _refreshIndicatorKey,
          children: [
            Container(
              child: Column(
                children: [_currentWeather(), _buildHourlyForecast()],
              ),
            )
          ],
          onRefresh: refresh,
        ),
      ),
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
                    _buildMaxMinTemp(
                        weatherResponse.mainWeatherData.tempMax.toInt(),
                        weatherResponse.mainWeatherData.tempMin.toInt())
                  ],
                );
              }

              if (snapshot.data is WeatherStateError) {
                WeatherStateError weatherStateError = snapshot.data;
                return Center(
                    child: Text('${weatherStateError.error.toString()}'));
              }

              return Container();
            } else {
              return Container();
            }
          }),
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
    print('_buildFeelsLike $temp');
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
              WeatherForecastListResponse weatherForecastListResponse =
                  weatherForecastStateSuccess.weatherResponse;
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
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        height: 200,
                        width: 2000,
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: ChartWidget(
                            chartData: WeatherForecastHolder(
                              weatherForecastListResponse.list,
                              weatherForecastListResponse.city,
                            ).setupChartData(
                                ChartDataType.temperature, 2000, 60),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
          return Container(
            height: 200,
          );
        });
  }

  _buildRowTitle(String title1, String title2, VoidCallback voidCallback) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
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

  _buildDetail() {}

  Future<void> refresh() async {
    await bloc.fetchWeather(widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecastResponse(
        widget.lat, widget.lon);
    await weatherForecastBloc.fetchWeatherForecast7Day(
        widget.lat, widget.lon, _exclude7DayForecast);
    return;
  }
}

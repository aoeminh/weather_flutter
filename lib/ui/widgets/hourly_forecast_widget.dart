import 'package:flutter/material.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/model/chart_data.dart';
import 'package:weather_app/model/weather_forecast_holder.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/shared/colors.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/ui/screen/hourly_forecast_screen.dart';

import 'chart_widget.dart';

const double _mainWeatherHeight = 240;
const double _mainWeatherWidth = 2000;
const double _chartHeight = 30;
class HourlyForecastWidget extends StatelessWidget {
  final WeatherForecastListResponse? weatherForecastListResponse;

  const HourlyForecastWidget({Key? key, this.weatherForecastListResponse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appBloc.showInterstitialAd();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HourlyForecastScreen(
                      weatherForecastListResponse: weatherForecastListResponse,
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
            margin: EdgeInsets.only(left: marginXLarge, right: marginXLarge),
            child: Center(
              child: ChartWidget(
                chartData: WeatherForecastHolder(
                  weatherForecastListResponse!.list!,
                ).setupChartData(
                    ChartDataType.temperature, _mainWeatherWidth, _chartHeight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

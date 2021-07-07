import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/weather_response.dart';
import '../../shared/dimens.dart';
import '../../shared/image.dart';
import '../../shared/text_style.dart';
import '../../utils/utils.dart';

const double _mainWeatherHeight = 240;

class CurrentWeatherWidget extends StatelessWidget {
  final WeatherResponse? weatherResponse;
  final String? unitValue;
  const CurrentWeatherWidget({Key? key, this.weatherResponse,this.unitValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _currentWeather(weatherResponse);
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
          unitValue!,
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
}

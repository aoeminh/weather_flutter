import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/shared/colors.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/detail_daily_forecast.dart';
import 'package:weather_app/ui/screen/weather_screen.dart';
import 'package:weather_app/utils/utils.dart';

const double _bigIconSize = 16;

class DetailWeatherWidget extends StatelessWidget {
  final WeatherData? weatherData;
  final Daily? daily;

  const DetailWeatherWidget({Key? key, this.weatherData, this.daily})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: weatherData != null
          ? () {
              appBloc.showInterstitialAd();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            currentIndex: 0,
                            weatherForecastDaily:
                                weatherData!.weatherForecastDaily,
                          )));
            }
          : () {},
      child: Container(
        margin: EdgeInsets.all(margin),
        padding:
            EdgeInsets.symmetric(vertical: paddingLarge, horizontal: padding),
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
                  child: _buildItemDetail('precipitation'.tr, mIcPrecipitation,
                      formatHumidity(daily!.pop!)),
                ),
                _verticalDivider(),
                Expanded(
                  flex: 1,
                  child: _buildItemDetail('humidity'.tr, mIconHumidity,
                      formatHumidity(daily!.humidity!.toDouble())),
                ),
                _verticalDivider(),
                Expanded(
                    flex: 1,
                    child: _buildItemDetail(
                      'uv_index'.tr,
                      mIconUVIndex,
                      daily!.uvi!.toStringAsFixed(0),
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
                      formatVisibility(
                          weatherData!
                              .weatherForecastDaily!.current!.visibility!,
                          settingBloc.visibilityEnum.value)),
                ),
                _verticalDivider(),
                Expanded(
                  flex: 1,
                  child: _buildItemDetail('dew_point'.tr, mIconDewPoint,
                      formatTemperature(temperature: daily!.dewPoint)),
                ),
                _verticalDivider(),
                Expanded(
                    flex: 1,
                    child: _buildItemDetail(
                      'cloud_cover'.tr,
                      mIconCloudCover,
                      formatHumidity(daily!.clouds!.toDouble()),
                    ))
              ],
            ),
          ],
        ),
      ),
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
}

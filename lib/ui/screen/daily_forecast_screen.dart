import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/utils/utils.dart';

import 'detail_daily_forecast.dart';

const Color primaryColor = Colors.white;
const Color secondaryColor = Colors.white54;
const double iconWeatherSize = 30;
const double iconDetailSize = 20;

class DailyForecastScreen extends StatelessWidget {
  final WeatherForecastDaily weatherForecastDaily;

  const DailyForecastScreen({Key key, this.weatherForecastDaily})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: secondaryColor,
            )),
        title: Text(
          'Daily Forecast',
          style: textTitleH2WhiteBold,
        ),
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      color: Colors.black87,
      child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDailyForecast(weatherForecastDaily: weatherForecastDaily,currentIndex: index,))),
              child: _buildItemDailyForecast(weatherForecastDaily.daily[index]),
            );
          },
          separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey,
              ),
          itemCount: weatherForecastDaily.daily.length),
    );
  }

  _buildItemDailyForecast(Daily daily) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          _dateRow(DateTime.fromMillisecondsSinceEpoch(daily.dt)),
          _detailDay(daily),
          Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(left: marginLarge),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              )),
          _detailNight(daily)
        ],
      ),
    );
  }

  _dateRow(DateTime dateTime) {
    return Row(
      children: [
        Text(
          '${formatDate(dateTime)}',
          style: textSecondaryWhiteBold,
        ),
        const SizedBox(
          width: marginSmall,
        ),
        Text(
          '${formatWeekday(dateTime)}',
          style: textSecondaryGrey,
        ),
      ],
    );
  }

  _detailDay(Daily daily) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              'Day',
              style: textSmallWhite70,
            )),
        Expanded(
            flex: 1,
            child: Image.asset(
              getIconForecastUrl(daily.weather[0].icon),
              width: iconWeatherSize,
              height: iconWeatherSize,
            )),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${daily.weather[0].main}',
                style: textSecondaryWhite,
              ),
              Row(
                children: [
                  Image.asset(
                    mIconSunrise,
                    width: iconDetailSize,
                    height: iconDetailSize,
                  ),
                  Text(
                    'Sunrise:',
                    style: textSmallWhite70,
                  ),
                  Text(
                    '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunrise))}',
                    style: textSmallWhite,
                  )
                ],
              )
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              children: [
                Image.asset(
                  mIconHigh,
                  width: iconDetailSize,
                  height: iconDetailSize,
                ),
                Text(
                  '${daily.temp.max.toInt()}$degree',
                  style: textTitleWhite,
                )
              ],
            ))
      ],
    );
  }

  _detailNight(Daily daily) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              'Night',
              style: textSmallWhite70,
            )),
        Expanded(
            flex: 1,
            child: Image.asset(
              getIconForecastUrl(daily.weather[0].icon),
              width: iconWeatherSize,
              height: iconWeatherSize,
            )),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${daily.weather[0].description}',
                style: textSecondaryWhite,
              ),
              Row(
                children: [
                  Image.asset(
                    mIconSunset,
                    width: iconDetailSize,
                    height: iconDetailSize,
                  ),
                  Text(
                    'Sunset:',
                    style: textSmallWhite70,
                  ),
                  Text(
                    '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunset))}',
                    style: textSmallWhite,
                  )
                ],
              )
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              children: [
                Image.asset(
                  mIconLow,
                  width: iconDetailSize,
                  height: iconDetailSize,
                ),
                Text(
                  '${daily.temp.min.toInt()}$degree',
                  style: textTitleWhite70,
                )
              ],
            ))
      ],
    );
  }
}

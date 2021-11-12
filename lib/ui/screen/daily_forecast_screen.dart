import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../bloc/setting_bloc.dart';
import '../../model/daily.dart';
import '../../model/weather_forcast_daily.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../shared/image.dart';
import '../../shared/strings.dart';
import '../../shared/text_style.dart';
import '../../utils/utils.dart';
import 'detail_daily_forecast.dart';

const Color primaryColor = Colors.white;
const Color secondaryColor = Colors.white54;
const double iconWeatherSize = 30;
const double iconDetailSize = 20;

class DailyForecastScreen extends StatefulWidget {
  final WeatherForecastDaily? weatherForecastDaily;

  const DailyForecastScreen({Key? key, this.weatherForecastDaily})
      : super(key: key);

  @override
  _DailyForecastScreenState createState() => _DailyForecastScreenState();
}

class _DailyForecastScreenState extends State<DailyForecastScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          'daily_forecast'.tr,
          style: textTitleH2WhiteBold,
        ),
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      color: backgroundColor,
      child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            weatherForecastDaily: widget.weatherForecastDaily,
                            currentIndex: index,
                          ))),
              child: _buildItemDailyForecast(
                  widget.weatherForecastDaily!.daily![index]),
            );
          },
          separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey,
              ),
          itemCount: widget.weatherForecastDaily!.daily!.length),
    );
  }

  _buildItemDailyForecast(Daily daily) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          _dateRow(DateTime.fromMillisecondsSinceEpoch(daily.dt!)),
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${formatDateAndMonth(dateTime, settingBloc.dateEnum)}',
          style: textSecondaryWhiteBold,
        ),
        const SizedBox(
          width: marginSmall,
        ),
        Text(
          '${formatWeekday(dateTime)}',
          style: textSmallWhite70,
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
              'day'.tr,
              style: textSmallWhite70,
            )),
        Expanded(
            flex: 1,
            child: Image.asset(
              getIconForecastUrl(daily.weather![0].icon),
              width: iconWeatherSize,
              height: iconWeatherSize,
            )),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${daily.weather![0].main}',
                style: textSecondaryWhite,
              ),
              Row(
                children: [
                  Image.asset(
                    mIconSunrise,
                    width: iconDetailSize,
                    height: iconDetailSize,
                  ),
                  const SizedBox(
                    width: marginSmall,
                  ),
                  Text(
                    'sunrise'.tr,
                    style: textSmallWhite70,
                  ),
                  Text(
                    '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunrise!), settingBloc.timeEnum)}',
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
                  '${daily.temp!.max!.toInt()}$degree',
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
              'night'.tr,
              style: textSmallWhite70,
            )),
        Expanded(
            flex: 1,
            child: Image.asset(
              getIconForecastUrl(daily.weather![0].icon),
              width: iconWeatherSize,
              height: iconWeatherSize,
            )),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${daily.weather![0].description}',
                style: textSecondaryWhite,
              ),
              Row(
                children: [
                  Image.asset(
                    mIconSunset,
                    width: iconDetailSize,
                    height: iconDetailSize,
                  ),
                  const SizedBox(
                    width: marginSmall,
                  ),
                  Text(
                    'sunset'.tr,
                    style: textSmallWhite70,
                  ),
                  Text(
                    '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunset!), settingBloc.timeEnum)}',
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
                  '${daily.temp!.min!.toInt()}$degree',
                  style: textTitleWhite70,
                )
              ],
            ))
      ],
    );
  }
}

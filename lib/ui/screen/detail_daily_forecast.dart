import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/model/weather_forcast_daily.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/utils/utils.dart';
import 'package:weather_app/shared/colors.dart';

const double _iconStatusSize = 50;
const double _iconLowHighSize = 20;
const double _iconRowSize = 14;

class DetailDailyForecast extends StatefulWidget {
  final WeatherForecastDaily? weatherForecastDaily;
  final int? currentIndex;

  const DetailDailyForecast(
      {Key? key, this.weatherForecastDaily, this.currentIndex})
      : super(key: key);

  @override
  _DetailDailyForecastState createState() => _DetailDailyForecastState();
}

class _DetailDailyForecastState extends State<DetailDailyForecast>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.currentIndex!,
      length: widget.weatherForecastDaily!.daily!.length,
      child: Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back)),
            title: Text('daily_detail'.tr, style: textTitleH2WhiteBold),
            bottom: TabBar(
                indicatorColor: Colors.white,
                labelPadding: EdgeInsets.all(margin),
                indicator: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white70),
                  borderRadius: BorderRadius.circular(radiusSmall),
                  color: transparentBg,
                ),
                isScrollable: true,
                unselectedLabelColor: Colors.white.withOpacity(0.3),
                tabs: [
                  ...widget.weatherForecastDaily!.daily!
                      .asMap()
                      .map((i, daily) {
                        return MapEntry(
                          i,
                          Container(
                            child: Column(children: [
                              Text(
                                '${formatWeekday(DateTime.fromMillisecondsSinceEpoch(daily.dt!))}',
                                style: textTitleWhite70,
                              ),
                              Text(
                                '${formatDateAndMonth(DateTime.fromMillisecondsSinceEpoch(daily.dt!), settingBloc.dateEnum)}',
                                style: textTitleWhite70,
                              ),
                            ]),
                          ),
                        );
                      })
                      .values
                      .toList()
                ]),
          ),
          body: TabBarView(
            children: <Widget>[
              ...widget.weatherForecastDaily!.daily!
                  .map((daily) => _buildBodyTabView(daily))
            ],
          )),
    );
  }

  _buildBodyTabView(Daily daily) => SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white70),
            borderRadius: BorderRadius.circular(radiusSmall),
            color: transparentBg,
          ),
          margin: EdgeInsets.all(margin),
          child: Column(
            children: [
              _buildDetail(daily, isDay: true),
              _divider(),
              _buildDetail(daily, isDay: false),
              _divider(),
              _buildSunAndMoon(daily)
            ],
          ),
        ),
      );

  _buildDetail(Daily daily, {required bool isDay}) {
    String session;
    String temp;
    Image icon;
    String? status;
    String feelslike;
    if (isDay) {
      session = 'day'.tr;
      temp = '${daily.temp!.day!.toInt()}$degree';
      icon = Image.asset(
        mIconHigh,
        width: _iconLowHighSize,
        height: _iconLowHighSize,
      );
      status = daily.weather![0].main;
      feelslike = '${daily.temp!.max!.toInt()}$degree';
    } else {
      session = 'night'.tr;
      temp = '${daily.temp!.night!.toInt()}$degree';
      icon = Image.asset(
        mIconLow,
        width: _iconLowHighSize,
        height: _iconLowHighSize,
      );
      status = daily.weather![0].description;
      feelslike = '${daily.temp!.min!.toInt()}$degree';
    }

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '$session',
              style: textTitleH2White,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                getIconForecastUrl(daily.weather![0].icon),
                width: _iconStatusSize,
                height: _iconStatusSize,
              ),
              const SizedBox(
                width: margin,
              ),
              Text(
                temp,
                style: textBigTemp,
              ),
              icon
            ],
          ),
          SizedBox(
            height: margin,
          ),
          Text(
            status!,
            style: textTitleH2White,
          ),
          _buildRowDetail(mIconSettingTemp,
              '${'feels_like'.tr} (${isDay ? 'max'.tr : 'min'.tr})', feelslike),
          _divider(),
          _buildRowDetail(mIconWind, 'wind'.tr,
              "${formatWind(daily.windSpeed!, settingBloc.windEnum.value)}"),
          _divider(),
          isDay
              ? _buildRowDetail(
                  mIconUVIndex, 'uv_index'.tr, "${daily.uvi!.toInt()}")
              : Container(),
          isDay ? _divider() : Container(),
          _buildRowDetail(mIcPrecipitation, 'precipitation'.tr,
              "${formatHumidity(daily.pop!)}"),
          _divider(),
          _buildRowDetail(mIconCloudCover, 'cloud_cover'.tr,
              "${formatHumidity(daily.clouds!.toDouble())}"),
        ],
      ),
    );
  }

  _divider() => Divider(
        height: 1,
        color: Colors.white70,
      );

  _buildRowDetail(String image, String title, String content) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: margin),
            child: Row(
              children: [
                Image.asset(
                  image,
                  width: _iconRowSize,
                  height: _iconRowSize,
                ),
                Text(
                  '$title',
                  style: textSmallWhite70,
                )
              ],
            ),
          ),
          Text(
            '$content',
            style: textTitleWhite,
          )
        ],
      );

  _buildSunAndMoon(Daily daily) {
    return Container(
      decoration: BoxDecoration(),
      margin: EdgeInsets.all(margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'sun'.tr} & ${'moon'.tr}',
            style: textTitleH2White,
          ),
          _sunDetail(daily)
        ],
      ),
    );
  }

  _sunDetail(Daily daily) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: margin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  mIconSun,
                  width: _iconStatusSize,
                  height: _iconStatusSize,
                ),
                Text(
                  '${getRiseAndSetTime(DateTime.fromMillisecondsSinceEpoch(daily.sunrise!), DateTime.fromMillisecondsSinceEpoch(daily.sunset!))}',
                  style: textTitleWhite,
                )
              ],
            ),
          ),
          _divider(),
          Container(
            margin: EdgeInsets.symmetric(vertical: margin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'rise'.tr,
                  style: textSmallWhite70,
                ),
                Text(
                  '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunrise!), settingBloc.timeEnum)}',
                  style: textTitleWhite,
                )
              ],
            ),
          ),
          _divider(),
          Container(
            margin: EdgeInsets.symmetric(vertical: margin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'set'.tr,
                  style: textSmallWhite70,
                ),
                Text(
                  '${formatTime(DateTime.fromMillisecondsSinceEpoch(daily.sunset!), settingBloc.timeEnum)}',
                  style: textTitleWhite,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

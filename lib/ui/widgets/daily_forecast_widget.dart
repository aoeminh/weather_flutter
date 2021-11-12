import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import '../../bloc/app_bloc.dart';
import '../../model/weather_forcast_daily.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../shared/strings.dart';
import '../../shared/text_style.dart';
import '../screen/detail_daily_forecast.dart';
import '../../utils/utils.dart';

const double _dailySectionHeight = 520;
const double _oneHour = 3600000;

class DailyForecastWidget extends StatefulWidget {
  final WeatherForecastDaily? weatherForecastDaily;
  final double? differentTime;

  const DailyForecastWidget(
      {Key? key, this.weatherForecastDaily, this.differentTime})
      : super(key: key);

  @override
  _DailyForecastWidgetState createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  // BehaviorSubject<int> behaviorSubject = BehaviorSubject.seeded(0);
  // int index = 0;
  // Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // timer!.cancel();
    // behaviorSubject.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                "${widget.weatherForecastDaily!.daily![0].weather![0].description}",
                style: textTitleH1White,
              )),
          Divider(
            height: 1,
            color: Colors.white,
          ),
          Expanded(child: _buildDailyRow(widget.weatherForecastDaily!))
        ],
      ),
    );
  }

  _buildDailyRow(WeatherForecastDaily data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: data.daily!.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          DateFormat dayFormat =
              DateFormat("MM/dd", Get.deviceLocale!.languageCode);
          DateFormat weekDayFormat =
              DateFormat("E", Get.deviceLocale!.languageCode);
          String day = dayFormat.format(
              DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!));
          String weekday = DateTime.fromMillisecondsSinceEpoch(
                          (DateTime.now().millisecondsSinceEpoch +
                                  widget.differentTime! * _oneHour)
                              .toInt())
                      .day ==
                  DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!)
                      .day
              ? 'today'.tr
              : weekDayFormat.format(
                  DateTime.fromMillisecondsSinceEpoch(data.daily![index].dt!));
          return GestureDetector(
            onTap: () {
              appBloc.showInterstitialAd();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            weatherForecastDaily: data,
                            currentIndex: index,
                          )));
            },
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
                          data.daily![index].weather![0].icon,
                          width: 30,
                          height: 30)),
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(left: margin),
                        child: Text(
                          '${data.daily![index].weather![0].description}',
                          style: textTitleWhite70,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(left: marginLarge),
                        child: Text(
                          '${data.daily![index].temp!.min!.toInt()}$degree - '
                          '${data.daily![index].temp!.max!.toInt()}$degree',
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

  // startAnim() {
  //   timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
  //     if (index < 29) {
  //       index += 1;
  //     } else {
  //       index = 0;
  //     }
  //     behaviorSubject.add(index);
  //   });
  // }
}

import 'package:flutter/material.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/colors.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/detail_daily_forecast.dart';
import 'package:weather_app/ui/screen/weather_screen.dart';
import 'package:weather_app/utils/utils.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

const double _bigIconSize = 16;
const double _iconWindPathSize = 50;
const double _iconWindPillarHeight = 60;
const double _iconWindPillarWidth = 50;
const double _iconWindPathSmallSize = 30;
const double _iconWindPillarSmallHeight = 40;
const double _iconWindPillarSmallWidth = 30;
const double _smallIconSize = _bigIconSize;

class PressureAndWind extends StatefulWidget {
  final WeatherResponse? weatherResponse;
  final WeatherData? weatherData;

  const PressureAndWind({Key? key, this.weatherResponse, this.weatherData})
      : super(key: key);

  @override
  _PressureAndWindState createState() => _PressureAndWindState();
}

class _PressureAndWindState extends State<PressureAndWind>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  AnimationController? _controller2;

  @override
  void initState() {
    super.initState();
    _initAnim();
  }
@override
  void dispose() {
  _controller?.dispose();
  _controller2?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.weatherData != null
          ? () {
              appBloc.showInterstitialAd();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDailyForecast(
                            currentIndex: 0,
                            weatherForecastDaily:
                                widget.weatherData!.weatherForecastDaily,
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
                            animation: _controller!,
                            builder: (context, _child) {
                              return Transform.rotate(
                                  angle: _controller!.value * 2 * math.pi,
                                  child: _child);
                            },
                            child: Image.asset(
                              mIconWindPath1,
                              width: _iconWindPathSize,
                              height: _iconWindPathSize,
                            )),
                        Container(
                            margin: EdgeInsets.only(top: _iconWindPathSize / 2),
                            child: Image.asset(
                              mIconWindPillar,
                              width: _iconWindPillarWidth,
                              height: _iconWindPillarHeight,
                            ))
                      ],
                    ),
                    Stack(
                      children: [
                        AnimatedBuilder(
                            animation: _controller2!,
                            builder: (context, _child) {
                              return Transform.rotate(
                                  angle: _controller2!.value * 2 * math.pi,
                                  child: _child);
                            },
                            child: Image.asset(
                              mIconWindPath1,
                              width: _iconWindPathSmallSize,
                              height: _iconWindPathSmallSize,
                            )),
                        Container(
                            margin: EdgeInsets.only(
                                top: _iconWindPathSmallSize / 2),
                            child: Image.asset(
                              mIconWindPillar,
                              width: _iconWindPillarSmallWidth,
                              height: _iconWindPillarSmallHeight,
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
                        width: _bigIconSize,
                        height: _bigIconSize,
                      ),
                      const SizedBox(
                        width: marginSmall,
                      ),
                      Text(
                        'wind'.tr,
                        style: textSmallWhite70,
                      )
                    ],
                  ),
                  Text(
                    '${formatWind(widget.weatherResponse!.wind!.speed, settingBloc.windEnum.value)} ${getWindDirection(widget.weatherResponse!.wind!.deg)}',
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
                            width: _bigIconSize,
                            height: _bigIconSize,
                            color: Colors.white,
                          ),
                          Image.asset(
                            mIconDownArrow,
                            width: _bigIconSize,
                            height: _smallIconSize,
                            color: Colors.white,
                          ),
                          Text(
                            'pressure'.tr,
                            style: textSmallWhite70,
                          )
                        ],
                      ),
                      Text(
                        '${formatPressure(widget.weatherResponse!.mainWeatherData!.pressure, settingBloc.pressureEnum.value)}',
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
    );
  }

  _initAnim() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
  }
}

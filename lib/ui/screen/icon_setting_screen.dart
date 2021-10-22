import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/shared/constant.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/utils/utils.dart';

const double _itemHeight = 150;
const double _iconSize = 20;
const int _itemCount = 10;

class IconSettingScreen extends StatefulWidget {
  const IconSettingScreen({Key? key}) : super(key: key);

  @override
  _IconSettingScreenState createState() => _IconSettingScreenState();
}

class _IconSettingScreenState extends State<IconSettingScreen> {
  Timer? timer;
  int index = 0;
  BehaviorSubject<int> behaviorSubject = BehaviorSubject.seeded(0);

  @override
  void initState() {
    super.initState();

    settingBloc.settingStream.listen((event) {
      if (this.mounted) {
        setState(() {});
        settingBloc.saveSetting();
      }
    });

    startAnim();
  }

  @override
  void dispose() {
    super.dispose();
    behaviorSubject.close();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appbar(),
      body: _body(),
    );
  }

  _appbar() => AppBar(
        leading: InkWell(
            onTap: () {
              appBloc.showInterstitialAd();
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text('app_name'.tr),
      );

  _body() => Column(
        children: [
          const SizedBox(
            height: marginLarge,
          ),
          _itemIcon(IconEnum.p1),
          _itemIcon(IconEnum.p2),
          _itemIcon(IconEnum.p3),
        ],
      );

  _itemIcon(IconEnum iconEnum) => GestureDetector(
        onTap: () =>
            settingBloc.changeSetting(iconEnum.value, SettingEnum.Icon),
        child: Container(
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.all(margin),
          decoration: BoxDecoration(
              color: iconEnum == settingBloc.iconEnum ? Colors.white30 : null,
              border: iconEnum == settingBloc.iconEnum
                  ? Border.all(color: Colors.white12, width: 1)
                  : null,
              borderRadius: iconEnum == settingBloc.iconEnum
                  ? BorderRadius.circular(radiusSmall)
                  : null),
          height: _itemHeight,
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: margin),
                    child: Icon(
                      Icons.check_circle,
                      color: iconEnum == settingBloc.iconEnum
                          ? Colors.green
                          : Colors.grey,
                    ),
                  )),
              Expanded(flex: 4, child: _gridIcon(iconEnum))
            ],
          ),
        ),
      );

  _gridIcon(IconEnum iconEnum) => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: _iconSize,
            crossAxisSpacing: _iconSize),
        itemBuilder: (context, index) {
          return StreamBuilder<int>(
            stream: behaviorSubject.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String tail = getImageByIndex(snapshot.data!);
                return Image.asset(
                  listIcon(tail, iconEnum.value)[index],
                  width: _iconSize,
                  height: _iconSize,
                );
              }
              return Image.asset(
                listIcon('00', iconEnum.value)[index],
                width: _iconSize,
                height: _iconSize,
              );
            },
          );
        },
        itemCount: _itemCount,
      );

  static List<String> listIcon(String tail, String iconType) => [
        // mIconRainyy(tail, iconType),
        // mIconSnoww(tail, iconType),
        // mIconThunderstormm(tail, iconType),
        // mIconHazyy(tail, iconType),
        // mIconFewCloudsNightt(tail, iconType),
        // mIconFewCloudsDayy(tail, iconType),
        // mIconClearsNightt(tail, iconType),
        // mIconClearss(tail, iconType),
        // mIconBrokenCloudss(tail, iconType),
        // mIconFogg(tail, iconType),
      ];

  startAnim() {
    timer = Timer.periodic(Duration(milliseconds: durationAnim), (timer) {
      if (index < imageQuantity) {
        index += 1;
      } else {
        index = 0;
      }
      behaviorSubject.add(index);
    });
  }
}

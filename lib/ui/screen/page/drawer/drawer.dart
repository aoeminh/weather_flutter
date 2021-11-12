import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../bloc/app_bloc.dart';
import '../../../../bloc/page_bloc.dart';
import '../../../../bloc/setting_bloc.dart';
import '../../../../model/city.dart';
import '../../../../model/weather_response.dart';
import '../../../../shared/dimens.dart';
import '../../../../shared/image.dart';
import '../../../../shared/strings.dart';
import '../../../../shared/text_style.dart';
import 'package:get/get.dart';
import '../../weather_screen.dart';

import '../../edit_location_screen.dart';

const double _iconDrawerSize = 30;
const int _defaultDisplayNumberLocation = 4;

class DrawerWidget extends StatefulWidget {
  final WeatherData weatherData;

  const DrawerWidget(this.weatherData, {Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isShowMore = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [_drawerBody(), _drawerHeader()],
        ),
      ),
    );
  }

  _drawerHeader() => Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: margin),
                Text('app_name'.tr, style: textTitleH1White),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white70),
        ],
      );

  _drawerBody() => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _listLocation(),
            Divider(height: 1, color: Colors.grey),
            _buildItemDrawer(
                mIconSettingNotify,
                'notification'.tr,
                Switch(
                  value: settingBloc.isOnNotification,
                  onChanged: (isOn) {
                    _showNotification(widget.weatherData.weatherResponse);
                  },
                ), () {
              _showNotification(widget.weatherData.weatherResponse);
            }),
            _buildItemUnit(
                mIconSettingTemp,
                'temp_unit'.tr,
                settingBloc.tempEnum.value,
                () => showSettingDialog(SettingEnum.TempEnum)),
            _buildItemUnit(
                mIconWind,
                'wind_unit'.tr,
                settingBloc.windEnum.value,
                () => showSettingDialog(SettingEnum.WindEnum)),
            _buildItemUnit(
                mIconSettingPressure,
                'pressure_unit'.tr,
                settingBloc.pressureEnum.value,
                () => showSettingDialog(SettingEnum.PressureEnum)),
            _buildItemUnit(
                mIconSettingVisibility,
                'visibility_unit'.tr,
                settingBloc.visibilityEnum.value,
                () => showSettingDialog(SettingEnum.VisibilityEnum)),
            _buildItemUnit(
                imSettingTime,
                'time_format'.tr,
                settingBloc.timeEnum.value,
                () => showSettingDialog(SettingEnum.TimeEnum)),
            _buildItemUnit(
                imSettingDate,
                'date_format'.tr,
                settingBloc.dateEnum.value,
                () => showSettingDialog(SettingEnum.DateEnum)),
            InkWell(
              onTap: () => showLanguageDialog(SettingEnum.Language),
              child: Container(
                padding: EdgeInsets.only(
                    left: padding, right: paddingSmall, bottom: padding),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.language,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: padding),
                    Text('setting_language'.tr, style: textTitleWhite),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey),
            InkWell(
              onTap: () {
                launch(appUrl);
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: padding, right: paddingSmall, top: padding),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.system_update,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: padding),
                    Text('check_update'.tr, style: textTitleWhite),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launch(appUrl);
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: padding, right: paddingSmall, top: padding),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.rate_review,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: padding),
                    Text('Rate us!', style: textTitleWhite),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  _listLocation() {
    return StreamBuilder<List<City>>(
        stream: pageBloc.currentCitiesStream as Stream<List<City>>?,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: padding, right: paddingSmall, bottom: padding),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          appBloc.showInterstitialAd();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditLocationScreen()));
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              mIconEditingLocation,
                              width: _iconDrawerSize,
                              height: _iconDrawerSize,
                            ),
                            const SizedBox(width: padding),
                            Text('edit_location'.tr, style: textTitleWhite),
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.length >
                                  _defaultDisplayNumberLocation
                              ? isShowMore
                                  ? snapshot.data!.length
                                  : _defaultDisplayNumberLocation
                              : snapshot.data!.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _itemLocation(snapshot.data![index], index);
                          }),
                      _showMoreLocation(snapshot.data!.length)
                    ],
                  ),
                ),
              ],
            );
          }

          return Container();
        });
  }

  _itemLocation(City city, int index) {
    return InkWell(
      onTap: () => pageBloc.jumpToPage(index),
      child: Container(
        padding: EdgeInsets.only(top: padding),
        child: Row(
          children: [
            Image.asset(
              mIconSettingLocation,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text('${city.name}', style: textTitleWhite),
          ],
        ),
      ),
    );
  }

  _showMoreLocation(int locationLength) {
    if (locationLength > _defaultDisplayNumberLocation) {
      return InkWell(
        onTap: () => setState(() {
          isShowMore = !isShowMore;
        }),
        child: Container(
          padding: EdgeInsets.only(top: padding),
          child: Row(
            children: [
              Image.asset(
                mIconMoreHoriz,
                width: _iconDrawerSize,
                height: _iconDrawerSize,
              ),
              const SizedBox(width: padding),
              Text(
                isShowMore
                    ? 'collapse'.tr
                    : '${'show_more'.tr} ${locationLength - _defaultDisplayNumberLocation}',
                style: textTitleWhite,
              ),
              Expanded(child: Container()),
              Icon(
                isShowMore
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
                size: _iconDrawerSize,
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _showNotification(WeatherResponse? response) {
    settingBloc.onOffNotification(response);
    setState(() {});
  }

  _buildItemDrawer(
      String imagePath, String title, Widget widget, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding:
            EdgeInsets.only(left: padding, right: paddingSmall, top: padding),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              color: Colors.white,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text(title, style: textTitleWhite),
            Expanded(child: Container()),
            widget
          ],
        ),
      ),
    );
  }

  _buildItemUnit(
      String imagePath, String title, String unit, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.only(
            left: padding, right: paddingSmall, bottom: padding),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              color: Colors.white,
              width: _iconDrawerSize,
              height: _iconDrawerSize,
            ),
            const SizedBox(width: padding),
            Text(title, style: textTitleWhite),
            Expanded(child: Container()),
            Text(unit, style: textSecondaryUnderlineBlue)
          ],
        ),
      ),
    );
  }

  showSettingDialog(SettingEnum settingEnum) {
    List<String> settings = [];
    String groupValue = '';
    String title = '';
    switch (settingEnum) {
      case SettingEnum.TempEnum:
        TempEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'temp_unit'.tr;
        groupValue = settingBloc.tempEnum.value;
        break;
      case SettingEnum.WindEnum:
        WindEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'wind_unit'.tr;
        groupValue = settingBloc.windEnum.value;
        break;
      case SettingEnum.PressureEnum:
        PressureEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'pressure_unit'.tr;
        groupValue = settingBloc.pressureEnum.value;
        break;
      case SettingEnum.VisibilityEnum:
        VisibilityEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'visibility_unit'.tr;
        groupValue = settingBloc.visibilityEnum.value;
        break;
      case SettingEnum.TimeEnum:
        TimeEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'time_format'.tr;
        groupValue = settingBloc.timeEnum.value;
        break;
      case SettingEnum.DateEnum:
        DateEnum.values.forEach((element) {
          settings.add(element.value);
        });
        title = 'date_format'.tr;
        groupValue = settingBloc.dateEnum.value;
        break;
      case SettingEnum.Language:
        // TODO: Handle this case.
        break;
    }

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: textTitleBold,
                        )),
                    ...settings.map((e) {
                      return Container(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: InkWell(
                            onTap: () {
                              _changeSetting(e, settingEnum);
                            },
                            child: ListTile(
                              title: Text(e),
                              leading: Radio<String>(
                                value: e,
                                groupValue: groupValue,
                                onChanged: (String? value) {
                                  _changeSetting(value, settingEnum);
                                },
                              ),
                            ),
                          ));
                    })
                  ],
                ),
              ),
            ),
          );
        });
  }

  showLanguageDialog(SettingEnum settingEnum) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'setting_language'.tr,
                          style: textTitleBold,
                        )),
                    ...LanguageEnum.values.toList().map((e) {
                      return Container(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: InkWell(
                            onTap: () {
                              _changeLanguageSetting(e);
                            },
                            child: ListTile(
                              title: Text(e.value),
                              leading: Radio<LanguageEnum>(
                                value: e,
                                groupValue: settingBloc.languageEnum,
                                onChanged: (LanguageEnum? value) {
                                  print(value);
                                  _changeLanguageSetting(value);
                                },
                              ),
                            ),
                          ));
                    })
                  ],
                ),
              ),
            ),
          );
        });
  }

  _changeSetting(String? value, SettingEnum settingEnum) {
    Navigator.pop(context);
    settingBloc.changeSetting(value, settingEnum);
  }

  _changeLanguageSetting(LanguageEnum? value) {
    Navigator.pop(context);
    settingBloc.changeLanguageSetting(value);
  }
}

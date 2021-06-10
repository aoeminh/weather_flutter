import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/air_pollution_level.dart';
import '../../shared/dimens.dart';
import '../../shared/text_style.dart';

const double _colorContainerSize = 30;
const double _emojiSize = 30;

class AirPollutionLevelScreen extends StatelessWidget {
  const AirPollutionLevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() => AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () => Navigator.pop(Get.context!),
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
        title: Text(
          'air_pollution_level'.tr,
          style: textTitleH2WhiteBold,
          overflow: TextOverflow.ellipsis,
        ),
      );

  _body() => Container(
        padding: EdgeInsets.all(padding),
        child: _listLevel(),
      );

  _listLevel() => ListView.separated(
      itemBuilder: (context, index) =>
          _itemLevel(AirPollutionLevel.listPollutionLevel[index]),
      separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey,
          ),
      itemCount: AirPollutionLevel.listPollutionLevel.length);

  _itemLevel(AirPollutionLevel airPollutionLevel) => Container(
        padding: EdgeInsets.symmetric(vertical: margin),
        child: Row(
          children: [
            Expanded(flex: 1, child: _colorAnnRange(airPollutionLevel)),
            Expanded(
              flex: 3,
              child: _descriptionInfo(airPollutionLevel),
            ),
          ],
        ),
      );

  _colorAnnRange(AirPollutionLevel airPollutionLevel) => Column(
        children: [
          Container(
            width: _colorContainerSize,
            height: _colorContainerSize,
            decoration: BoxDecoration(
                color: airPollutionLevel.color,
                borderRadius: BorderRadius.circular(_colorContainerSize)),
          ),
          const SizedBox(
            height: margin,
          ),
          Text(
            '${airPollutionLevel.minAqi} - ${airPollutionLevel.maxAqi}',
            style: textTitleWhite,
          )
        ],
      );

  _descriptionInfo(AirPollutionLevel airPollutionLevel) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                airPollutionLevel.emoji,
                width: _emojiSize,
                height: _emojiSize,
              ),
              const SizedBox(
                width: marginSmall,
              ),
              Expanded(
                  child: Text(
                '${airPollutionLevel.level}',
                style: textTitleH2White,
              )),
            ],
          ),
          const SizedBox(
            height: marginSmall,
          ),
          Text(
            '${airPollutionLevel.healthImplications}',
            style: textTitleWhite,
          ),
          const SizedBox(
            height: marginSmall,
          ),
          Text(
            '${airPollutionLevel.cautionaryStatement}',
            style: textSecondaryWhite70,
          )
        ],
      );
}

import 'package:flutter/material.dart';
import '../../model/air_pollution_level.dart';
import '../screen/air_pollution_level_screen.dart';
import '../../shared/text_style.dart';

import '../../model/air_data.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';

class AirPollutionWidget extends StatelessWidget {
  final AirData airData;

  const AirPollutionWidget(this.airData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    String level = '';
    String implication = '';
    AirPollutionLevel.listPollutionLevel.forEach((element) {
      if (airData.aqi >= element.minAqi && airData.aqi <= element.maxAqi) {
        color = element.color;
        level = element.level;
        implication = element.healthImplications;
      }
    });
    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.symmetric(vertical: margin, horizontal: padding),
      decoration: BoxDecoration(
          color: transparentBg,
          borderRadius: BorderRadius.circular(radiusSmall),
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${airData.aqi}',
                style: textTitleWhite36,
              ),
              const SizedBox(width: margin),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: _level(level, color),
                    ),
                    const SizedBox(width: margin),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AirPollutionLevelScreen())),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )

            ],
          ),
          const SizedBox(height: margin),
          Text(
            implication,
            style: textSmallWhite70,
          ),
          const SizedBox(height: margin),
          _rowIaqi(airData)
        ],
      ),
    );
  }

  _level(String content, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: marginSmall, horizontal: margin),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(26), color: color),
      child: Text(
        content,
        style: textTitleWhite,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _rowIaqi(AirData airData) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _itemIaqi('PM2.5', airData.iaqi.pm25.v.toInt()),
          _itemIaqi('CO', airData.iaqi.co.v.toInt()),
          _itemIaqi('NO2', airData.iaqi.no2.v.toInt()),
          _itemIaqi('SO2', airData.iaqi.so2.v.toInt()),
          _itemIaqi('O3', airData.iaqi.o3.v.toInt()),
        ],
      );

  _itemIaqi(String title, int data) {
    return Column(
      children: [
        Text(
          '$data',
          style: textTitleWhite,
        ),
        const SizedBox(
          height: margin,
        ),
        Text(
          title,
          style: textSmallWhite70,
        )
      ],
    );
  }
}

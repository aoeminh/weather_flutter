import 'package:flutter/material.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:get/get.dart';
import 'package:weather_app/utils/utils.dart';
import '../../model/covid_summary_response.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';

class Covid19 extends StatelessWidget {
  final Country? country;

  const Covid19({Key? key, this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.symmetric(vertical: margin, horizontal: padding),
      decoration: BoxDecoration(
          color: transparentBg,
          borderRadius: BorderRadius.circular(radiusSmall),
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Align(
        alignment: Alignment.center,
        child: _body(),),
    );
  }

  _body() => Column(
        children: [
          Flexible(child:  _title()),
          _verticalMargin(),
          Flexible(child:       _content('confirmed cases'.tr, '${formatNumber(country!.totalConfirmed!)}',
              '+${country!.newConfirmed}'),),
          _verticalMargin(),
          Flexible(child:  _content(
              'recovered'.tr,
              '${country!.totalRecovered! != 0 ? formatNumber(country!.totalRecovered!) : '-'}',
              '${country!.newRecovered! != 0 ? country!.newRecovered! : '-'}'),),

          _verticalMargin(),
          Flexible(child:
          _content(
              'deaths'.tr, '${formatNumber(country!.totalDeaths!)}', '+${country!.newDeaths}'),),

        ],
      );

  _title() => Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(
                '${country!.country}',
                style: textTitleWhite,
              )),
          Expanded(
              flex: 2,
              child: Text(
                'total'.tr,
                style: textTitleWhite,
                textAlign: TextAlign.end,
              )),
          _horizontalMargin(),
          Expanded(
              flex: 2,
              child: Text(
                'today'.tr,
                style: textTitleWhite,
                textAlign: TextAlign.end,
              )),
        ],
      );

  _content(String title, String total, String today) => Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(
                '$title',
                style: textSecondaryWhite70,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '$total',
                style: textSecondaryWhite70,
                textAlign: TextAlign.end,
              )),
          _horizontalMargin(),
          Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all( 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: today != '-' ? Colors.red[700] : null),
                  child: Text(
                    '$today',
                    style: textSecondaryWhite,
                    textAlign: TextAlign.end,
                  ))),
        ],
      );

  _verticalMargin() => SizedBox(
        height: marginSmall,
      );

  _horizontalMargin() => SizedBox(
        width: margin,
      );
}

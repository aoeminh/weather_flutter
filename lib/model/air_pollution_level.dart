import 'dart:ui';
import 'package:get/get.dart';
import '../shared/image.dart';
class AirPollutionLevel {
  late int minAqi;
  late int maxAqi;
  late String level;
  late String healthImplications;
  late String cautionaryStatement;
  late Color color;
  late String emoji;

  AirPollutionLevel(this.minAqi, this.maxAqi, this.level,
      this.healthImplications, this.cautionaryStatement, this.color,this.emoji);

  static List<AirPollutionLevel> listPollutionLevel = [
    AirPollutionLevel(0,50,'good'.tr,'good_implications'.tr,'good_cautionary'.tr,Color(0xff009966),icEmojiAqi1),
    AirPollutionLevel(51,100,'moderate'.tr,'moderate_implications'.tr,'moderate_cautionary'.tr,Color(0xffFFDE33),icEmojiAqi2),
    AirPollutionLevel(101,150,'unhealthy_sensitive'.tr,'sensitive_implications'.tr,'sensitive_cautionary'.tr,Color(0xffFF9933),icEmojiAqi3),
    AirPollutionLevel(151,200,'unhealthy'.tr,'unhealthy_implications'.tr,'unhealthy_cautionary'.tr,Color(0xffCC0033),icEmojiAqi4),
    AirPollutionLevel(201,300,'very_unhealthy'.tr,'very_unhealthy_implications'.tr,'very_unhealthy_cautionary'.tr,Color(0xff660099),icEmojiAqi5),
    AirPollutionLevel(300,350,'hazardous'.tr,'hazardous_implications'.tr,'hazardous_cautionary'.tr,Color(0xff7E0023),icEmojiAqi6),
  ];
}


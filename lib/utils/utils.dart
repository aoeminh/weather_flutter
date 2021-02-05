import 'package:flutter/material.dart';
import 'package:weather_app/shared/strings.dart';
import 'package:weather_app/shared/image.dart';

Image getIconForecastImage(String iconCode) {
  switch (iconCode) {
    case mClear:
      return Image.asset(mIconClears);
    case mClearN:
      return Image.asset(mIconClearsNight);
    case mFewClouds:
      return Image.asset(mIconFewCloudsDay);
    case mFewCloudsN:
      return Image.asset(mIconFewCloudsNight);
    case mClouds:
    case mCloudsN:
    case mBrokenClouds:
    case mBrokenCloudsN:
      return Image.asset(mIconBrokenClouds);
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return Image.asset(mIconRainy);
    case mthunderstorm:
    case mthunderstormN:
      return Image.asset(mIconThunderstorm);
    case mSnow:
    case mSnowN:
      return Image.asset(mIconSnow);
    case mist:
    case mistN:
      return Image.asset(mIconFog);
    default:
      return Image.asset(mIconClears);
  }
}

String getIconForecastUrl(String iconCode) {
  switch (iconCode) {
    case mClear:
      return mIconClears;
    case mClearN:
      return mIconClearsNight;
    case mFewClouds:
      return mIconFewCloudsDay;
    case mFewCloudsN:
      return mIconFewCloudsNight;
    case mClouds:
    case mCloudsN:
    case mBrokenClouds:
    case mBrokenCloudsN:
      return mIconClearsNight;
    case mShowerRain:
    case mShowerRainN:
    case mRain:
    case mRainN:
      return mIconRainy;
    case mthunderstorm:
    case mthunderstormN:
      return mIconThunderstorm;
    case mSnow:
    case mSnowN:
      return mIconSnow;
    case mist:
    case mistN:
      return mIconFog;
    default:
      return mIconClears;
  }
}


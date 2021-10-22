import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/shared/constant.dart';

import '../model/application_error.dart';
import '../model/city.dart';
import '../model/coordinates.dart';
import '../utils/share_preferences.dart';
import 'base_bloc.dart';


const _timeReShowAds = 60;

class AppBloc extends BlocBase {
  List<City>? _cities;
  List<City>? _suggestCities;
  BehaviorSubject<ApplicationError> _errorBehavior = BehaviorSubject();
  bool isShowAds = true;
  Timer? _timer;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  BannerAd? myBanner;
  BannerAd? myBanner1;
  BannerAd? myBanner2;

  addError(ApplicationError error) {
    _errorBehavior.add(error);
  }

  Future<City> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    var position = await Geolocator.getCurrentPosition();
    return City(
        coordinates: Coordinates(position.longitude, position.latitude));
    // add the first city
  }

  getListCity() async {
    String cityStr = await rootBundle.loadString("assets/city/cities.json");

    List<dynamic> list = jsonDecode(cityStr);
    _cities = list.map((e) => City.fromAssetJson(e)).toList();
  }

  getListSuggestCity() async {
    String cityStr =
        await rootBundle.loadString("assets/city/suggest_city.json");

    List<dynamic> list = jsonDecode(cityStr);
    _suggestCities = list.map((e) => City.fromJson(e)).toList();
  }

  List<City> decodeListCity(String cities) {
    return (jsonDecode(cities) as List<dynamic>)
        .map((e) => City.fromJson(e))
        .toList();
  }

  saveListCity(List<City> cities) async {
    await Preferences.saveListCity(cities);
  }

  Future<List<City>> getListCityFromCache() async {
    return Preferences.getListCityFromCache();
  }

  void createBannerAds() async {
    AnchoredAdaptiveBannerAdSize? width =
        await AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait,
            (MediaQuery.of(Get.context!).size.width.truncate() - 20).toInt());
    myBanner = myBanner ??
        BannerAd(
          adUnitId: productBannerAdsId,
          size: width ?? AdSize.leaderboard,
          request: AdRequest(),
          listener: createBannerAdCallback(),
        );
    myBanner1 = myBanner1 ??
        BannerAd(
          adUnitId: productBannerAdsId1,
          size: width ?? AdSize.leaderboard,
          request: AdRequest(),
          listener: createBannerAdCallback(),
        );

    myBanner2 = myBanner2 ??
        BannerAd(
          adUnitId: productBannerAdsId2,
          size: width ?? AdSize.leaderboard,
          request: AdRequest(),
          listener: createBannerAdCallback(),
        );

    // myBanner!.load();
    // myBanner1!.load();
    // myBanner2!.load();
  }

  BannerAdListener createBannerAdCallback() => BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          isShowAds = false;
          print('Ad opened.');
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          startTimer();
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      );

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: productIntermediaryAdsId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    if (!isShowAds) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('onAdShowedFullScreenContent');
        isShowAds = false;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('onAdShowedFullScreenContent');
        startTimer();
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    } else {
      int _start = _timeReShowAds;
      const oneSec = const Duration(seconds: 1);
      new Timer.periodic(
        oneSec,
        (Timer timer) {
          if (_start == 0) {
            print(' isShowAds = true;');
            isShowAds = true;
            timer.cancel();
          } else {
            _start--;
          }
        },
      );
    }
  }

  Stream<ApplicationError> get errorStream => _errorBehavior.stream;

  List<City>? get cities => _cities;

  List<City>? get suggestCities => _suggestCities;

  @override
  void dispose() {
    _errorBehavior.close();
    if (_timer != null) _timer!.cancel();
    _numInterstitialLoadAttempts = 0;
  }
}

final appBloc = AppBloc();

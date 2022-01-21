import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/shared/constant.dart';

import '../main.dart';
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
  int maxFailedLoadAttempts = 10;
  String? keyAds;
  Position? currentLocation;

  final DatabaseReference db = FirebaseDatabase(app: firebaseApp).reference();

  getAdKey() {
    db.onChildAdded.listen((event) {
      if (event.snapshot.value.toString().trim().isNotEmpty) {
        keyAds = event.snapshot.value;
      } else {
        keyAds = productIntermediaryAdsId;
      }
      createInterstitialAd();
      print('keyAds ${event.snapshot.value}');
    });
  }

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
    currentLocation = await Geolocator.getCurrentPosition();
    return City(
        coordinates:
            Coordinates(currentLocation!.longitude, currentLocation!.latitude));
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

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: InterstitialAd.testAdUnitId,
        // adUnitId: keyAds ?? '',
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

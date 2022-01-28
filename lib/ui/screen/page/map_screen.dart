import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/model/coordinates.dart';
import 'package:weather_app/shared/text_style.dart';

class MapScreen extends StatefulWidget {
  final LatLng? latLng;

  MapScreen({Key? key, this.latLng}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition? _kInitialPosition;
  CameraPosition? currentCamPosition;
  String? name = '';
  String? country = '';

  @override
  void initState() {
    super.initState();

    _kInitialPosition = CameraPosition(
      target: LatLng(widget.latLng!.latitude, widget.latLng!.longitude),
      zoom: 7,
    );
    currentCamPosition = _kInitialPosition;
    placemarkFromCoordinates(currentCamPosition!.target.latitude,
            currentCamPosition!.target.longitude)
        .then((value) {
      setState(() {
        name = value.first.administrativeArea;
        country = value.first.country;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _kInitialPosition != null
            ? Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _kInitialPosition!,
                      mapType: MapType.hybrid,
                      zoomControlsEnabled: false,
                      onCameraIdle: _onCamIdle,
                      onCameraMove: _onCamMove,
                    ),
                    Center(
                      child: Icon(
                        Icons.location_on_sharp,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    Positioned(bottom: 8, left: 8, right: 8, child: _bottom()),
                    Positioned(
                      top: 50,
                      left: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('$name - $country '),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox(),
        onWillPop: onWillPop);
  }

  _bottom() => GestureDetector(
        onTap: () {
          appBloc.showInterstitialAd();
          pageBloc.addNewCity(City(
              id: currentCamPosition!.bearing,
              name: name,
              country: country,
              coordinates: Coordinates(currentCamPosition!.target.longitude,
                  currentCamPosition!.target.latitude)));
          appBloc.showInterstitialAd();
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.green),
            child: Center(
                child: Text(
              'OK',
              style: textTitleWhiteBold,
            ))),
      );

  Future<bool> onWillPop() async {
    return true;
  }

  _onCamMove(CameraPosition cameraPosition) {
    currentCamPosition = cameraPosition;
  }

  _onCamIdle() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        currentCamPosition!.target.latitude,
        currentCamPosition!.target.longitude);

    setState(() {
      name = placemarks.first.administrativeArea;
      country = placemarks.first.country;
    });
  }
}

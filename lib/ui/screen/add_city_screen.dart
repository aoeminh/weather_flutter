import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';
import 'package:weather_app/ui/screen/page/map_screen.dart';

const double _heightItem = 50;

class AddCityScreen extends StatefulWidget {
  @override
  _AddCityScreenState createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  List<City>? listCity = [];
  CameraPosition? _kInitialPosition;

  @override
  void initState() {
    super.initState();
    listCity = appBloc.cities;
    appBloc.determinePosition().then((value) {
      setState(() {
        _kInitialPosition = CameraPosition(
          target:
              LatLng(value.coordinates!.latitude, value.coordinates!.longitude),
          zoom: 8,
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _body(),
      ),
    );
  }

  _body() => Container(
        child: Column(
          children: [
            SizedBox(
              height: _heightItem,
            ),
            _searchView(),
            const SizedBox(
              height: 16,
            ),
            _map(),
            const SizedBox(
              height: 16,
            ),
            Expanded(child: _similarCity())
          ],
        ),
      );

  _searchView() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radiusSmall)),
        child: _autoComplete());
  }

  _onItemSubmit(City city) {
    appBloc.showInterstitialAd();
    pageBloc.addNewCity(city);
    Navigator.pop(context);
  }

  _autoComplete() => RawAutocomplete<City>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const [];
        }
        return listCity!.where((City city) {
          return city.name!
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (City city) {
        _onItemSubmit(city);
      },
      displayStringForOption: (city) {
        return '${city.name} - ${city.province}/${city.country}';
      },
      fieldViewBuilder:
          (context, textEditController, focusNode, voidCallBack) => TextField(
                controller: textEditController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'insert_city_name'.tr,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusColor: Colors.black,
                  icon: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                          margin: EdgeInsets.only(left: margin),
                          child: Icon(Icons.arrow_back))),
                ),
              ),
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<City> onSelected, Iterable<City> options) {
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            final City city = options.elementAt(index);
            return GestureDetector(
              onTap: () => onSelected(city),
              child: Material(
                child: ListTile(
                  title:
                      Text('${city.name} - ${city.province}/${city.country}'),
                ),
              ),
            );
          },
        );
      });

  _map() => _kInitialPosition != null
      ? GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => MapScreen(latLng: _kInitialPosition!.target,))),
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _kInitialPosition!,
                  mapType: MapType.hybrid,
                  onTap: (_) => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapScreen(latLng: _kInitialPosition!.target,))),
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black87),
                        child: Text(
                          'Pick a location from the map',
                          style: textTitleWhite70,
                        ))),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MapScreen(latLng: _kInitialPosition!.target,))),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(40)),
                        child: Icon(
                          Icons.zoom_out_map_outlined,
                          color: Colors.white,
                        )),
                  ),
                )
              ],
            ),
          ),
        )
      : const SizedBox(
          height: 100,
        );

  _similarCity() {
    return Container(
      child: Column(
        children: [
          Container(
            height: _heightItem,
            child: Row(
              children: [
                Image.asset(
                  mIconSettingLocation,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(
                  width: margin,
                ),
                Text(
                  'similar_city'.tr,
                  style: textTitleWhite70,
                ),
              ],
            ),
          ),
          Expanded(
            child: _listLocation(),
          )
        ],
      ),
    );
  }

  _listLocation() {
    return ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return _itemSimilar(appBloc.suggestCities![index]);
        },
        separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white24,
            ),
        itemCount: appBloc.suggestCities!.length);
  }

  _itemSimilar(City city) => InkWell(
        onTap: () => _onItemSubmit(city),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: padding),
          height: _heightItem,
          child: RichText(
            text: TextSpan(
                text: city.name,
                style: textTitleWhite,
                children: <TextSpan>[
                  TextSpan(
                      text: ' - ${city.province}/${city.country}',
                      style: textTitleWhite70)
                ]),
          ),
        ),
      );
}

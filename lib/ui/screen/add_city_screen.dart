import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/shared/text_style.dart';

const double _heightItem = 50;

class AddCityScreen extends StatefulWidget {
  @override
  _AddCityScreenState createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<City>>();
  List<City> listCity = [];
  List<City> listSimilarCity = [];

  @override
  void initState() {
    super.initState();
    listCity = cityBloc.cities;
    for (City city in listCity) {
      if (city.country == 'VN') {
        listSimilarCity.add(city);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _body(),
    );
  }

  _body() => Container(
        child: Column(
          children: [
            SizedBox(
              height: _heightItem,
            ),
            _searchView(),
            Expanded(child: _similarCity())
          ],
        ),
      );

  _searchView() {
    final double width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radiusSmall)),
      child: Row(
        children: [
          Container(
            height: _heightItem,
            width: width,
            child: AutoCompleteTextField<City>(
              suggestions: listCity,
              key: key,
              decoration: InputDecoration(
                hintText: 'Insert city name',
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
              itemSubmitted: _onItemSubmit,
              itemBuilder: (context, city) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    height: _heightItem,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${city.name} - ${city.country}',
                        )));
              },
              itemFilter: (city, string) =>
                  city.name.toLowerCase().startsWith(string.toLowerCase()),
              itemSorter: (a, b) => a.name.compareTo(b.name),
            ),
          )
        ],
      ),
    );
  }

  _onItemSubmit(City city) {
    print('${city.name}');
    pageBloc.addPage(city.coordinates.latitude, city.coordinates.longitude);
    Navigator.pop(context);
  }

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
                  'Similar location',
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
          return _itemSimilar(listSimilarCity[index]);
        },
        separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white24,
            ),
        itemCount: listSimilarCity.length);
  }

  _itemSimilar(City city) => InkWell(
    onTap: () =>_onItemSubmit(city),
    child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: padding),
          height: _heightItem,
          child: RichText(
            text: TextSpan(
                text: city.name,
                style: textTitleWhite,
                children: <TextSpan>[
                  TextSpan(text: '- ${city.country}', style: textTitleWhite70)
                ]),
          ),
        ),
  );
}

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/shared/dimens.dart';

class AddCityScreen extends StatefulWidget {
  @override
  _AddCityScreenState createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  GlobalKey key =
  new GlobalKey<AutoCompleteTextFieldState<City>>();
  TextEditingController _controller = TextEditingController();
  List<City> listCity = [];


  @override
  void initState() {
    super.initState();
    listCity = cityBloc.cities;
    print('dddddd${listCity.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _body(),
    );
  }

  _body() =>
      Container(
        child: Column(
          children: [
            SizedBox(height: 50,),
            _searchView(),
          ],
        ),
      );

  _searchView() {
    final double width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radiusSmall)
      ),
      child: Row(
        children: [

          Container(
            height: 50,
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
                icon:  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        margin: EdgeInsets.only(left: margin),
                        child: Icon(Icons.arrow_back))),
              ),

              itemSubmitted: _onItemSubmit,
              itemBuilder: (context, city){
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                    height: 50,
                    child: Align(
                        alignment: Alignment.centerLeft,child: Text('${city.name} - ${city.country}',)));
              },
              itemFilter: (city,string)=> city.name.toLowerCase().startsWith(string.toLowerCase()),
              itemSorter: (a,b) => a.name.compareTo(b.name),
            ),
          )

        ],
      ),
    );
  }

  _onItemSubmit(City city){
   print('${city.name}');
   pageBloc.addPage(city.coordinates.latitude, city.coordinates.longitude);
   Navigator.pop(context);
  }
}

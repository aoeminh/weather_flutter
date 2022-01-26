import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/shared/text_style.dart';

import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import 'add_city_screen.dart';

const double _iconSize = 20;

class EditLocationScreen extends StatefulWidget {
  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  bool isDeleteMode = true;
  List<City> _listTempCity = [];

  @override
  void initState() {
    super.initState();

    _listTempCity = pageBloc.copyCurrentCityList(pageBloc.currentCityList);
    _listTempCity.forEach((element) {
      print('element latitude ${element.coordinates!.latitude} longitude ${element.coordinates!.longitude}');
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
          title: Text(
            'edit_location'.tr,
            style: textTitleH2WhiteBold,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: margin),
              child: isDeleteMode
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          isDeleteMode = !isDeleteMode;
                        });
                      },
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        setState(() {
                          pageBloc.editCurrentCityList(
                              pageBloc.copyCurrentCityList(_listTempCity));
                          isDeleteMode = !isDeleteMode;
                        });
                      },
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
            )
          ],
        ),
        body: _body(),
      ),
    );
  }

  _body() => isDeleteMode
      ? _listView()
      : Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: ReorderableListView.builder(
            header: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddCityScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: margin,
                  ),
                  Text(
                    'add_new_city'.tr,
                    style: textTitleWhite,
                  )
                ],
              ),
            ),
            itemBuilder: (context, index) =>
                _buildItemCityList(_listTempCity[index]),
            itemCount: _listTempCity.length,
            onReorder: (oldIndex, newIndex) {
              _reorderList(oldIndex, newIndex);
            },
          ),
        );

  _listView() => SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AddCityScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: margin,
                  ),
                  Text(
                    'add_new_city'.tr,
                    style: textTitleWhite,
                  )
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  _buildItemCityList(_listTempCity[index]),
              itemCount: _listTempCity.length,
            ),
          ],
        ),
      );

  _buildItemCityList(City city) => Container(
      key: ValueKey(city),
      child: ListTile(
        title: Row(
          children: [
            RichText(
              text: TextSpan(text: city.name, style: textTitleWhite, children: [
                TextSpan(text: ' - ${city.country}', style: textTitleWhite70)
              ]),
            ),
            city.isHome
                ? Row(
                    children: [
                      const SizedBox(
                        width: marginLarge,
                      ),
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: _iconSize,
                      ),
                      Icon(
                        Icons.home,
                        color: Colors.blue,
                        size: _iconSize,
                      )
                    ],
                  )
                : Container()
          ],
        ),
        trailing: isDeleteMode
            ? !city.isHome
                ? InkWell(
                    onTap: () {
                      _listTempCity.remove(city);
                      pageBloc.editCurrentCityList(_listTempCity);
                      setState(() {});
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: _iconSize,
                    ),
                  )
                : Container(
                    width: 1,
                  )
            : Icon(Icons.menu, color: Colors.white, size: _iconSize),
      ));

  _reorderList(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _listTempCity.removeAt(oldIndex);
      _listTempCity.insert(newIndex, item);
    });
  }
}

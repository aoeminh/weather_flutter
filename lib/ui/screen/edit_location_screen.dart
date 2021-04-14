import 'package:flutter/material.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/bloc/page_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/shared/text_style.dart';

import '../../shared/colors.dart';
import '../../shared/dimens.dart';

class EditLocationScreen extends StatefulWidget {
  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  bool isDeleteMode = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
          title: Text('Edit Location'),
          actions: [
            isDeleteMode
                ? Icon(
                    Icons.edit,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.check,
                    color: Colors.white,
                  )
          ],
        ),
        body: _body(),
      ),
    );
  }

  _body() => Container(
        color: backgroundColor,
        padding: EdgeInsets.all(padding),
        child: ReorderableListView(
          onReorder: (oldIndex, newIndex) {},
          children: [
            ...pageBloc.currentCity.map((city) => _buildItemCityList(city))
          ],
        ),
      );

  _buildItemCityList(City city) => Container(
      key: ValueKey(city),
      child: ListTile(
        title: RichText(
          text: TextSpan(text: city.name, style: textTitleWhite, children: [
            TextSpan(text: ' - ${city.country}', style: textTitleWhite70)
          ]),
        ),
        trailing: Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ));
}

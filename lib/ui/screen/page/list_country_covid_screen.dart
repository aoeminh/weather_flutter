import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../bloc/app_bloc.dart';
import '../../../model/covid_summary_response.dart';
import '../../../shared/dimens.dart';
import '../../widgets/covid_19.dart';

class ListCountryCovid extends StatefulWidget {
  final CovidSummaryResponse? covidSummaryResponse;

  const ListCountryCovid({Key? key, this.covidSummaryResponse})
      : super(key: key);

  @override
  _ListCountryCovidState createState() => _ListCountryCovidState();
}

class _ListCountryCovidState extends State<ListCountryCovid> {
  List<Country> countries = [];

  @override
  void initState() {
    super.initState();
    countries.addAll(widget.covidSummaryResponse!.countries!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        appBloc.showInterstitialAd();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _appbar(),
        body: _body(),
      ),
    );
  }

  _appbar() => AppBar(
        leading: InkWell(
            onTap: () {
              appBloc.showInterstitialAd();

              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text('list_country'.tr),
      );

  _body() => Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: margin),
            decoration: BoxDecoration(color: Colors.white),
            child: TextField(
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              onChanged: (value) {
                countries.clear();
                countries.addAll(widget.covidSummaryResponse!.countries!.where(
                    (element) => element.country!
                        .toLowerCase()
                        .contains(value.toLowerCase())));
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'inser_country_name'.tr,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: margin,
          ),
          Expanded(child: _listCountry())
        ],
      );

  _listCountry() => ListView.separated(
      itemBuilder: (context, index) => Covid19(
        country: countries[index],
      ),
      separatorBuilder: (_, __) => const SizedBox(),
      itemCount: countries.length);
}

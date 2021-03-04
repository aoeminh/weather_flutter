import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/shared/dimens.dart';
import 'package:weather_app/shared/image.dart';
import 'package:weather_app/utils/utils.dart';
import '../../shared/text_style.dart';
import '../../shared/strings.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:rxdart/rxdart.dart';

const double iconWeatherSize = 30;
const double iconDetailSize = 20;

class HourlyForecastScreen extends StatefulWidget {
  final WeatherForecastListResponse weatherForecastListResponse;


  const HourlyForecastScreen({Key key, this.weatherForecastListResponse})
      : super(key: key);

  @override
  _HourlyForecastState createState() => _HourlyForecastState();
}

class _HourlyForecastState extends State<HourlyForecastScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  BehaviorSubject<int> dateBehaviorSubject =BehaviorSubject.seeded(0);

  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(()=> {
      if(dateBehaviorSubject.value != itemPositionsListener.itemPositions.value.first.index){
        dateBehaviorSubject.add(itemPositionsListener.itemPositions.value.first.index)
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    dateBehaviorSubject.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '72 Hours Forecast',
            style: textTitleH1White,
          ),
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_rounded)),
          backgroundColor: Colors.black,
        ),
        body:  _buildBody());
  }

  _buildBody() {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: ScrollablePositionedList.separated(
                  itemBuilder: (context, index) =>
                      _buildItem(widget.weatherForecastListResponse.list[index]),
                  separatorBuilder: (context, index) => const Divider(color: Colors.grey,),
                  itemCount: widget.weatherForecastListResponse.list.length,
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildDateHeader(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<int>(
            stream: dateBehaviorSubject.stream,
            builder: (context, snapshot){
              if(snapshot.hasData){
                DateTime dateTime = widget.weatherForecastListResponse.list[snapshot.data].dateTime;
                return Container(
                    margin: EdgeInsets.all(padding),

                    child: Text('${formatDateAndWeekDay(dateTime)}',style: textTitleWhite,));
              }else{
                return Container();
              }
            },
          ),
          const Divider(color: Colors.grey,)
        ],
      ),
    );

  }


  _buildItem(WeatherForecastResponse weatherForecastResponse) => Container(
        child: Container(
          padding: EdgeInsets.all(margin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1, child: _buildTimeAndIcon(weatherForecastResponse)),
              SizedBox(
                width: marginLarge,
              ),
              Expanded(
                flex: 4,
                child: _buildDetail(weatherForecastResponse),
              )
            ],
          ),
        ),
      );

  _buildTimeAndIcon(WeatherForecastResponse weatherForecastResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "${getTimeLabel(weatherForecastResponse.dateTime)}",
          style: textSecondaryWhite,
        ),
        _marginVertical(),
        Image.asset(
          getIconForecastUrl(
              weatherForecastResponse.overallWeatherData[0].icon),
          width: iconWeatherSize,
          height: iconWeatherSize,
        )
      ],
    );
  }

  _buildDetail(WeatherForecastResponse weatherForecastResponse) {
    return Column(
      children: [
        _buildRowHeader(weatherForecastResponse),
        const SizedBox(
          height: margin,
        ),
        _buildRowDetails(mIconSettingWind, 'Wind',
            '${convertMetersPerSecondToKilometersPerHour(weatherForecastResponse.wind.speed).toInt()}km/h'),
        const Divider(
          color: Colors.grey,
        ),
        _buildRowDetails(mIcPrecipitation, 'Precipitation',
            '${weatherForecastResponse.pop}$percent'),
        const Divider(
          color: Colors.grey,
        ),
        _buildRowDetails(mIconCloudCover, 'Cloud Cover',
            '${weatherForecastResponse.clouds.all}$percent'),
      ],
    );
  }

  _buildRowHeader(WeatherForecastResponse weatherForecastResponse) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${weatherForecastResponse.overallWeatherData[0].main}',
          style: textTitleWhite,
        ),
        Text(
          'Feels Like: ${weatherForecastResponse.mainWeatherData.feelsLike.toInt()}$degree',
          style: textTitleWhite,
        ),
        Text(
          '${weatherForecastResponse.mainWeatherData.temp.toInt()}$degree',
          style: textTitleWhite,
        ),
      ],
    );
  }

  _buildRowDetails(String iconUrl, String title, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              iconUrl,
              width: iconDetailSize,
              height: iconDetailSize,
              color: Colors.grey,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: marginSmall,
            ),
            Text(
              title,
              style: textSecondaryGrey,
            ),
          ],
        ),
        Text(
          data,
          style: textSecondaryWhite,
        )
      ],
    );
  }

  _marginVertical() => SizedBox(
        height: margin,
      );
}

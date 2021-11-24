import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/bloc/app_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Radar extends StatefulWidget {
  const Radar({Key? key}) : super(key: key);

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  double? lat;
  double? lon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lat = appBloc.currentLocation!.latitude;
    lon = appBloc.currentLocation!.longitude;
    print('<html><body><iframe src="https://www.rainviewer.com/map.html?loc=$lat,$lon&oFa=0&oC=0&oU=0&oCS=1&oF=0&oAP=1&rmt=0&c=1&o=83&lm=0&th=0&sm=1&sn=1" width="100%" frameborder="0" style="border:0;height:100vh;" allowfullscreen></iframe></body></html>');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radar'),
      ),
      body: Container(
          child: WebView(
        initialUrl: Uri.dataFromString(
                '<html><body><iframe src="https://www.rainviewer.com/map.html?loc=$lat,$lon,5&oFa=0&oC=0&oU=0&oCS=1&oF=0&oAP=1&rmt=0&c=1&o=83&lm=0&th=0&sm=1&sn=1" width="100%" frameborder="0" style="border:0;height:100vh;" allowfullscreen></iframe></body></html>',
                mimeType: 'text/html')
            .toString(),
        javascriptMode: JavascriptMode.unrestricted,
      )),
    );
  }
}

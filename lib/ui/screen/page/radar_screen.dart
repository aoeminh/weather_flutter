import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Radar extends StatefulWidget {
  final double? lat;
  final double? lon;

  const Radar({this.lat, this.lon, Key? key}) : super(key: key);

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  // var a= '<html><body><iframe src="https://www.rainviewer.com/map.html?loc=${widget.lat},${widget.lon},5&oFa=0&oC=0&oU=0&oCS=1&oF=0&oAP=1&rmt=0&c=1&o=83&lm=0&th=0&sm=1&sn=1" width="100%" frameborder="0" style="border:0;height:100vh;" allowfullscreen></iframe></body></html>';

  String windy(double lat, double lon) =>
      '<html><body><iframe style="border:0" height="100%" width="100%" src="https://embed.windy.com/embed2.html?lat=19.124&lon=$lon&detailLat=$lat&detailLon=105.852&width=650&height=450&zoom=7&level=surface&overlay=wind&product=ecmwf&menu=&message=&marker=&calendar=now&pressure=&type=map&location=coordinates&detail=&metricWind=default&metricTemp=default&radarRange=-1" frameborder="0"></iframe></body></html>';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                    child: WebView(
                  initialUrl: Uri.dataFromString(
                          windy(widget.lat!, widget.lon!),
                          mimeType: 'text/html')
                      .toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                )),
                Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Icon(Icons.arrow_back)),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

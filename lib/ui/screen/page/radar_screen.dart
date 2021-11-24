import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();
  }

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
                          '<html><body><iframe src="https://www.rainviewer.com/map.html?loc=${widget.lat},${widget.lon},5&oFa=0&oC=0&oU=0&oCS=1&oF=0&oAP=1&rmt=0&c=1&o=83&lm=0&th=0&sm=1&sn=1" width="100%" frameborder="0" style="border:0;height:100vh;" allowfullscreen></iframe></body></html>',
                          mimeType: 'text/html')
                      .toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                )),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

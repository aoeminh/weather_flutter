import 'package:flutter/material.dart';

class SmartRefresher extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onRefresh;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  const SmartRefresher({this.refreshIndicatorKey, this.children, this.onRefresh});

  @override
  _SmartRefresherState createState() => _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: widget.refreshIndicatorKey,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return widget.children[index];
        },
        itemCount: widget.children.length,
        shrinkWrap: true,
      ),
      onRefresh: widget.onRefresh,
    );
  }
}

import 'package:flutter/material.dart';

class SmartRefresher extends StatefulWidget {
  final Widget children;
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
      child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: widget.children),
      onRefresh: widget.onRefresh,
    );
  }
}

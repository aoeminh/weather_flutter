import 'package:flutter/material.dart';

class SmartRefresher extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onRefresh;

  const SmartRefresher({Key key, this.children, this.onRefresh}) : super(key: key);
  @override
  _SmartRefresherState createState() => _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(itemBuilder: (context, index){
        return widget.children[index];
      },
      itemCount: widget.children.length,),
      onRefresh: widget.onRefresh,
    );
  }
}

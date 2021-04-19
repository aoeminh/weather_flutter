import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/ui/widgets/empty_animation.dart';
abstract class AnimatedState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  AnimationController controller;
  BehaviorSubject<double> _streamController;

  Widget build(BuildContext context);

  animateTween(
      {double start = 0.0,
      double end = 1.0,
      int duration: 2000,
      Curve curve = Curves.easeInOut}) {
    print('animateTween');
    controller = _getAnimationController(this, duration);
    Animation animation = _getCurvedAnimation(controller, curve);
   _streamController = BehaviorSubject<double>();

    Animation<double> tween = _getTween(start, end, animation);
    var valueListener = () {
      _streamController.sink.add(tween.value);

    };
    tween..addListener(valueListener);
    tween.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _streamController.close();
      }
    });

    controller.forward();
  }


  AnimationController _getAnimationController(
      TickerProviderStateMixin object, int duration) {
    return AnimationController(
        duration: Duration(milliseconds: duration), vsync: object);
  }

  Animation _getCurvedAnimation(AnimationController controller, Curve curve) {
    return CurvedAnimation(parent: controller, curve: curve);
  }

  static Animation<double> _getTween(
      double start, double end, Animation animation) {
    return Tween(begin: start, end: end).animate(animation);
  }


  @override
  void dispose() {
    if (controller != null) {
      controller.dispose();
    }
    _streamController.close();

    super.dispose();
  }
  Stream<double> get animatedStream => _streamController.stream;
}

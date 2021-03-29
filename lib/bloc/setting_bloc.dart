import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/shared/strings.dart';

enum TempEnum { C, F }
enum WindEnum { kmh, ms }
enum PressureEnum { mBar, bar, mmHg }
enum VisibilityEnum { km, mile }
enum TimeEnum { twelve, twentyFour }
enum DateEnum { dd, mm, yy }

extension TempExtenstion on TempEnum {
  String get value {
    switch (this) {
      case TempEnum.C:
        return '$degreeC';
      case TempEnum.F:
        return '$degreeF';
      default:
        return '$degreeC';
    }
  }
}

extension WindExtenstion on WindEnum {
  String get value {
    switch (this) {
      case WindEnum.kmh:
        return kmh;

      case WindEnum.ms:
        return ms;
      default:
        return kmh;
    }
  }
}

extension PressureExtenstion on PressureEnum {
  String get value {
    switch (this) {
      case PressureEnum.mBar:
        return mBar;
      case PressureEnum.bar:
        return bar;
      case PressureEnum.mmHg:
        return mmHg;
      default:
        return mBar;
    }
  }
}

class SettingBloc extends BlocBase {
  @override
  void dispose() {
    // TODO: implement dispose
  }
}

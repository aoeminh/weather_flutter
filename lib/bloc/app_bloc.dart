import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/application_error.dart';

class AppBloc extends BlocBase {

  BehaviorSubject<ApplicationError> _errorBehavior = BehaviorSubject();

  addError(ApplicationError error){
    _errorBehavior.add(error);
  }


  Stream<ApplicationError> get errorStream => _errorBehavior.stream;
  @override
  void dispose() {
    _errorBehavior.close();
  }
}

final appBloc = AppBloc();
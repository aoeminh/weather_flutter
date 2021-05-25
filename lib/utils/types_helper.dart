
class TypesHelper {
  static double toDouble(num? val) {
    try {
      if (val == null){
        return 0;
      }
      if (val is double) {
        return val;
      } else {
        return val.toDouble();
      }
    } catch (exc,stackTrace){
      return 0;
    }
  }
}

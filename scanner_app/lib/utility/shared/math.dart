import 'dart:math';

class Math {

  static double dp(double val, int places){ 
    num mod = pow(10.0, places); 
    return ((val * mod).round().toDouble() / mod); 
  }

}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
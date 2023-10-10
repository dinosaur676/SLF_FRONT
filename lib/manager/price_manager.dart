import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class PriceManager extends ChangeNotifier {

  int marketPrice = 0; // 시세
  int lotCost = 0; // 제비용
  int loadingCost = 0; // 상하차비

  int getTotalPrice(double ho, bool floatRound) {
    if(floatRound) {
      return _getTotalPriceFloat(ho);
    }
    else {
      return _getTotalPriceInt(ho);
    }
  }

  int _getTotalPriceFloat(double ho) {
    return ((((marketPrice + loadingCost) / 0.7) + lotCost) * ho).round();
  }

  int _getTotalPriceInt(double ho) {

    int num = ((((marketPrice + loadingCost) / 0.7) + lotCost) * ho).toInt();

    int temp = num % 10;

    num = num ~/ 10;

    if(temp >= 5) {
      num += 1;
    }

    return num * 10;
  }

  void updateView() {
    notifyListeners();
  }
}
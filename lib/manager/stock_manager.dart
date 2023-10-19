import 'package:flutter/cupertino.dart';

class StockManager extends ChangeNotifier {

  int chickenStock = 0;

  void updateView() {
    notifyListeners();
  }
}
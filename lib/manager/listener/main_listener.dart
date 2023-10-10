import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class MainListener extends ChangeNotifier {

  void updateView() {
    notifyListeners();
  }
}
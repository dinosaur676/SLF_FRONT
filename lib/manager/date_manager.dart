import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateManager extends ChangeNotifier {

  String selectTime = DateFormat("yyyy-MM-dd").format(DateTime.now());

  void updateView() {
    notifyListeners();
  }


}
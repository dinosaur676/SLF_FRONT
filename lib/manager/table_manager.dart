import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/util/chicken_parts.dart';

class TableManager extends ChangeNotifier{

  final Map<String, dynamic> _tableStockMap = Map();

  Map get tableStockMap => _tableStockMap;

  void clear() {
    _tableStockMap.clear();
  }

  int getWorkedPrice() {
    if(tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE] == null || tableStockMap[ChickenParts.WORK_TOTAL] == null) {
      return 0;
    }

    return tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE] + tableStockMap[ChickenParts.WORK_TOTAL];
  }

  int getPartsTotal() {
    int sum = 0;

    for(String parts in ChickenParts.partsList) {
      if(_tableStockMap[parts + ChickenParts.SELL_TOTAL] == null) {
        continue;
      }
      sum += _tableStockMap[parts + ChickenParts.SELL_TOTAL] as int;
    }

    return sum;
  }

  int getProfits() {
    int sellTotal = getPartsTotal();
    int buyTotal = getWorkedPrice();

    return sellTotal - buyTotal;
  }


  void updateView() {
    notifyListeners();
  }
}
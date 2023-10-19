import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/util/chicken_parts.dart';

class TableManager extends ChangeNotifier{

  static const String TOTAL_SELL = "total_sell";
  static const String TOTAL_BUY = "total_buy";
  static const String PROFITS = "profits";

  final Map<String, dynamic> _totalMap = Map();
  final Map<String, dynamic> _priceMap = Map();
  final Map<String, dynamic> _tableStockMap = Map();
  final Map<String, dynamic> _stockMap = Map();


  Map get totalMap => _totalMap;
  Map get priceMap => _priceMap;
  Map get tableStockMap => _tableStockMap;
  Map get stockMap => _stockMap;


  TableManager(){
    _totalMap[TOTAL_SELL] = 0;
    _totalMap[TOTAL_BUY] = 0;
    _totalMap[PROFITS] = 0;
  }

  void clear() {
    _stockMap.clear();
    _totalMap.clear();
    _tableStockMap.clear();
    _priceMap.clear();

    _totalMap[TOTAL_SELL] = 0;
    _totalMap[TOTAL_BUY] = 0;
    _totalMap[PROFITS] = 0;
  }

  int getWorkedPrice() {
    if(tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE] == null || tableStockMap[ChickenParts.WORK_TOTAL] == null) {
      return 0;
    }

    return tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE] + tableStockMap[ChickenParts.WORK_TOTAL];
  }

  void setPriceValue(String key, int value) {
    _priceMap[key] = value;
  }

  void addPriceValue(String key, int value) {
    _priceMap[key] = _priceMap[key]! + value;
  }

  int getPriceValue(String key) {
    return _priceMap[key]!;
  }

  void setStockValue(String key, int value) {
    tableStockMap[key] = value;
  }

  void addStockValue(String key, int value) {
    tableStockMap[key] = tableStockMap[key]! + value;
  }

  int getTableStockValue(String key) {
    if(tableStockMap[key] == null)
      return 0;
    return tableStockMap[key]!;
  }

  void setTotalBuy(int value) {
    _totalMap[TOTAL_BUY] = value;
  }

  int getTotalBuy() {
    return _totalMap[TOTAL_BUY]!;
  }


  int getTotalSell() {
    _totalMap[TOTAL_SELL] = _priceMap.entries.map((e) => e.value).toList().fold(0, (sum, element) => sum + (element as int));
    return _totalMap[TOTAL_SELL]!;
  }

  int getProfits() {
    return (getTotalSell()! - _totalMap[TOTAL_BUY]!).toInt();
  }

  void updateView() {
    notifyListeners();
  }

  void initView() {
    if(_priceMap.length == 11) {
      notifyListeners();
    }
  }
}
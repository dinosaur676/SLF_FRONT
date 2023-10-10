import 'dart:convert';

class RequestDto {
  String name;
  double count;
  int? price;
  int? total;
  String createOn;

  RequestDto({required this.name, required this.count, required this.createOn});


  void setPrice(int value) {
    price = value;
  }

  void setTotal() {
    total = (count! * price!).toInt();
  }

  void clearTotal() {
    total = 0;
  }

  Map getJson(){
    Map toJson = {
      "name": name,
      "count": count,
      "createOn" : createOn,
    };
    if(price != null) {
      toJson["price"] = price;
      toJson["total"] = total;
    }

    return toJson;
  }
}
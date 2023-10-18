class BuyInsertReqDto {
  final String buyName;
  final String buyTime;
  final int size;
  final int count;
  final int price;
  final int total;
  final String createdOn;

  BuyInsertReqDto(this.buyName, this.buyTime, this.size, this.count, this.price, this.total, this.createdOn);

  Map toJson() {
    Map param = {
      "buyName": buyName,
      "buyTime": buyTime,
      "size": size,
      "count": count,
      "price": price,
      "total": total,
      "createdOn": createdOn,
    };

    return param;
  }
}
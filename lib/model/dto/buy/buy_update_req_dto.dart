class BuyUpdateReqDto {
  final int id;
  final String buyName;
  final String buyTime;
  final int size;
  final int count;
  final int price;
  final int total;


  BuyUpdateReqDto(this.id, this.buyName, this.buyTime, this.size, this.count,
      this.price, this.total);

  Map toJson() {
    Map param = {
      "id": id,
      "buyName": buyName,
      "buyTime": buyTime,
      "size": size,
      "count": count,
      "price": price,
      "total": total,
    };

    return param;
  }
}
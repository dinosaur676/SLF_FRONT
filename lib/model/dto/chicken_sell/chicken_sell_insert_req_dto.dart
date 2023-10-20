class ChickenSellInsertReqDto {
  String parts;
  String name;
  double count;
  int price;
  int total;
  String type;
  int prodId;
  String createdOn;


  ChickenSellInsertReqDto(this.parts, this.name, this.count, this.price,
      this.total, this.type, this.prodId, this.createdOn);

  Map toJson() {
    Map param = {
      "parts": parts,
      "name": name,
      "count": count,
      "price": price,
      "total": total,
      "type": type,
      "prodId": prodId,
      "createdOn": createdOn,
    };

    return param;
  }
}
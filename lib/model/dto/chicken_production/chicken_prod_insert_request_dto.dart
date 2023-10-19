class ChickenProdInsertReqDto {
  String parts;
  String name;
  double count;
  int price;
  int total;
  String type;
  String createdOn;

  ChickenProdInsertReqDto(this.parts, this.name, this.count, this.price,
      this.total, this.type, this.createdOn);

  Map toJson() {
    Map param = {
      "parts": parts,
      "name": name,
      "count": count,
      "price": price,
      "total": total,
      "type": type,
      "createdOn": createdOn,
    };

    return param;
  }
}
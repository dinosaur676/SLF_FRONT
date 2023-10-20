class ChickenProdUpdateReqDto {
  int id;
  String name;
  double count;
  int price;
  int total;
  String type;


  ChickenProdUpdateReqDto(
      this.id, this.name, this.count, this.price, this.total, this.type);

  Map toJson() {
    Map param = {
      "id": id,
      "name": name,
      "count": count,
      "price": price,
      "total": total,
      "type": type,
    };

    return param;
  }
}
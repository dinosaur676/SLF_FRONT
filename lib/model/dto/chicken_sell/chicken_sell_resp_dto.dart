class ChickenSellRespDto {
  late final int id;
  late final String parts;
  late final String name;
  late final double count;
  late final int price;
  late final int total;
  late final String type;
  late final int prodId;
  late final String createdOn;


  ChickenSellRespDto(this.id, this.parts, this.name, this.count, this.price,
      this.total, this.type, this.prodId, this.createdOn);

  ChickenSellRespDto.byResult(Map result) {
    id = result["id"];
    parts = result["parts"];
    name = result["name"];
    count = result["count"];
    price = result["price"];
    total = result["total"];
    type = result["type"];
    prodId = result["prodId"];
    createdOn = result["createdOn"];
  }
}
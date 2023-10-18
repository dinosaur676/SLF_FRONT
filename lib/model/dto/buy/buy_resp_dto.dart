class BuyRespDto {
  late final int id;
  late final String name;
  late final String buyTime;
  late final int size;
  late final int count;
  late final int price;
  late final int total;
  late final String createdOn;


  BuyRespDto(this.id, this.name, this.buyTime, this.size, this.count,
      this.price, this.total, this.createdOn);

  BuyRespDto.byResult(Map result) {
    id = result["id"];
    name = result["name"];
    buyTime = result["buyTime"];
    size = result["size"];
    count = result["count"];
    price = result["price"];
    total = result["total"];
    createdOn = result["createdOn"];
  }
}
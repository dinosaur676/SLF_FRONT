class WorkRespDto {
  late final int id;
  late final String name;
  late final String workTime;
  late final int size;
  late final int count;
  late final int price;
  late final String createdOn;

  WorkRespDto(this.id, this.name, this.workTime, this.size, this.count,
      this.price, this.createdOn);

  WorkRespDto.byResult(Map result) {
    id = result["id"];
    name = result["name"];
    workTime = result["workTime"];
    size = result["size"];
    count = result["count"];
    price = result["price"];
    createdOn = result["createdOn"];
  }
}
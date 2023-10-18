class WorkInsertReqDto {
  String name;
  String workTime;
  int size;
  int count;
  int price;
  int total;
  String createdOn;
  int buyId;

  WorkInsertReqDto(this.name, this.workTime, this.size, this.count, this.price,
      this.total, this.createdOn, this.buyId);

  Map toJson() {
    Map param = {
      "name": name,
      "workTime": workTime,
      "size": size,
      "count": count,
      "price": price,
      "total": total,
      "createdOn": createdOn,
      "buyId": buyId
    };

    return param;
  }
}
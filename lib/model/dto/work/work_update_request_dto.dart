class WorkUpdateRequestDto {
  final int id;
  final String name;
  final String workTime;
  final int size;
  final int count;
  final int price;
  final int total;

  WorkUpdateRequestDto(this.id, this.name, this.workTime, this.size, this.count,
      this.price, this.total);

  Map toJson() {
    Map param = {
      "id" : id,
      "name" : name,
      "workTime" : workTime,
      "size": size,
      "count": count,
      "price": price,
      "total": total
    };

    return param;
  }
}
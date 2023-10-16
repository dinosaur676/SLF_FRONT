class PriceSelectRequestDto {
  String name;
  String createdOn;

  PriceSelectRequestDto(this.name, this.createdOn);

  Map toJson() {
    Map param = {
      "name": name,
      "createdOn": createdOn
    };

    return param;
  }
}
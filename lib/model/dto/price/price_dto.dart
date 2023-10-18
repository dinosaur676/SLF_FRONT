class PriceDto {
  late int? id;
  late String name;
  late int marketPrice;
  late int loadingPrice;
  late int lotPrice;
  late String createdOn;

  PriceDto(this.name, this.marketPrice, this.loadingPrice, this.lotPrice,
      this.createdOn);

  PriceDto.byResult(Map result) {
    id = result["id"];
    name = result["name"];
    marketPrice = result["marketPrice"];
    loadingPrice = result["loadingPrice"];
    lotPrice = result["lotPrice"];
    createdOn = result["createdOn"];
  }

  Map toJson() {
    Map param = {
      "name": name,
      "marketPrice": marketPrice,
      "loadingPrice": loadingPrice,
      "lotPrice": lotPrice,
      "createdOn": createdOn
    };

    return param;
  }
}
class PriceDto {
  String name;
  int marketPrice;
  int loadingPrice;
  int lotPrice;
  String createdOn;

  PriceDto(this.name, this.marketPrice, this.loadingPrice, this.lotPrice,
      this.createdOn);

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
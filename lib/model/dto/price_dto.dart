class PriceDto {
  int marketPrice;
  int loadingPrice;
  int lotPrice;
  String createOn;

  PriceDto(this.marketPrice, this.loadingPrice, this.lotPrice, this.createOn);

  Map getJson() {
    Map toJson = {
      "marketPrice": marketPrice,
      "loadingPrice": loadingPrice,
      "lotPrice": lotPrice,
      "createOn": createOn
    };

    return toJson;
  }
}
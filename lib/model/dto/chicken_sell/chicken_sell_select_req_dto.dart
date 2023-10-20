class ChickenSellSelectReqDto {
  final String parts;
  final String createdOn;

  ChickenSellSelectReqDto(this.parts, this.createdOn);

  Map toJson() {
    Map param = {
      "parts": parts,
      "createdOn": createdOn
    };

    return param;
  }
}
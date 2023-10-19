class ChickenProdSelectRequestDto {
  String parts;
  String createdOn;

  ChickenProdSelectRequestDto(this.parts, this.createdOn);

  Map toJson() {
    Map param = {
      "parts" : parts,
      "createdOn": createdOn
    };

    return param;
  }
}
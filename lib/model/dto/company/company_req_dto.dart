class CompanyUpdateReqDto {
  String before;
  String after;

  CompanyUpdateReqDto(this.before, this.after);

  Map toJson() {
    Map param = {
      "before": before,
      "after": after
    };

    return param;
  }
}
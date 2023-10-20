class DateUpdateReqDto {
  String before;
  String after;

  DateUpdateReqDto(this.before, this.after);

  Map toJson() {
    Map param = {
      "before": before,
      "after": after
    };

    return param;
  }
}
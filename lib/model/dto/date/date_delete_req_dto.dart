class DateDeleteReqDto {
  String createdOn;


  DateDeleteReqDto(this.createdOn);

  Map toJson() {
    Map param = {
      "createdOn": createdOn,
    };

    return param;
  }
}
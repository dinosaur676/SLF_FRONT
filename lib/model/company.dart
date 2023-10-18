class Company {
  late final int id;
  late final String name;

  Company(this.id, this.name);

  Company.byResult(Map result) {
    id = result["id"];
    name = result["name"];
  }

}

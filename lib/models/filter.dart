class CatFilter {
  int minAge;
  int maxAge;
  String gender;
  String size;
  String color;
  String location;

  CatFilter({
    this.minAge = 0,
    this.maxAge = 20,
    this.gender = '',
    this.size = '',
    this.color = '',
    this.location = '',
  });

  bool isDefault() {
    return minAge == 0 &&
        maxAge == 20 &&
        gender.isEmpty &&
        size.isEmpty &&
        color.isEmpty &&
        location.isEmpty;
  }
}
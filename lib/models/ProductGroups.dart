class ProductGroups{
  int id;
  String name;
  List<String> images = List<String>();

  ProductGroups.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    List ls = json['images'];
    ls.forEach((element) {
      this.images.add(element);
    });
    name = json['name'];
  }

}
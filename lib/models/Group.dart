class Group{
  int id;
  String name;
  String image;


  Group.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
  }

}
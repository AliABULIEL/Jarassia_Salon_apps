

class Service{
  int id;
  String name;
  String desc;
  String image;
  int minutes;
  int clientsCount;

  Service.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    desc = "explain Service ";
    if (json['description'] != null) {
      desc = json['description'];
    }

    if (json['minutes'] != null) {
      minutes = json['minutes'];
    }

    if (json['clients_count'] != null) {
      clientsCount = json['clients_count'];
    }
  }

}
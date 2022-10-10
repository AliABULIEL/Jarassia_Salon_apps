



class User{
  int id;
  String name;
  String lastName;
  String phone;
  String image;
  int ordersCount;
  bool suspended;
  Role role = Role.client;

    User.fromJson(Map<dynamic, dynamic> json) {
      id = json['id'];
      name = json['first_name'];
      if (name == null) {
        name = json['name'];
      }
      lastName = json['last_name'];
      image = json['image'] ?? "";
      ordersCount = json['orders_count'] ?? 0;
      suspended = json['suspended'] ?? false;

      String roleString = json['role'];
      if (roleString != null) {
        if (roleString == "Admin" || roleString == "Business admin") {
          role = Role.admin;
        }else if ( roleString == "Business employee"){
          role = Role.employee;
        }else{
          role = Role.client;
        }
      }
      phone = json['phone'];
    }
  }

enum Role {
  admin,
  employee,
  client
}
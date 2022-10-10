
class Employee {
  int id;
  String first_name;
  String last_name;
  String phone;
  String role;
  String image;

  Employee.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    first_name = json['first_name'];
    last_name = json['last_name'];
    phone = json['phone'];
    role = json['role'];
    image = json['image'] ?? "";
  }
}
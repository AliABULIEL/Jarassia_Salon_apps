


import 'package:intl/intl.dart';

class Product{
  int id;
  String name;
  String description;
  String image;
  int price;
  List<String> images = List<String>();

  Product.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    image = json['image'];
    List ls = json['images'];
    ls.forEach((element) {
      this.images.add(element);
    });
    name = json['name'];
    description = json['description'];
    price = json['price'];

  }

}

class Cart{
  int id;
  String name;
  String description;
  String image;
  int price;
  int quantity;

  Cart.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    description = json['description'];

  }
}

class UserOrder{
  int id;
  String status;
  String createdAt;
  String stringDate = "";
  int itemsCount;
  int price;
  List<Cart> items = List<Cart>();

  UserOrder.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    itemsCount = json['items_count'];

    if (createdAt != null) {
     var  tempDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(createdAt);
     stringDate = "${tempDate.year}-${tempDate.month}-${tempDate.day}";
    }
    List ls = json['items'];
    ls.forEach((element) {
      Cart cart = Cart.fromJson(element);
      items.add(cart);
    });

  }
}

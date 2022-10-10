

import 'package:salon_app/models/Day.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/Service.dart';
import 'package:cool_alert/cool_alert.dart';

import 'Order.dart';
import 'User.dart';


class OrderResult {

  List<Service> services = List<Service>();
  Employee employee;
  String date;
  String day;
  Time time;
  Order order ;
  User user ;

  OrderResult.fromJson(Map<dynamic, dynamic> json) {
    List ml = json['services'];
    if (ml != null) {
      ml.forEach((element) {
        Service service = Service.fromJson(element);
        services.add(service);
      });
    }

    Map wml = json['workshop'];
    if (wml != null) {
      print("get service from workshiop");
      Service service = Service.fromJson(wml);
      services.add(service);
    }

    employee = Employee.fromJson(json['employee']);
    date = json['date'];
    day = json['day'];


    time = Time.fromJson(json['time']);
    if(json["order"] != null) {
      order = Order.fromJson(json["order"]);
    }

    if(json["client"] != null) {
      user = User.fromJson(json["client"]);
    }

  }

  getServiceIds(){
    var ids = [];
    this.services.forEach((element) {
      ids.add(element.id);
    });
    return ids;
  }
}
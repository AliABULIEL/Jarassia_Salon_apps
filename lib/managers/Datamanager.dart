


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:salon_app/models/Business.dart';
import 'package:salon_app/models/Day.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/Notification.dart';
import 'package:salon_app/models/Order.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/models/Product.dart';
import 'package:salon_app/models/Service.dart';
import 'package:salon_app/models/Story.dart';
import 'package:salon_app/models/User.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

String Buissness_id="1";

final domainName = "http://moad.jarasia.co";

class DataManager{

  static var shared = DataManager();
  User user;
  String token;
  List<Story> stories = new List<Story>();
  List<Service> services = new List<Service>();
  List<NotificationM> notifications = new List<NotificationM>();
  List<Order> orders = new List<Order>();
  List<Order> archivedOrders = new List<Order>();
  List<Order> waitApproveOrders = new List<Order>();
  List<Product> products = new List<Product>();
  List<UserOrder> myOrders = new List<UserOrder>();
  TabController tabController;

  Business business;
  bool showNotifications = false;

  final baseUrl = "http://moad.jarasia.co/api/";

  String lan;

  String fontName(){
    if (lan == "he") {
      return "Heebo";
    }
    return "Cairo";
  }

  Future<Map> login(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse( baseUrl + "login"),
        body: body,
        headers: {"Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("request login finish");
    print(map);

    return map;

  }
  Future deleteUser(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);
    print("delteUser!!!");
    var body = jsonEncode(result);
    final response = await http.delete(
        Uri.parse( baseUrl + "user"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("deleteuserFinish");
    print(map);

  }


  Future<Map> register(Map ma) async {

    var body = jsonEncode(ma);
    final response = await http.post(
        Uri.parse( baseUrl + "register"),
        body: body,
        headers: {"Content-Type": "application/json",
                   "Accept": "application/json",
                   "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("request register finish");
    print(map);
    return map;


  }

  Future<Map> verifyCode(Map ma) async {

    var body = jsonEncode(ma);
    final response = await http.post(
        Uri.parse( baseUrl + "verify"),
        body: body,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print(map);
    print("verify code finish");
    return map;



  }

  Future<User> fetchUser(String token) async {

    print(7777777755);

    final response = await http.get(
        Uri.parse( baseUrl + "user"),
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type" : "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("User finish");
    print(map);
    print(77777777);

    User us = User.fromJson(map);
    this.user = us;
    if (us == null || us.name == null) {
      this.user = null;
      return null;
    }
    return us;
  }

  Future<Business> fetchHome(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);
    print(body);
    final response = await http.post(
        Uri.parse( baseUrl + "home"),
        body: body,
        headers: {"Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    print("home finish");
    Map map = json.decode(response.body);
    print("home finish");
    print(map);

    if (map["stories"] != null){
      List mStories = map["stories"];
      stories = [];
      mStories.forEach((element) {
        Story story = Story.fromJson(element);
        stories.add(story);
      });
    }

    print("home finish 2");

    if (map["business"] != null) {
      print("home finish 3");

      Map m = map["business"];
      Business bs = Business.fromJson(m);
      business = bs;
      return bs;
    } else {
      print("home finish 4");

      return null;
    }
  }

  Future<List<Service>> fetchService(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse(baseUrl + "services"),
        body: body,
        headers: {"Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("home fetch Service");
    print(map);

    services = [];
    if (map["services"] != null) {
      List mL = map["services"];
      mL.forEach((element) {
        Service service = Service.fromJson(element);
        services.add(service);

      });
      return services;
    } else {
      return null;
    }
  }

  Future<List<Employee>> submitService(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-order/submit-services"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("employees fetch Finish");
    print(map);
    List <Employee> employees = new List <Employee>();

    if (map["employees"] != null) {
      List mL = map["employees"];
      mL.forEach((element) {
        Employee employee = Employee.fromJson(element);
        employees.add(employee);
      });
      return employees;
    } else {
      return null;
    }
  }
  Future<List<Employee>> getWorkshopEmpolyee(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/employees"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("employees fetch Finish");
    print(token);
    print(map);
    List <Employee> employees = new List <Employee>();

    if (map["employees"] != null) {
      List mL = map["employees"];
      mL.forEach((element) {
        Employee employee = Employee.fromJson(element);
        employees.add(employee);
      });
      return employees;
    } else {
      return null;
    }
  }

  Future<List<Service>> getWorkshopService(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);

    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/submit-employee"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("home fetch Service");
    print(map);
    print(map);

    services = [];
    if (map["workshops"] != null) {
      List mL = map["workshops"];
      mL.forEach((element) {
        Service service = Service.fromJson(element);
        services.add(service);

      });
      return services;
    } else {
      return null;
    }
  }

  Future<List<Day>> getWorkshopDays(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/submit-workshop"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("submit Employee  Finish");
    print(map);

    List <Day> days = new List <Day>();

    if (map["days"] != null) {
      List mL = map["days"];
      mL.forEach((element) {
        Day day = Day.fromJson(element);
        days.add(day);
      });
      return days;
    } else {
      return null;
    }
  }


  Future<List<Time>> getWorkshopTimes(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print(body);
    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/submit-day"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);

    print("submit Day  Finish");
    print(map);

    List <Time> times = new List <Time>();

    if (map["times"] != null) {
      List mL = map["times"];
      mL.forEach((element) {
        Time time = Time.fromJson(element);
        times.add(time);
      });
      return times;
    } else {
      return null;
    }
  }


  Future<OrderResult> getWorkshopSubmitTimes(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/submit-time"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("submit workshop Time  Finish");
    print(map);
    if (map.length == 1) {
      return null;
    }
    OrderResult orderResult = OrderResult.fromJson(map);

    return orderResult;
  }

  Future<OrderResult> submitWorkshopOrder(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);

    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-workshop-order/submit-order"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("submit workshop Order  Finish");
    print(map);
    if (map.length == 1) {
      return null;
    }
    OrderResult orderResult = OrderResult.fromJson(map);
    return orderResult;

  }

  Future<OrderResult> editWorkshopOrder(id,Map ma) async {
    print("start edit workshop2 *******");
    print(ma);
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "workshop-orders/${id}/update"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("update workshop Order by id");
    print(map);

    OrderResult orderResult = OrderResult.fromJson(map);

    return orderResult;

  }


  Future submitEmployee(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-order/submit-employee"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("submit Employee  Finish");
    print(map);

    List <Day> days = new List <Day>();

    if (map["days"] != null) {
      List mL = map["days"];
      mL.forEach((element) {
        Day day = Day.fromJson(element);
        days.add(day);
      });
      return days;
    } else {
      return null;
    }

  }

  Future<List<Time>> submitDay(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-order/submit-day"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language":lan}
    );

    Map map = json.decode(response.body);
    print("submit Day  Finish");
    print(map);

    List <Time> times = new List <Time>();

    if (map["times"] != null) {
      List mL = map["times"];
      mL.forEach((element) {
        Time time = Time.fromJson(element);
        times.add(time);
      });
      return times;
    } else {
      return [];
    }
  }

  Future submitTime(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-order/submit-time"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("submit Time  Finish");
    print(map);
    if (map.length == 1) {
      return null;
    }
    OrderResult orderResult = OrderResult.fromJson(map);

    return orderResult;

  }

  Future<OrderResult> submitOrder(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);

    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "create-order/submit-order"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("submit Order  Finish");
    print(map);
    if (map.length == 1) {
      return null;
    }
    print(map);
    OrderResult orderResult = OrderResult.fromJson(map);
    return orderResult;

  }

  Future sendMessage(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "contact-messages"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("sendMessage Finish");
    print(map);

  }

  Future<List<NotificationM>> fetchNotification(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "notifications"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    print(token);
    Map map = json.decode(response.body);

    print("fetch notifications");
    print(map);

    showNotifications = map["show_notifications"] ?? false;

    notifications = [];
    List mL = map["notifications"];

    mL.forEach((element) {
      NotificationM notification = NotificationM.fromJson(element);
      notifications.add(notification);

    });

    return notifications;

  }

  Future<List<Order>> fetchActiveOrders(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "orders/active"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    print(token);
    Map map = json.decode(response.body);

    print("fetch Active Orders");
    print("token-${token}");

    print(map);

    orders = [];
    List mL = map["orders"];
    if (mL != null) {
      mL.forEach((element) {
        Order order = Order.fromJson(element);
        orders.add(order);
      });
    }
    orders.sort((a,b) => a.startingDate.compareTo(b.startingDate));
    print(1);
    return orders;
  }

  Future<List<Order>> fetchOldOrders(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "orders/archived"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    print(token);
    Map map = json.decode(response.body);

    print("fetch old Active Orders");
    print(map);

    archivedOrders = [];
    List mL = map["orders"];
    mL.forEach((element) {
      Order order = Order.fromJson(element);
      archivedOrders.add(order);
    });
    archivedOrders.sort((a,b) => a.startingDate.compareTo(b.startingDate));

    return archivedOrders;
  }

  Future<List<Order>> fetchWaitOrders(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "orders/waiting-approval"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    print(token);
    Map map = json.decode(response.body);

    print("fetch waiting approve Orders");
    print(map);

    waitApproveOrders = [];
    List mL = map["orders"];
    mL.forEach((element) {
      Order order = Order.fromJson(element);
      waitApproveOrders.add(order);
    });
    waitApproveOrders.sort((a,b) => a.startingDate.compareTo(b.startingDate));
    return waitApproveOrders;
  }

  Future<Story> uploadStory(imageFile,Map map) async {

    Map<String,String> msx =  Map<String,String>();
    map.forEach((key, value) {
      if (key != "file"){
        msx[key] = value;
      }
    });

    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    print(imageFile.path);
    final mimeType = lookupMimeType(imageFile.path); // 'image/jpeg'
    print(mimeType);
    // get file length
    var length = await imageFile.length();

    var arrayString = mimeType.split("/");
    MediaType mediaType;

    if (arrayString.contains("image") && arrayString.length == 2){
      mediaType = new MediaType(arrayString[0],arrayString[1]);
    }


    var uri = Uri.parse(baseUrl + "stories");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path),contentType : mediaType);
    // add file to multipart
    request.headers.addAll({
      "Authorization" : "Bearer ${token}",
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Accept-Language": lan});
    request.files.add(multipartFile);
    request.fields.addAll(msx);

    // send
    var response = await request.send();
    print(response.statusCode);
    // listen for response

    print("storuesssss....****");
    response.stream.transform(utf8.decoder).listen((value) {
      Map resultMap = json.decode(value);
      print(resultMap);
      Story story = Story.fromJson(resultMap["story"]);

      if (story != null) {
        DataManager.shared.stories.add(story);
        return story;
      }else{
        return null;
      }


    });
  }

  Future editUser(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);
    print("editUser");
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "user"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("editUser Finish");
    print(map);

  }

  Future editBusiness(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    print(result);
    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse( baseUrl + "business/${Buissness_id}/update"),
        body: body,
        headers: {
          "Authorization" : "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("editBusiness Finish");
    print(map);

    print(map);

  }

  uploadImage(imageFile,Map map,Function(String) callBack) async {

    Map<String,String> msx =  Map<String,String>();
    map.forEach((key, value) {
      if (key != "file"){
        msx[key] = value;
      }
    });

    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    print(imageFile.path);
    final mimeType = lookupMimeType(imageFile.path); // 'image/jpeg'
    print(mimeType);
    // get file length
    var length = await imageFile.length();

    var arrayString = mimeType.split("/");
    MediaType mediaType;

    if (arrayString.contains("image") && arrayString.length == 2){
      mediaType = new MediaType(arrayString[0],arrayString[1]);
    }


    var uri = Uri.parse(baseUrl + "upload");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path),contentType : mediaType);
    // add file to multipart
    request.headers.addAll({
      "Authorization" : "Bearer ${token}",
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Accept-Language": lan});
    request.files.add(multipartFile);
    request.fields.addAll(msx);

    // send
    var response = await request.send();
    print(response.statusCode);
    // listen for response

    print("uplaod image ....****");
    print(1);

    response.stream.transform(utf8.decoder).listen((value) {
      print(2);
      Map resultMap = json.decode(value);
      print(resultMap);

      var imageUrl = resultMap["image"];
      if (imageUrl != null) {
        print(imageUrl);
        callBack(imageUrl);
      }else{
        callBack(null);
      }

    });
  }

  Future<OrderResult> getOrder(id) async {

    var body = jsonEncode({"business_id": Buissness_id});
    final response = await http.post(
        Uri.parse( baseUrl + "orders/${id}"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("get Order by id");
    print(map);

    OrderResult orderResult = OrderResult.fromJson(map);

    return orderResult;

  }

  Future<OrderResult> editOrder(id,Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    final response = await http.post(
        Uri.parse( baseUrl + "orders/${id}/update"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("update Order by id");
    print(map);

    OrderResult orderResult = OrderResult.fromJson(map);

    return orderResult;

  }

  Future<bool> cancelOrder(id,Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("cancelOrder");
    print(result);
    final response = await http.post(
        Uri.parse( baseUrl + "orders/${id}/cancel"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("cancel Order  by id");
    print(map);
    return true;

  }

  Future<bool> approveOrder(id,Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse( baseUrl + "orders/${id}/approve"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("approve Order  by id");
    print(map);
    return true;

  }

  Future<bool> readAllNoti() async {
    Map ma = {"business_id": Buissness_id};
    var body = jsonEncode(ma);
    final response = await http.post(
        Uri.parse( baseUrl + "notifications/read-all"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    showNotifications = false;
    Map map = json.decode(response.body);
    print("read All Noti");
    print(map);
    return true;

  }

  Future<bool> viewStory(id) async {
    Map ma = {"business_id": Buissness_id};
    var body = jsonEncode(ma);
    final response = await http.post(
        Uri.parse( baseUrl + "stories/${id}/view"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );
    Map map = json.decode(response.body);
    print(map);
    return true;

  }


  Future<bool> deleteStory(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("deleteStory");
    print(result);
    final response = await http.post(
        Uri.parse( baseUrl + "stories/delete"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("delete Story Order  by id");
    print(map);
    return true;

  }


  Future<bool> updateSuspended(Map ma,String key) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("suspended");
    print(result);
    var url =   baseUrl + "business/${Buissness_id}/clients/${key}";
    print(url);
    final response = await http.post(
        Uri.parse( url),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("res suspunded");
    print(map);
    return true;

  }

  Future<List<User>> getClients(String type) async {

    var body = jsonEncode({"business_id": Buissness_id,"order_by":type});
    final response = await http.post(
        Uri.parse( baseUrl + "business/${Buissness_id}/clients"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("get clients d");
    print(map);

    List<User> clients = new List<User>();

    List mL = map["users"];
    mL.forEach((element) {
      User user = User.fromJson(element);
      clients.add(user);
    });

    return clients;

  }

  Future<List<Product>> getProducts() async {

    var body = jsonEncode({"business_id": Buissness_id});
    final response = await http.post(
        Uri.parse( baseUrl + "products"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("get produts d");
    print(token);
    print( baseUrl + "prodcuts");
    print(map);

    List<Product> products = new List<Product>();

    List mL = map["products"];
    mL.forEach((element) {
      Product prodcut = Product.fromJson(element);
      products.add(prodcut);
    });
    this.products = products;
    return products;

  }

  Future<List<Product>> getMyProducts() async {

    var body = jsonEncode({"business_id": Buissness_id});
    final response = await http.post(
        Uri.parse( baseUrl + "products"),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("get produts d");
    print(token);
    print( baseUrl + "prodcuts");
    print(map);

    List<Product> products = new List<Product>();

    List mL = map["products"];
    mL.forEach((element) {
      Product prodcut = Product.fromJson(element);
      products.add(prodcut);
    });
    this.products = products;
    return products;

  }

  Future<bool> addToCart(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("add to cart");
    print(result);
    var url =   baseUrl + "cart/add";
    print(url);
    final response = await http.post(
        Uri.parse( url),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );
    print(token);
    Map map = json.decode(response.body);
    print("res add to cart");
    print(map);
    return true;

  }

  Future<bool> removeFromCart(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("remove from cart");
    print(result);
    var url =   baseUrl + "cart/remove";
    print(url);
    final response = await http.post(
        Uri.parse( url ),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("res remove from");
    print(map);
    return true;

  }

  Future<bool> submitCart(Map ma) async {
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print("submit cart");
    print(result);
    var url =   baseUrl + "cart/submit";
    print(url);
    final response = await http.post(
        Uri.parse( url),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("res submit cart");
    print(map);
    return true;

  }


  Future<List<Cart>> getMyCart() async {

    var body = jsonEncode({"business_id": Buissness_id});
    final response = await http.post(
        Uri.parse( baseUrl + "cart" ),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("get produts d");
    print(token);
    print( baseUrl + "prodcuts");
    print(map);

    List<Cart> cartList = new List<Cart>();

    List mL = map["items"];
    mL.forEach((element) {
      Cart cart = Cart.fromJson(element);
      cartList.add(cart);
    });

    return cartList;

  }


  Future<List<UserOrder>> getMyOrders() async {

    var body = jsonEncode({"business_id": Buissness_id});
    final response = await http.post(
        Uri.parse( baseUrl + "cart/orders" ),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    List<dynamic> map = json.decode(response.body);
    print("get my orders d");
    print(map);

    List<UserOrder> myOrders = new List<UserOrder>();

    List mL = map;
    mL.forEach((element) {
      UserOrder userOrder = UserOrder.fromJson(element);
      myOrders.add(userOrder);
    });
    DataManager.shared.myOrders = myOrders;
    return myOrders;

  }



  Future<bool> addWaitngToList(Map ma) async {

    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);
    print(baseUrl + "waiting-list");
    print(ma);

    final response = await http.post(
        Uri.parse( baseUrl + "waiting-list" ),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("add waiting list finish");
    print(map);
    return true;

  }

  Future<bool> addFeedback(Map ma) async {
    print(ma);
    var result = {}..addAll({"business_id": Buissness_id})..addAll(ma);
    var body = jsonEncode(result);

    final response = await http.post(
        Uri.parse( baseUrl + "feedbacks" ),
        body: body,
        headers: {
          "Authorization": "Bearer ${token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Language": lan}
    );

    Map map = json.decode(response.body);
    print("add Feedback finish");
    print(map);
    return true;

  }


}
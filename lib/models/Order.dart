

import 'package:intl/intl.dart';
import 'package:salon_app/managers/Datamanager.dart';

class Order {
    int id;
    String email;
    String name;
    String clinetName;
    int total;
    int minutes;
    String startingAt;
    String startingDate;
    String startingTime;
    bool approved;
    String userImage;
    DateTime tempDate;
    bool canEdit;
    bool canApprove;
    bool canCancel;
    String notes;
    int clientsCount;


    Order.fromJson(Map<dynamic, dynamic> json) {
      id = json['id'];
      email = json['email'];
      name = json['name'];
      clinetName = json['clinet_name'];
      notes = json['notes'] ?? "";
      total = json['total'];
      minutes = json['minutes'];
      startingAt = json['starting_at'];
      startingDate = json['start_date'];
      startingTime = json['start_time'];
      canEdit = json['can_edit'];
      canApprove = json['can_approve'];
      canCancel = json['can_cancel'];
      clientsCount = json['clients_count'];

      if (startingAt != null) {
        tempDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startingAt);
      }
      approved = json['approved'];
      if (json['user_image'] != null) {
        userImage = domainName + "/images/small/" + json['user_image'];
      }else{
        userImage  = "";
      }

    }

}
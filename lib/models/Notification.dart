

class NotificationM{
  String id;
  String title;
  String content;
  String link;
  int orderId;
  String type;

  NotificationM.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    orderId = json['order_id'];
    link = json['link'];
    type = json['type'];

  }

}
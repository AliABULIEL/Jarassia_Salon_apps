


class Business {

  int id;
  String name;
  String intro;
  String about;
  String address;
  String working_days;
  String logo;
  String cover;
  String pColor;
  String latitude;
  String longitude;
  String addressText;
  String addressImage;
  List<Social> social_links =  List<Social>();

  int order_min_days;
  bool creditCardPayment;
  bool cashPayment;

  Business.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    intro = json['intro'];
    about = json['about'];
    address = json['address'];
    addressText = json['address_text'];
    addressImage = json['address_image'];
    working_days = json['working_days'];
    logo = json['logo'] ?? "";
    cover = json['cover'] ?? "";
    latitude = json['latitude'];// ?? "32.724295";
    longitude = json['longitude'];// ?? "35.353369";
    pColor = json['color'];
    creditCardPayment =  json['credit_card_payment'] == null ? false : json['credit_card_payment'];
    cashPayment =  json['cash_payment'] == null ? false : json['cash_payment'];

    List m = json['social_links'];
    print(m);
    m.forEach((element) {
      Social s = Social.fromJson(element);
      this.social_links.add(s);
    });
    if (latitude != null) {
      Social waze = Social("waze","");
      this.social_links.add(waze);
    }

    order_min_days = json['order_min_days'];

  }

  getSocialLink(type){
    var link = "";
    this.social_links.forEach((element) {
      if (element.type == type) {
        link = element.link;
      }
    });
    return link;
  }


}

class Social {
  String type;
  String link;

  Social(String type,String link){
    this.type = type;
    this.link = link;
  }

  Social.fromJson(Map<dynamic, dynamic> json) {
    type = json['type'];
    link = json['link'];
  }
}
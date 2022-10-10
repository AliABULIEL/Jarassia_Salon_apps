

class Day{

  String date;
  String name;
  bool disabled;
  int clientsCount;
  int clientsRegistred;


  Day.fromJson(Map<dynamic, dynamic> json) {
    date = json['date'];
    name = json['name'];
    disabled = json['disabled'];

    if (json['clients_count'] != null) {
      clientsCount = json['clients_count'];
    }
    if (json['clients_registred'] != null) {
      clientsRegistred = json['clients_registred'];
    }
  }
}

class Time{

  String start;
  String end;
  bool disabled;
  int clientsCount;
  int clientsRegistred;

  Time.fromJson(Map<dynamic, dynamic> json) {
    start = json['start'];
    end = json['end'];
    disabled = json['disabled'];

    if (json['clients_count'] != null) {
      clientsCount = json['clients_count'];
    }
    if (json['clients_registred'] != null) {
      clientsRegistred = json['clients_registred'];
    }


  }
}
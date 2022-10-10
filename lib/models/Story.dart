

import 'package:salon_app/managers/Datamanager.dart';

import 'User.dart';

class Story {
  int id;
  String image;
  int views;
  String createdAt;
  User user;


  Story.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    image = domainName + "/images/large/" + json['image'];
    views = json['views'];
    createdAt = json['created_at'];
    user = User.fromJson(json['user']);

  }
}



/*
* {id: 1, user_id: 1, image: PrFmXAzer0n46Ik7lQZWd1K3v6AUZSy2PGn2GzC3.png,
*  views: 0, created_at: 2021-01-22T20:08:01.000000Z,
*  updated_at: 2021-01-22T20:11:55.000000Z, laravel_through_key: 1}
* */
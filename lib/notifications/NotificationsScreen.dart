import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/orderSteps/OrderFinishScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Menu.dart';
import 'package:salon_app/models/Notification.dart';
import 'package:salon_app/models/Order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/edits/WebScreen.dart';
import '../home/orderSteps/SelectOrderTypeScreen.dart';


class NotificationsScreen extends StatefulWidget{

  Function callback;
  NotificationsScreen({this.callback});
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  bool _darkModeEnabled = false;

  List<NotificationM> notifications = DataManager.shared.notifications;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async{
    if(DataManager.shared.showNotifications == true) {
      DataManager.shared.showNotifications = false;
      DataManager.shared.readAllNoti();
      widget.callback();
    }
    if (DataManager.shared.user != null) {
      var data = await DataManager.shared.fetchNotification({"business_id": Buissness_id});
      setState(() {
        this.notifications = data;
      });
    }

  }
  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var size = MediaQuery.of(context).size;

    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["notifications"],style: TextStyle(fontWeight: FontWeight.bold,color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(child: InkWell(
              onTap: (){
                MenuView(context: context).presentMenu();
              },
              child: Container(
                width: 40,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.menu,
                      color: _darkModeEnabled ? Colors.white : Colors
                          .black,),
                  ],
                ),
              ),
            )
            ),
            SizedBox(width: 10,),

          ],
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      body: Container(
        width: size.width,
        child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: notifications.length,
        itemBuilder: (context, idx) {
          return _itemView(notifications[idx]);
        }
        ),
      ),
    );
  }

  _itemView(NotificationM noti){
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: (){
          print("noti.link");
          print(noti.link);
           if (noti.link != null) {
            print(noti.link);
            showWebView(noti.link);
          }else if (noti.type != null && noti.type == "AvailableDate") {
                this.goCreateOrder();
           }else if (noti.orderId == null) {
             return;
           } else{
            Order order = Order.fromJson({"id":noti.orderId});
            Navigator.of(context).push(_createRoute(OrderFinishScreen(isEdit: false,order: order,)));
          }
        },
        child: Container(
          width: size.width,
          decoration: BoxDecoration(
              color:_darkModeEnabled ? Colors.black : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 10,),
                Text(noti.title,style: TextStyle(color: Colors.grey,fontSize: 15,fontFamily: DataManager.shared.fontName())),
                SizedBox(height: 5,),
                Text(noti.content,textAlign: TextAlign.right,style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 15,fontWeight: FontWeight.w600,fontFamily: DataManager.shared.fontName())),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showWebView(String url){
    Navigator.of(context).push(_createRoute(WebScreen(url: url,)));
  }


  goCreateOrder(){
    Navigator.of(context).push(_createRoute(SelectOrderTypeScreen()));
  }
  //(type == "AvailableDate")

  Route _createRoute(screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
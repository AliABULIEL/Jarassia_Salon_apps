import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:salon_app/home/orderSteps/SelectOrderTypeScreen.dart';
// import 'package:plain_notification_token/plain_notification_token.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/shop/MarketScreen.dart';
import 'package:salon_app/splash/SplashScreen.dart';
import 'Extensions.dart';
import 'conections/ConnectScreen.dart';
import 'home/HomeScreen.dart';
import 'home/edits/WebScreen.dart';
import 'models/DemoLocalizations.dart';
import 'models/Order.dart';
import 'notifications/NotificationsScreen.dart';
import 'order/OrdersScreen.dart';
import 'package:device_info/device_info.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(

      debugShowCheckedModeBanner: false,
        localizationsDelegates: [const DemoLocalizationsDelegate()],
        supportedLocales: [const Locale('he', ''), const Locale('ar', ''),Locale('en', '')],
        theme: ThemeData(
        fontFamily: DataManager.shared.fontName(),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: SplashScreen(),
    );
  }
}

class TabBarScreen extends StatefulWidget{
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> with SingleTickerProviderStateMixin {

  Future<String> permissionStatusFuture;

  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  var noInternet = false;
  var isPresentDialog = false;
  var isPresentRating = false;
  double ratingCount = 0;
  OrderResult orderForFeedback;
  final TextEditingController commitController = TextEditingController();

  ConnectivityResult _connectivityResult;
  StreamSubscription _connectivitySubscription;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    DataManager.shared.tabController = new TabController(initialIndex: 4,vsync: this, length: 5);
    checkNoti();
    _checkConnectivityState();
    sendDeviceInfo();
    observeNotification();



  }

  sendDeviceInfo() async {
    if (DataManager.shared.user == null) {
      return;
    }
    Map map;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      map = {"device":iosInfo.utsname.machine};
    }else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      map = {"device":androidInfo.device};
    }
    DataManager.shared.editUser(map);
    print(map);
    print("device info");
  }

  checkNoti() async {
    if (DataManager.shared.user != null) {
      var d = await DataManager.shared.fetchNotification({"":""});
      if(mounted) {
        setState(() {
          DataManager.shared.showNotifications = DataManager.shared.showNotifications;
        });
      }
    }
  }



  void observeNotification(){

    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print("token-res");
      print(token);
      if (DataManager.shared.user != null) {
        DataManager.shared.editUser({"fcm_token": token});
      }
    });

    // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
      print('getInitialMessage data: ${message.data}');
      naviagtionByPush(message.data);

    });

    // onMessage: When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage data: ${message.data}");
          if(mounted) {
            setState(() {
              DataManager.shared.showNotifications = true;
            });
          }
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');

      naviagtionByPush(message.data);
    });

    }

  naviagtionByPush(Map<String, dynamic> message) async{
    if (isPresentDialog == true) {
      return;
    }
    isPresentDialog = true;
    Future.delayed(const Duration(seconds: 3), ()
    {
      this.isPresentDialog = false;
    });

    var data = message;
    String type = message["type"];
    String orderId = data["order_id"];
    String link = data["link"];
    if(orderId != null && type == null) {
      OrderResult order = await DataManager.shared.getOrder(orderId);
      this.orderForFeedback = order;
      this.setState(() {
        this.isPresentRating = true;
      });
    }else if (type == "AvailableDate") {
      goCreateOrder();
    } else if (link != null) {
      showWebView(link);
    }else{

      Future.delayed(const Duration(seconds: 1), ()
      {
        DataManager.shared.tabController.animateTo(0);
      });

    }
  }


  void iOS_Permission() async{

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    //
    // _firebaseMessaging.requestNotificationPermissions(
    //     IosNotificationSettings(sound: true, badge: true, alert: true)
    // );
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings)
    // {
    //   print("Settings registered: $settings");
    // });
  }

  Future<void> _checkConnectivityState() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result
        ) {
      print('Current connectivity status: $result');

      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile){
        print('Connected to a Wi-Fi network');
        setState(() {
          noInternet = false;
        });
      } else {
        setState(() {
          noInternet = true;
        });
      }
    });

  }

  ratingsPopup(){
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
           width: size.width*0.8,
           height: size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6)
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      setState(() {
                        this.isPresentRating = false;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.cancel,color: Colors.black,size: 30,),
                    ),
                  ),
                ],
              ),
               CircleAvatar(
                child:  Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      image:  DataManager.shared.business == null ? null :
                      DecorationImage(
                          image:CachedNetworkImageProvider(
                              domainName + "/images/medium/" + DataManager.shared.business.logo),
                          fit: BoxFit.cover
                      )
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Text(language["title_rating"],style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
              SizedBox(height: 10,),
              Text(language["sub_title_rating"],textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.normal,fontFamily: DataManager.shared.fontName()),),
              SizedBox(height: 15,),
              Container(
                child: SmoothStarRating(
                    allowHalfRating: false,
                    onRated: (v) {
                      this.ratingCount = v;
                    },
                    starCount: 5,
                    rating: 2,
                    size: 40.0,
                    // isReadOnly:true,
                    // fullRatedIconData: Icons.blur_off,
                    // halfRatedIconData: Icons.blur_on,
                    color: Colors.yellow,
                    borderColor: Colors.yellow,
                    spacing:0.0
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: size.width * 0.7,
                height: 50,
                decoration: BoxDecoration(
                  color: _darkModeEnabled?Colors.white:Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                      width: 1,
                      color: Colors.grey.withOpacity(0.3)
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),

                  child: TextFormField(
                    controller: this.commitController,
                    style: TextStyle(color: _darkModeEnabled?Colors.black:Colors.black,),
                    decoration: InputDecoration(

                        hintText: language["hint_rating"],
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey,fontFamily: "Heebo")
                    ),
                    textAlign:TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      InkWell(
                          onTap: (){
                            var value = commitController.value.text;
                            if (orderForFeedback != null) {
                              DataManager.shared.addFeedback({"service_id":"${this.orderForFeedback.services.first.id}","stars":"${this.ratingCount}","text":value});
                            }
                            setState(() {
                              isPresentRating = false;
                            });
                          },
                          child: Text(language["submit_rating"],style: TextStyle(color: HexColor.fromHex(DataManager.shared.business.pColor),fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showWebView(String url){
    Future.delayed(const Duration(seconds: 1), ()
    {
      Navigator.of(context).push(_createRouteEdit(WebScreen(url: url,)));
    });
  }

  goCreateOrder(){
    Future.delayed(const Duration(seconds: 1), ()
    {
      Navigator.of(context).push(_createRouteEdit(SelectOrderTypeScreen()));
    });
  }

  @override
  void dispose() {
    DataManager.shared.tabController.dispose();
    commitController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
 //   var user = DataManager.shared.user;
    print("build  tabbar ");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      DefaultTabController(
        length: 5,//user != null && user.role != Role.admin ? 4 : 5,
        initialIndex: 4,//user != null && user.role != Role.admin ? 3 : 4,
        child:  Scaffold(

            bottomNavigationBar: menu(),
            body: Stack(
              children: [
                TabBarView(
                  // physics: NeverScrollableScrollPhysics(),
                  controller: DataManager.shared.tabController,
                  children: [
                    NotificationsScreen(callback: (){
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            print("call back noti");
                            DataManager.shared.showNotifications = false;
                          });
                        }
                      });
                    },),
                    MarketScreen(),
                    ConnectScreen(),
                    OrdersScreen(),
                    HomeScreen()
                  ],
                ),
                !noInternet ? SizedBox() : Positioned(
                    bottom: 0,
                    child: Container(
                  width: size.width,
                  height: 60,
                  color: Colors.red,
                      child: Center(child: Text(language["no_internet"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),)),

                )),
                isPresentRating == false ? SizedBox() : ratingsPopup()
              ],
            ),
          ),
        ),
      );
  }

  var _darkModeEnabled = false;

  Widget menu() {

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    return  Container(
        color: _darkModeEnabled ? Colors.black : Colors.white,
        child: SafeArea(
          child: TabBar(
            controller: DataManager.shared.tabController,
            indicatorColor: _darkModeEnabled ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey.withOpacity(0.7),
            labelColor: _darkModeEnabled ? Colors.white : Colors.black,
            labelStyle: TextStyle(fontSize: 11 ,fontFamily: DataManager.shared.fontName()),

            tabs: [
              Tab(
                text: language["notifications"],
                icon: Stack(
                  children: [
                    Container(
                        child: Icon(Icons.notifications_active_outlined)
                    ),
                    Positioned(
                      right: 0,
                      top: 6,
                      child: ClipOval(
                        child: DataManager.shared.showNotifications == false ? SizedBox() : Container(
                          height: 9,
                          width: 9,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),


              ),

              Tab(
                text: language["products"],
                icon: Icon(Icons.shop),

              ),

              Tab(
                text: language["connect_us"],
                icon: Icon(Icons.grid_view),
              ),


              Tab(
                text: language["my_orders"],
                icon: Stack(
                  children: [
                    Icon(Icons.assignment),
                  ],
                ),
              ),

              Tab(
                text: language["home"],
                icon: Icon(Icons.home),
              ),
            ],
          ),
        ),
      );
  }
  Route _createRouteEdit(screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
      screen,
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

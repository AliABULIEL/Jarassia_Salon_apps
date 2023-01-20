import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class LocationScreen extends StatefulWidget{

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var appBar = AppBar(
      elevation: 0,
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["location"],style: TextStyle(fontWeight: FontWeight.bold,color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: "Heebo"),),
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
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      appBar: appBar,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _header(),
        SizedBox(height: 20,),
        Center(
          child: InkWell(
            onTap: (){
              loc();
            },
            child: Container(
              height: 50,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.lightBlue
              ),
              child: Container(
                width: 30,
                height: 30,
                child: Image.asset("assets/images/waze.png"),
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),
        Center(
          child: InkWell(
            onTap: (){
              int flag =0;
              if(Platform.isAndroid){
                flag=1;
              }
              openMap(DataManager.shared.business.latitude,DataManager.shared.business.longitude,flag);
            },
            child: Container(
              height: 50,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey.withOpacity(0.7)
              ),
              child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset(Platform.isAndroid?"assets/images/googlemaps.png":"assets/images/apple.png"),
                  ),
              ),
            ),
          ),
        SizedBox(height: 10,),

        Text(DataManager.shared.business.address,style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkModeEnabled ? Colors.white : Colors
                .black.withOpacity(0.9),
            fontFamily: "Heebo"),),
        Padding(
          padding: const EdgeInsets.only(left:35.0,right: 35.0),
          child: Text(DataManager.shared.business.addressText,style: TextStyle(fontSize: 16,
              color: _darkModeEnabled ? Colors.white : Colors
                  .black.withOpacity(0.9),
              fontFamily: "Heebo"),),
        ),

      ],
    ),
    );

  }

  _header(){
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height * 0.35,
      decoration: BoxDecoration(
        image: DecorationImage(
            image:CachedNetworkImageProvider(domainName + "/storage/" + DataManager.shared.business.addressImage),
            fit: BoxFit.cover
        )
      ),
    );

  }

  loc(){
    var bus = DataManager.shared.business;
    var url = "https://waze.com/ul?ll=" + bus.latitude + "," + bus.longitude + "&navigate=yes&zoom=17";
    print(url);
    String mapRequest = url;
    _launchURL(mapRequest);

  }

  static Future<void> openMap(String latitude, String longitude, int flag) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query='+latitude+','+longitude;
    String appleUrl = 'https://maps.apple.com/?q='+latitude+','+longitude;
    if(flag ==1) {
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }

    }
    else {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        throw 'Could not open the map.';
      }

    }

  }


  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => SigninScreen(fromHome:true),
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


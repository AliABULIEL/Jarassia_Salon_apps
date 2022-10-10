import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';
import 'animation_screen.dart';

class SplashScreen extends StatefulWidget{

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _darkModeEnabled = false;

  @override
  void initState() {
    Firebase.initializeApp();
    fetchData();

    super.initState();
  }

  fetchData() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("api_token");
    var lan = prefs.getString("lan");
    //if (lan != null ) {DataManager.shared.lan = lan;}else{DataManager.shared.lan = "ar";}
    print("zzzzz");
    var busniss = await DataManager.shared.fetchHome({"business_id": Buissness_id});
    print("zzzzz");
    print(busniss);
    setState(() {
      DataManager.shared.business  = busniss;
    });
    print(busniss);

    if (token != null) {
      DataManager.shared.token = token;
      print(token);
      var user = await DataManager.shared.fetchUser(token);
      presentScreen(TabBarScreen());
    }else{
      presentScreen(TabBarScreen());
    }
  }

  presentScreen(StatefulWidget screen){
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => screen,
        ),
            (route) => false,
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var size = MediaQuery.of(context).size;
    var imageSize = size.width * 0.25;
    var bgColor = _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF1F1F1);
    return Scaffold(
      backgroundColor: bgColor,

      body: Stack(
        children: [
          Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: imageSize, width: imageSize,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(imageSize / 2)),
                    color: Colors.grey,
                    image:  DataManager.shared.business == null ? null :
                    DecorationImage(
                       image:CachedNetworkImageProvider(
                           domainName + "/images/medium/" + DataManager.shared.business.logo),
                          fit: BoxFit.cover
                    )
                  ),
                  ),
                  SizedBox(height: 5,),
                  Text(DataManager.shared.business != null ? DataManager.shared.business.name : "",
                    style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _darkModeEnabled ? Colors.white : Color(0xff121416),
                      fontFamily: "Heebo"),),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 20,
              child: SafeArea(
                child: Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                            child: _darkModeEnabled ? Image.asset("assets/images/logoD.png") : Image.asset("assets/images/logoW.png")
                        )
                      ],
                    )),
              )
          ),
          IgnorePointer(
              child: AnimationScreen(
                  color: bgColor
              )
          )
        ],
      ),
    );
  }
}

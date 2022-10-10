import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';


class VarficationCodeScreen extends StatefulWidget{

  Map map;
  VarficationCodeScreen({this.map});

  @override
  _VarficationCodeScreenState createState() => _VarficationCodeScreenState();
}

class _VarficationCodeScreenState extends State<VarficationCodeScreen> {

  final TextEditingController code = TextEditingController();
  bool _darkModeEnabled = false;

  var phoneString = "";
  String errorMessage = "";

  @override
  void initState() {
    phoneString = widget.map["phone"];
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var size = MediaQuery.of(context).size;
    var imageSize = size.width * 0.27;

    return Scaffold(
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(color: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),height: size.height*0.42,width: size.width,child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: imageSize, width: imageSize, decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(imageSize / 2)),
                color: Colors.grey,
                image:  DecorationImage(
                    image:CachedNetworkImageProvider(domainName + "/images/medium/" + DataManager.shared.business.logo),
                    fit: BoxFit.cover
                ),
              ),
              ),
              SizedBox(height: 8,),
              Text(DataManager.shared.business.name,style: TextStyle(fontSize: 20,fontFamily: DataManager.shared.fontName(),fontWeight:FontWeight.bold, color: _darkModeEnabled?Colors.white:Colors.black),),
            ],
          )
            ,),
          Text("${language["code_send_to"]} ${phoneString}",style: TextStyle(fontSize: 17,fontFamily: DataManager.shared.fontName(),color:  _darkModeEnabled? Colors.white:Colors.black),),
          SizedBox(height: 16,),
         Padding(
           padding: const EdgeInsets.only(left:25.0,right:25.0),
           child: Container(
        width: size.width * 0.8,
             child: PinCodeTextField(
                 appContext: context,
                 length: 5,
                 obscureText: false,
                 obscuringCharacter: '*',
                 animationType: AnimationType.fade,
               pinTheme: PinTheme(
                 shape: PinCodeFieldShape.box,
                 activeColor: Colors.grey,
                 borderRadius: BorderRadius.circular(10),
                 borderWidth: 1,
                 inactiveColor: Colors.grey,
                 fieldHeight: 50,
                 fieldWidth: 50,
                 activeFillColor: Colors.grey,

               ),
               cursorColor: Colors.white,
               animationDuration: Duration(milliseconds: 300),
               textStyle: TextStyle(fontSize: 20, height: 1.6,color: Colors.grey),
               backgroundColor:  _darkModeEnabled? Colors.black:Color(0xffF5F5F5),
               keyboardType: TextInputType.number,
               onCompleted: (v) {
                 //print("Completed");
                 setState(() {
                   errorMessage = "";
                 });
                 checkCode(v);
               },

             ),
           ),
         ),
          Padding(
            padding: const EdgeInsets.only(left: 35 ,right:35),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell( onTap: (){
                  Navigator.pop(context);
                },child: Text(language["dont_got_message"],style: TextStyle(color: Colors.grey,fontFamily: DataManager.shared.fontName()),)),
                 errorMessage == "" ? SizedBox() : Text(errorMessage,style: TextStyle(color: Colors.red,fontFamily: DataManager.shared.fontName()),)

              ],
            ),
          )

      ],
  ),
      bottomNavigationBar: InkWell(
        onTap: (){
          Navigator.pop(context);
        },
        child: Container(
          width: size.width,
          height: size.height*0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 25,),
              Text(language["back"],style: TextStyle(color: Colors.grey.withOpacity(1 ),fontFamily: DataManager.shared.fontName()),),
              SizedBox(width: 25,)
            ],
          ),
        ),
      ),
    );
  }

  checkCode(String code) async{
    print("checkCode");

    String apiToken;

    Map map = await DataManager.shared.verifyCode({"phone":phoneString,"code":code,"business_id": Buissness_id});

    if (map["api_token"] == null) {
      setState(() {
        errorMessage = map["message"];
      });
    } else {
      apiToken = map["api_token"];
      if (map["user"] != null) {
        Map mp = map["user"];
        User user = User.fromJson(mp);
        DataManager.shared.user = user;
      }


      var x = await DataManager.shared.fetchService(
          {"business_id": Buissness_id});

      print("Buisseness is " + Buissness_id);


      if (apiToken != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("api_token", apiToken);
        if (DataManager.shared.user == null) {
          var user = await DataManager.shared.fetchUser(apiToken);
        }
        DataManager.shared.token = apiToken;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TabBarScreen(),
          ),
              (route) => false,
        );
      }
    }
  }
}

//


import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Extensions.dart';

class SelectLanguageScreen extends StatefulWidget{

  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  bool _darkModeEnabled = false;

  var selectLanguage = -1;

  var isLoading = false;

  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;


    AppBar appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
      automaticallyImplyLeading: false,
      title: Text(language["language_title"],style: TextStyle(color: _darkModeEnabled ?  Color(0xffF5F5F5) : Colors.black ,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: DataManager.shared.fontName())),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(child: Container(
              width: 40,
              height: 40,
              child: InkWell(onTap: ()=>{
                Navigator.pop(context)
              }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
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
      body: Center(
          child: ListView(
      children:[
        Container(
          margin: EdgeInsets.all(100),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child:Text(language["choose_lan"], textAlign: TextAlign.right,
              style: TextStyle(
                  color: _darkModeEnabled ? Colors.grey : Colors.black
                      .withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: DataManager.shared.fontName())),
        ),

            _languageList()
              ],


      ),
    ),
    );



  }

  _languageList(){
    var size = MediaQuery
        .of(context)
        .size;

    return Container(
      height: 70,
      width: size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                this.selectLanguage = 0;
                save();
              });
            },
            child: _langaugeCell(language["arabic"],0),
          ),
          SizedBox(width: 10,),
          InkWell(
            onTap: (){
              setState(() {
                this.selectLanguage = 1;
                save();
              });
            },
            child: _langaugeCell(language["hebrew"],1),
          ),
          SizedBox(width: 10,),
          // InkWell(
          //   onTap: (){
          //     setState(() {
          //       this.selectLanguage = 2;
          //     });
          //   },
          //   child: _langaugeCell(language["english"],2),
          // ),
        ],
      ),
    );
  }

  _langaugeCell(name,index){
    var size = MediaQuery
        .of(context)
        .size;

    return Container(
      width: size.width * 0.25,
      height: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
              width: 2,
              color: selectLanguage == index ?HexColor.fromHex(DataManager.shared.business.pColor):Colors.grey
          )
      ),
      child: Center(child:
      Text(name,style:TextStyle(color: selectLanguage == index ? HexColor.fromHex(DataManager.shared.business.pColor):Colors.grey,fontSize: 16,fontFamily: DataManager.shared.fontName()),),
      ),
    );
  }

  save() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (selectLanguage == 0 ) {
      prefs.setString("lan", "ar");
    }else if (selectLanguage == 1) {
      prefs.setString("lan", "he");
    }else if (selectLanguage == 2) {
      prefs.setString("lan", "en");
    }
    if (selectLanguage != -1) {
      DataManager.shared.lan = selectLanguage == 0 ? "ar" : selectLanguage == 1 ? "he" : "en";
    }

  }
}

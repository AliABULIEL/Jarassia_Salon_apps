

import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Extensions.dart';
import '../Signin/SigninScreen.dart';




class Delete_User_Screen extends StatefulWidget{

  @override
  _Delete_User_screenState createState() => _Delete_User_screenState();
}



class _Delete_User_screenState extends State<Delete_User_Screen> {
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
          child:Text(language["delete_user"], textAlign: TextAlign.right,
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
           FlatButton(
            onPressed: ()=>{
              delete(),
              _logout()

            },
             child: _langaugeCell(language["approve"],0),

           ),

          SizedBox(width: 10,),
          FlatButton(
      onPressed: ()=> Navigator.of(context).pop()

             ,

            child: _langaugeCell(language["cancel"],1),
          ),
          SizedBox(width: 10,),


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
  _logout() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("api_token");
    DataManager.shared.user = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SigninScreen(),
      ),
          (route) => false,
    );
  }

  delete() async{

      var user = DataManager.shared.user;
      var map = {"id":user.id,"first_name":user.name,"last_name":user.lastName,"phone":user.phone};
      print(user);
      DataManager.shared.deleteUser(map);

  }
}

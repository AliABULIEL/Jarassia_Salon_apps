import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/User.dart';
import 'dart:math' as math;

import '../Extensions.dart';


class ClientsListScreen extends StatefulWidget{


  @override
  _ClientsListScreenState createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {

  List<User> clients = new List<User>();
  bool _darkModeEnabled = false;

  var selectFilter = false;

  @override
  void initState() {
    super.initState();
    getData();

  }

  getData() async{
    var users = await DataManager.shared.getClients(selectFilter ? "latest" : "top_orders");
    setState(() {
      clients = users;
    });
  }

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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            child: InkWell(onTap: ()=>{
              Navigator.pop(context)
            }, child: Transform.rotate(
                angle: 180 * math.pi/180,
                child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,))//Image.asset("assets/images/editProfile.png",color: Colors.black,)
            ),
          ),
          Text(language["clients"],style: TextStyle(fontWeight: FontWeight.bold,color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
          Container(
            child: InkWell(onTap: ()=>
            {
              setState((){
                selectFilter = !selectFilter;
                getData();
              })

            }, child: Text(selectFilter ? "latest" : "top_orders",style: TextStyle(fontWeight: FontWeight.bold,color:HexColor.fromHex(DataManager.shared.business.pColor) ,fontSize: 17,fontFamily: DataManager.shared.fontName()),),//Image.asset("assets/images/editProfile.png",color: Colors.black,)
            ),
          ),
        ],
      ),//
      centerTitle: true,

    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      body:  Container(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: clients.length, //users.length,
              itemBuilder: (context, idx) {
                var user = clients[idx];
                print(user.name);
                return UserCell(user);
              }
          )
      ),
    );
  }

  UserCell(User user){

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: user.suspended ?  Colors.deepOrangeAccent : HexColor.fromHex(DataManager.shared.business.pColor),//_darkModeEnabled ? Colors.white : Colors
                      //.black.withOpacity(0.9),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: FlatButton(
                      onPressed: () =>
                      {

                      setState(() {
                        user.suspended = !user.suspended;
                      }),
                        DataManager.shared.updateSuspended({"user_id":"${user.id}"}, user.suspended ? "suspend" : "unsuspend")


                  },
                      child: Text(user.suspended == true ?  language["user_disabled"] : language["user_enable"],
                        style: TextStyle(color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: DataManager.shared.fontName()),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment:  CrossAxisAlignment.end,
                      children: [
                        Text(user.name + " " + user.lastName,textDirection: TextDirection.rtl,style: TextStyle(fontWeight: FontWeight.bold,color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 16,fontFamily: DataManager.shared.fontName()),),
                        SizedBox(height: 2,),
                        Text(user.phone,style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 15,fontFamily: DataManager.shared.fontName()),),
                      ],
                    ),
                    SizedBox(width: 10,),
                    ClipOval(
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 5,),
                  ],
                ),
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
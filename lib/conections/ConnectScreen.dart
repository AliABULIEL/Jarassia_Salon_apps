import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Menu.dart';
import 'package:salon_app/models/Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Extensions.dart';


class ConnectScreen extends StatefulWidget{
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  bool _darkModeEnabled = false;

  TextEditingController _controller = TextEditingController();

  var services = DataManager.shared.services;


  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async{
    var services = await DataManager.shared.fetchallService({"business_id": Buissness_id});
    if (mounted){
      setState(() {
        this.services = DataManager.shared.services;
      });

    }

  }

  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var size = MediaQuery
        .of(context)
        .size;
    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["connect_us"], style: TextStyle(
          color: _darkModeEnabled ? Colors.white:Colors.black, fontSize: 17,fontWeight: FontWeight.bold, fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(child: InkWell(onTap: () =>
            {
              MenuView(context: context).presentMenu()
            },
                child: Icon(Icons
                    .menu,color: _darkModeEnabled ? Colors.white : Colors.black,)
            )),
            SizedBox(width: 10,),

          ],
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      body: SafeArea(
        child: Container(
            width: size.width,
            height: size.height,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: services.length, //users.length,
                itemBuilder: (context, idx) {
                  var service = services[idx];
                  return _item(size, service);
                }
                )
        ),
      ),
    );
  }




  _showSuccesAlert(BuildContext context) async{
    await DataManager.shared.sendMessage({"content":_controller.value.text});
    _controller.text = "";
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success
      );

  }

  _item(Size size,Service service){
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(service.name,textAlign: TextAlign.right,style: TextStyle(color: ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 18,fontFamily: DataManager.shared.fontName()),),
                  Container(
                      width: size.width - (size.width * 0.26) - 70,
                      child: Text(service.desc,maxLines: 3,overflow: TextOverflow.ellipsis,textAlign: TextAlign.right,style: TextStyle(color: ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 13,fontFamily: DataManager.shared.fontName()),)),

                ],
              ),
              SizedBox(width: 10,),
              InkWell(
                 onTap:() {
                 //  showAlertDialog(context,service);
                 },
                 child: Container(
                    width: size.width * 0.24,
                    height: size.width * 0.26,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            width: 1,
                            color:  Colors.black
                        ),
                        image: service.image  == null ? null : DecorationImage(
                            image: CachedNetworkImageProvider(domainName + "/images/small/" + service.image),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context,Service service) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(service.name,style: TextStyle(fontFamily: DataManager.shared.fontName()),),
      content: Text(service.desc),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
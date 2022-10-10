
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceTimeScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/OrderResult.dart';

import '../../Extensions.dart';
import 'OrderFinishScreen.dart';


class ServiceUserDetailsScreen extends StatefulWidget {

  Map map;
  OrderResult orderResult;
  bool isEdit;
  bool isWorkshop = false;

  ServiceUserDetailsScreen({this.map,this.orderResult,this.isEdit,this.isWorkshop});

  @override
  _ServiceUserDetailsScreenState createState() => _ServiceUserDetailsScreenState();
}

class _ServiceUserDetailsScreenState extends State<ServiceUserDetailsScreen> {

  var isLoading = false;
  bool _darkModeEnabled = false;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();
  Map newMap;


  @override
  void initState() {
    this.newMap = widget.map;
    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _controllerPhone.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;


    var appBar = AppBar(
      elevation: 0,
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white:Colors.black, //change your color here
      ),
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["order_dower"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 18,fontFamily: DataManager.shared.fontName()),),
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
        backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF1F1F1),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 10,),
                _textField(language["main_name"],_controllerName,false),
                SizedBox(height: 10,),
                _textField(language["last_name"],_controllerLastName,false),
                SizedBox(height: 10,),
                _textField(language["phone_number"],_controllerPhone,true),
                SizedBox(height: 20,),
                Container(
                  height: 50,
                  width: (size.width * 0.9) * 0.44  ,
                  decoration: BoxDecoration(
                      color:HexColor.fromHex(DataManager.shared.business.pColor),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: FlatButton(
                    onPressed: ()=>{
                      if(isLoading == false){
                        submitUserData()
                      }
                    },
                    child: Text(
                      language["next"],
                      style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ,

    );


  }

  _textField(String placeHolder,TextEditingController controller,bool isNumbers) {

    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        color: _darkModeEnabled?Colors.black:Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
            width: 1,
            color: Colors.grey.withOpacity(0.3)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8,right: 8),

        child: TextFormField(
          keyboardType: isNumbers ? TextInputType.number : TextInputType.name,
          controller: controller,
          style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,),
          decoration: InputDecoration(
            // labelText: text,
              hintText: placeHolder,
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey,fontFamily: DataManager.shared.fontName())
          ),
          textAlign:TextAlign.right,
        ),
      ),
    );
  }

  submitUserData(){
    print(widget.map);
    print(this.newMap);
    if (_controllerName.value.text.isNotEmpty && _controllerPhone.value.text.isNotEmpty && _controllerLastName.value.text.isNotEmpty) {
      var name = _controllerName.value.text;
      var lastName = _controllerLastName.value.text;
      var phone = _controllerPhone.value.text;
      this.newMap["first_name"] = name;
      this.newMap["last_name"] = lastName;
      this.newMap["phone"] = phone;
      print(this.newMap);
      widget.map = this.newMap;
      Navigator.of(context).push(_createRoute(widget.orderResult));

    }
  }

  Route _createRoute(OrderResult orderResult) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => OrderFinishScreen(map: widget.map,orderResult: orderResult,isEdit: widget.isEdit,isWorkshop: widget.isWorkshop,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
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
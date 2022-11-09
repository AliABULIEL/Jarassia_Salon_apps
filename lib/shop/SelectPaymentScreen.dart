import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Product.dart';
import 'package:salon_app/shop/CreditCardWebView.dart';

import '../Extensions.dart';


class SelectPaymentScreen extends StatefulWidget {

  @override
  _SelectPaymentScreenState createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {

  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled =  qdarkMode == Brightness.dark;


    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white:Colors.black, //change your color here
      ),
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["my_cart"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              child:  InkWell(onTap: ()=>{
                Navigator.pop(context)
              }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
              ),
            )
          ],
        )
      ],

    );

    var color = _darkModeEnabled ? Colors.black : Colors.white;
    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Color(0xff252322) : Color(0xffF1F1F1),
      body: Center(
        child: Column(
          children: [
            Text(language["choose_Payment_type"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: ()=>{
                    _submit(false)
                  },
                  child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: color,
                        border: Border.all(
                            width: 2 ,
                            color:  Color(0xffF1F1F1)//HexColor.fromHex(DataManager.shared.business.pColor):
                        )

                    ),                child: Center(child: _itemView(language["cash"])),
                  ),
                ),
                InkWell(
                  onTap: ()=> {
                    _submit(true)
                  },
                  child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: color,
                        border: Border.all(
                            width: 2 ,
                            color:  Color(0xffF1F1F1)//HexColor.fromHex(DataManager.shared.business.pColor):
                        )

                    ),
                    child: Center(child: _itemView(language["credit_card"])),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _itemView(String title){
    return  Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,style: TextStyle(fontWeight:  FontWeight.bold , color: _darkModeEnabled ? Colors.white.withOpacity(1) : Colors.black.withOpacity(1),fontSize: 16,fontFamily: DataManager.shared.fontName()),),
            ],
          ),
        ),
      ),
    );
  }

  _submit(bool isCredit) async{
    // var urlPayment = "http://secure.cardcom.solutions/External/lowProfileClearing/137194.aspx?LowProfileCode=2c676c40-b83f-4713-890b-9c33eedb795c";//dictionary["payment_url"];
    // Navigator.of(context).push(_createRoute(urlPayment));
    // return;
    Map map = {"payment_method": isCredit ? "credit_card" : "cash"};
    var dictionary = await DataManager.shared.submitCart(map);
    if (isCredit == true && dictionary["payment_url"] != null) {
      var urlPayment = dictionary["payment_url"];
      Navigator.of(context).push(_createRoute(urlPayment));
    }
  }

  Route _createRoute(url) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>  CreditCardWebView(url:url,isFromOrder: false,),
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
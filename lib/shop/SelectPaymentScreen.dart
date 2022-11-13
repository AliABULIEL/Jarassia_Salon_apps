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
  bool isLoading = false;
  var showAlert = false;
  var type = 0;
  var title = language["success_cash_message"];

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
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text(language["choose_Payment_type"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                SizedBox(height: 30,),
                SizedBox(height: 100,),
                Text(language["choose_Payment"],   style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),textAlign:TextAlign.right,),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DataManager.shared.business.cashPayment == false ? SizedBox() :
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
                    DataManager.shared.business.creditCardPayment == false ? SizedBox() : InkWell(
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
          isLoading ? _loading() : SizedBox(),
          showAlert ? _alertView() : SizedBox(),
        ],
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

  _loading(){
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        _showSuccesAlert();
      },
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.black.withOpacity(0.75),
      ),
    );
  }

  _showLoadingAlert(){
    setState(() {
      type = 1;
      showAlert = true;
    });
  }

  _showSuccesAlert(){
    setState(() {
      type = 2;
    });
  }

  _alertView(){
    print("ali23232323232");
    print(type);
    print(showAlert);
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: InkWell(
          onTap: (){
            if (type == 2) {
              showAlert = false;
              type = 0;
              Navigator.of(context).popUntil((route) => route.isFirst);
              //Navigator.of(context, rootNavigator: true).pop('dialog');


            }
          },
          child: type != 2 ? SizedBox() : Container(
            width: size.width * 0.65,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color:Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height:10),
                Text(type == 2 ? title : "...",style: TextStyle(color: Colors.black,fontSize: 22),),
                Spacer(),
                type == 2 ? Text(language["done"]) : SizedBox(),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _submit(bool isCredit) async{
    if (isLoading == true) {
      return;
    }
    _showLoadingAlert();
    isLoading = true;
    Map map = {"payment_method": isCredit ? "credit_card" : "cash"};
    var dictionary = await DataManager.shared.submitCart(map);
    isLoading = false;

    if (isCredit == true && dictionary["payment_url"] != null) {
      var urlPayment = dictionary["payment_url"];
      Navigator.of(context).push(_createRoute(urlPayment));
    }else{

      _showSuccesAlert();
      // Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Route _createRoute(url) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>  CreditCardWebView(url:url,isFromOrder: true,),
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
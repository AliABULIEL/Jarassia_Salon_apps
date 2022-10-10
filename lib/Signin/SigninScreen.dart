import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salon_app/Signin/RegisterScreen.dart';
import 'package:salon_app/Signin/VarficationCodeScreen.dart';
import 'package:salon_app/home/edits/WebScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/User.dart';

import '../Extensions.dart';


class SigninScreen extends StatefulWidget{

  Map map;
  bool fromHome = false;
  SigninScreen({this.fromHome,this.map});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _darkModeEnabled = false;
  bool isloading = false;

  String errorMessage = "";


  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

   var  color =  _darkModeEnabled ? Colors.white : Colors.black;


    var size = MediaQuery.of(context).size;
    var imageSize = size.width * 0.27;


    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          // For Android.
          // Use [light] for white status bar and [dark] for black status bar.
          statusBarIconBrightness: _darkModeEnabled ? Brightness.light : Brightness.dark,
          // For iOS.
          // Use [dark] for white status bar and [light] for black status bar.
          statusBarBrightness: _darkModeEnabled ?  Brightness.dark : Brightness.light,
        ),
        child:Scaffold(
        // appBar: AppBar(
        //   brightness: _darkModeEnabled ? Brightness.light : Brightness.dark,
        // ),
        backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
        body: Stack(
          children: [
            Column(
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
                     Text(DataManager.shared.business.name,style: TextStyle(fontSize: 20,fontFamily: DataManager.shared.fontName(),fontWeight: FontWeight.bold, color: _darkModeEnabled?Colors.white:Colors.black),),
                  ],
                )
                  ,),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.map == null ?  language["sign_in"] : "${language["sign_in"]}  ",style: TextStyle(fontSize: 20,fontFamily: DataManager.shared.fontName(),color: _darkModeEnabled?Colors.white:Colors.black.withOpacity(0.9)),),
                ),
                SizedBox(height: 6,),
                Container(width: size.width * 0.9,height: 50,decoration: BoxDecoration(
                  color: _darkModeEnabled?Colors.black:Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.withOpacity(0.3)
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    Container(
                      height: 50,
                      width: (size.width * 0.9) * 0.34  ,
                      decoration: BoxDecoration(
                         color:HexColor.fromHex(DataManager.shared.business.pColor),
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: FlatButton(
                        onPressed: (){
                          print(_controller.value.text);
                          if (_controller.value.text.isNotEmpty && !isloading){
                            setState(() {
                              errorMessage = "";
                            });

                            if (widget.map == null){
                              widget.map = {"phone":_controller.value.text};
                            }else{
                              widget.map["phone"] = _controller.value.text;
                            }
                            sendRequest();

                          }

                        },
                        child: Text(
                          language["next"],
                          style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
                        ),
                      ),
                    ),
                    Expanded(child: TextField(
                      controller: _controller,
                      textAlign:TextAlign.right,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black),
                      decoration: InputDecoration(
                        hintText: language["phone_number"],
                        labelStyle: TextStyle(
                            color: Colors.white,fontFamily: DataManager.shared.fontName(),
                        ),

                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey)
                    ),)),
                    SizedBox(width: 10,)
                  ],
                ),
                ),
                errorMessage == "" ? SizedBox(): Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(errorMessage,style: TextStyle(color: Colors.red,fontFamily: DataManager.shared.fontName()),)
                    ],
                  ),
                )

              ],
            ),
            widget.fromHome == true ?  Positioned(
                  right: 10,
                  top: 0,
                  child: SafeArea(
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        child: Icon(Icons.close,color: color ,),
                      ),
                    ),
                  ),
            ):SizedBox(),
          ],
        ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: size.height*0.15,
                width: size.width*0.1,
                child: Row(
                  children: [
                    SizedBox(width: size.width * 0.5 / 2,),

                    Row(children: [
                      InkWell(onTap: ()=>{
                        widget.map = null,
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen(), fullscreenDialog: true),
                        )
                      } , child: Text(language["register_now"],style: TextStyle(color: HexColor.fromHex(DataManager.shared.business.pColor),fontSize: 15,
                          fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),)),
                      SizedBox(width: 4,),
                      Text(language["dont_have_account"],style: TextStyle(color: Colors.grey,fontSize: 15,
                          fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                    ],),


                  ],
                ),
              ),
            ),
      ),
    );
  }

  sendRequest() async{
    print("params");
    isloading = true;
    print(widget.map);
    widget.map["business_id"] = Buissness_id;
    if (widget.map.containsKey("first_name")){
      Map map = await DataManager.shared.register(widget.map);
      isloading = false;
      if (map["errors"] != null) {
          var message = map["message"];
          setState(() {
            errorMessage = message;
          });
      }else{
        Navigator.of(context).push(_createRoute());
      }
    }else{

      Map map = await DataManager.shared.login(widget.map);
      isloading = false;

      if (map["errors"] != null) {
        var message = map["message"];
        setState(() {
          errorMessage = message;
        });
      }else{
        Navigator.of(context).push(_createRoute());
      }

    }
  }

  Route _createRoute() {

    print(widget.map);

    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => VarficationCodeScreen(map: widget.map,),
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/edits/WebScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';

import '../Extensions.dart';


class RegisterScreen extends StatefulWidget{

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _darkModeEnabled = false;

  bool isAcceptTerms = false;
  bool selectedWithoutAccept = false;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  Map map;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var imageSize = size.width * 0.27;

    return Scaffold(
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      resizeToAvoidBottomInset: false,

      body: Container(
        child: SingleChildScrollView(
          child: Column(
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
                  Text(DataManager.shared.business.name,style: TextStyle(fontSize: 20,fontFamily: DataManager.shared.fontName(),fontWeight: FontWeight.bold,color: _darkModeEnabled?Colors.white:Colors.black),),
                ],
              )
                ,),
              Text("${language["invite_to"]} ${DataManager.shared.business.name} ",style: TextStyle(fontSize:18,fontFamily: DataManager.shared.fontName(),color: _darkModeEnabled?Colors.white:Colors.black),),
          SizedBox(height: 6,),
          Container(width: size.width * 0.9,height: 50,decoration: BoxDecoration(
              color: _darkModeEnabled?Colors.black:Color(0xffF5F5F5),
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
            child: Row(
              children: [
                Expanded(child: Container(
                decoration: BoxDecoration(
                  color: _darkModeEnabled?Colors.black:Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.withOpacity(0.3)
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                  child:  Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8),
                    child: TextField(
                      controller: _controllerLastName,
                      style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,fontFamily: "Heebo"),
                      textAlign:TextAlign.right,
                      decoration: InputDecoration(
                        hintText: language["last_name"],
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey,fontFamily: "Heebo")
                      ),),
                  ),
                )),
                SizedBox(width: 15,),
                Expanded(child: Container(
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
                    child: TextField(
                      controller: _controllerName,
                      style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black),
                      textAlign:TextAlign.right,
                      decoration: InputDecoration(
                        hintText: language["main_name"],
                        border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey,fontFamily: "Heebo")
                      ),),
                  ),
                ))
              ],
            ),
          ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
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
                        onPressed: ()=>{
                          if (_controllerLastName.value.text.isNotEmpty && _controllerName.value.text.isNotEmpty) {
                            if (isAcceptTerms != false) {
                              this.map = {"first_name":_controllerName.value.text,"last_name":_controllerLastName.value.text},
                              Navigator.of(context).push(_createRoute())
                            }else{
                              setState(() {
                                   selectedWithoutAccept = true;
                              })
                            }


                    }
                        },
                        child: Text(
                          language["next"],
                          style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
                        ),
                      ),
                    ),
                    Row(
                      children: [


                        InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebScreen(url: domainName + "/api/terms-of-use",), fullscreenDialog: true),
                              );
                            },

                            child: Text(language["privacy_policy"],style: TextStyle(color:  Colors.red ,fontFamily: DataManager.shared.fontName(),decoration: TextDecoration.underline,),)

                        ),
                        InkWell(

                            child: Text(" ",style: TextStyle(color: (selectedWithoutAccept == true && isAcceptTerms == false ) ? Colors.red: Colors.grey,fontFamily: DataManager.shared.fontName()),)
                        ),
                        InkWell(

                            child: Text(language["policy"],style: TextStyle(color: (selectedWithoutAccept == true && isAcceptTerms == false ) ? Colors.red: Colors.grey,fontFamily: DataManager.shared.fontName()),)
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              isAcceptTerms = !isAcceptTerms;
                            });
                          },
                          child: Icon(
                            isAcceptTerms == true ? Icons.check_box_outlined : Icons.check_box_outline_blank_sharp,
                            color: (selectedWithoutAccept == true && isAcceptTerms == false ) ? Colors.red: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: size.height*0.15,
          width: size.width*0.6,
          child: Row(
            children: [
              SizedBox(width: size.width * 0.7 / 2,),
              InkWell(onTap: ()=>{
                print(123)
              }, child: InkWell(onTap: (){
                Navigator.pop(context);
              },child: Text(language["sign_in"],style: TextStyle(color: HexColor.fromHex(DataManager.shared.business.pColor),fontSize: 15,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),))),
              SizedBox(width: 5,),
              Text(language["have_an_account"],style: TextStyle(color: Colors.grey,fontSize: 15,
                  fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => SigninScreen(map: this.map,),
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

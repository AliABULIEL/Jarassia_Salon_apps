import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceNameScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Employe.dart';

import '../../Extensions.dart';
import 'ServiceScreen.dart';

class SelectOrderTypeScreen extends StatefulWidget {

  @override
  _SelectOrderTypeScreenState createState() => _SelectOrderTypeScreenState();
}

class _SelectOrderTypeScreenState extends State<SelectOrderTypeScreen> {
  bool _darkModeEnabled = false;
  bool isLoading = false;
  int selectId = -1;

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
      title: Text(language["order_dower"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
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
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: size.width,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // _item(size,0,language["group_appointment"]),
                  _item1(size,1,language["normal_appointment"])
                ],
              ),
              SizedBox(height: 20,),
              selectId == -1 ? SizedBox() : Container(
                height: 50,
                width: (size.width * 0.9) * 0.44,
                decoration: BoxDecoration(
                    color:HexColor.fromHex(DataManager.shared.business.pColor),
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: FlatButton(
                  onPressed: ()=>{
                      if ( selectId == 0){
                        if (isLoading == false){
                          print("**"),
                          getEmployes()
                        }

                      }else{
                        if (isLoading == false){
                          print("**2"),
                          Navigator.of(context).push(_createRoute())
                        }
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
      ),

    );
  }

  _item1(Size size,int currentId,String name){
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                if (currentId != selectId) {
                  setState(() {
                    selectId = currentId;
                  });
                }
              });
            },
            child: Stack(
              children: [
                Container(
                  width: size.width * 0.22,
                  height: size.width * 0.22,

                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular((size.width * 0.22)/2)),

                    border: Border.all(
                        width: 4,
                        color: currentId == selectId ? HexColor.fromHex(DataManager.shared.business.pColor) : Colors.black
                    ),

                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset("assets/images/person.png"),
                  ),
                ),
                currentId == selectId ? Stack(

                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: size.width * 0.1,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: HexColor.fromHex(DataManager.shared.business.pColor),
                      size: size.width * 0.1,
                    ),
                  ],
                ):SizedBox()
              ],
            ),
          ),
          Text(name,textAlign: TextAlign.center,style: TextStyle(color: currentId == selectId ? HexColor.fromHex(DataManager.shared.business.pColor) : ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
        ],
      ),
    );
  }

  _item(Size size,int currentId,String name){
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                if (currentId != selectId) {
                  setState(() {
                    selectId = currentId;
                  });
                }
              });
            },
            child: Stack(
              children: [
                Container(
                  width: size.width * 0.22 ,
                  height: size.width * 0.22,

                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular((size.width * 0.25 )/2)),

                      border: Border.all(
                          width: 4,
                          color: currentId == selectId ? HexColor.fromHex(DataManager.shared.business.pColor) : Colors.black
                      ),


                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset("assets/images/groups.png"),
                  ),
                ),
                currentId == selectId ? Stack(

                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: size.width * 0.1,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: HexColor.fromHex(DataManager.shared.business.pColor),
                      size: size.width * 0.1,
                    ),
                  ],
                ):SizedBox()
              ],
            ),
          ),
          Text(name,textAlign: TextAlign.center,style: TextStyle(color: currentId == selectId ? HexColor.fromHex(DataManager.shared.business.pColor) : ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
        ],
      ),
    );
  }

  getEmployes() async {
    isLoading = true;
    List<Employee> employees = await DataManager.shared.getWorkshopEmpolyee({});
    isLoading = false;
    print(employees.length);
    Navigator.of(context).push(_createRoute(list:employees));
  }

  Route _createRoute({List<Employee> list}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => selectId == 0 ?  ServiceNameScreen(employees: list,isWorkshop: true,) : ServiceScreen(),
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
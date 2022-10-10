import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceScreen.dart';
import 'package:salon_app/home/orderSteps/ServiceTimeScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/OrderResult.dart';

import '../../Extensions.dart';


class ServiceNameScreen extends StatefulWidget {

  List<Employee> employees;
  Map map;
  OrderResult orderResult;
  bool isWorkshop = false;

  ServiceNameScreen({this.employees,this.map,this.orderResult,this.isWorkshop});

  @override
  _ServiceNameScreenState createState() => _ServiceNameScreenState();
}

class _ServiceNameScreenState extends State<ServiceNameScreen> {
  var selectId = -1 ;
  var isLoading = false;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    if (widget.orderResult != null) {
      this.selectId = widget.orderResult.employee.id;
    }
    super.initState();
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(language["choose_service_name"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                  SizedBox(height: 10,),
                  Container(
                    height:  size.height*0.21,
                      child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.employees.length, //users.length,
                          itemBuilder: (context, idx) {
                            var service = widget.employees[idx];
                            return _item(size, service);
                          }
                      )
                  ),
                  SizedBox(height: 20,),
                  selectId == -1 ? SizedBox() : Container(
                    height: 50,
                    width: (size.width * 0.9) * 0.44  ,
                    decoration: BoxDecoration(
                        color:HexColor.fromHex(DataManager.shared.business.pColor),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: ()=>{
                        if(isLoading == false){
                          _submitData()
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
          // Positioned(
          //   bottom: -5,
          //   right: -5,
          //   child://Image.asset("assets/images/logoicon-03.png")
          //   Container(
          //     height: size.width/1.8,
          //     width: size.width/1.8,
          //     child: Image.asset(_darkModeEnabled ? "assets/images/IMG_7095.png" : "assets/images/IMG_7094.png"),
          //   ),
          // )
        ],
      ),
    );
  }

  _item(Size size,Employee employee){
    return Padding(
      padding: const EdgeInsets.only(left:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                selectId = employee.id;
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
                        width: 5,
                        color: selectId == employee.id ? HexColor.fromHex(DataManager.shared.business.pColor) : _darkModeEnabled ?  Colors.black : Color(0xffF5F5F5),
                      ),
                      image: employee.image  == null ? null : DecorationImage(
                          image:CachedNetworkImageProvider(domainName + "/images/small/" + employee.image),
                          fit: BoxFit.cover
                      )
                  ),
                ),
            selectId == employee.id  ? Stack(

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
            ) : SizedBox()
              ],
            ),
          ),
          Text(employee.first_name,textAlign: TextAlign.center,style: TextStyle(color: selectId == employee.id ? HexColor.fromHex(DataManager.shared.business.pColor) : (_darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
        ],
      ),
    );
  }

  _submitData() async{
    isLoading = true;
    print(selectId);
    print("_submitData");
    print(widget.map);
    if (widget.isWorkshop == null) {
      widget.map["employee_id"] = this.selectId;
      var days = await DataManager.shared.submitEmployee(widget.map);
      if (days != null) {
        Navigator.of(context).push(_createRoute(days:days));
      }
    }else{
      isLoading = false;
      Navigator.of(context).push(_createRoute());
    }
    isLoading = false;
    
  }

  Route _createRoute({List days}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => widget.isWorkshop != null ? ServiceScreen(map:{"employee_id":this.selectId},orderResult: widget.orderResult,isWorkshop: true,) :  ServiceTimeScreen(map: widget.map,days: days,orderResult: widget.orderResult,),
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
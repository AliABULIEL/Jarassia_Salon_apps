import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceNameScreen.dart';
import 'package:salon_app/home/orderSteps/ServiceTimeScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/Day.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/models/Service.dart';

import '../../Extensions.dart';


class ServiceScreen extends StatefulWidget {

  OrderResult orderResult;
  Map map;
  bool isWorkshop = false;

  ServiceScreen({this.orderResult,this.map,this.isWorkshop});

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {

  bool _darkModeEnabled = false;
  var selectIds = [];
  var services = DataManager.shared.services;
  var isLoading = false;
  Map map;

  @override
  void initState() {
    print("isWorkshop");
    print(widget.isWorkshop);
    fetchData();
    super.initState();
  }

  fetchData() async{
    if (widget.isWorkshop == null) {
      var services = await DataManager.shared.fetchService({"business_id": Buissness_id});
      if (widget.orderResult != null) {
        print("update servicess");
        this.selectIds = widget.orderResult.getServiceIds();
      }else{
        print("not update servicess");

      }
      setState(() {
        this.services = DataManager.shared.services;
      });
    }else{

      setState(() {
        this.services = [];
      });
      var services = await DataManager.shared.getWorkshopService(widget.map);
      if (widget.orderResult != null) {
        print("update servicess");
        this.selectIds = widget.orderResult.getServiceIds();
      }else{
        print("not update servicess");

      }
      if (services != null) {
        setState(() {
          this.services = services;
        });
      }

    }

  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 1,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white : Colors.black, //change your color here
      ),
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
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(language["order_dower"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
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
                  Text(language["choose_service"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                  SizedBox(height: 10,),
                  Container(
                      height:  size.height*0.21,
                      child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: services.length, //users.length,
                          itemBuilder: (context, idx) {
                            var service = services[idx];
                            return _item(size, service);
                          }
                      )
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: services.map<Widget>((e) {
                  //     return _item(size, e);
                  //   }).toList(),
                  // ),
                  SizedBox(height: 20,),
                  selectIds.length == 0 ? SizedBox() : Container(
                    height: 50,
                    width: (size.width * 0.9) * 0.44  ,
                    decoration: BoxDecoration(
                        color:HexColor.fromHex(DataManager.shared.business.pColor),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: ()=>{
                        if (isLoading == false) {
                          print("isLoading"),
                          submitService()
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

  submitService() async{
    isLoading = true;
    if (widget.isWorkshop == null) {
      print("not workshop");
      map = {"services_id":this.selectIds};
      var employees = await DataManager.shared.submitService(map);
      isLoading = false;
      Navigator.of(context).push(_createRoute(employes: employees));
    }else{
      print("is workshop");
      widget.map["workshop_id"] = this.selectIds.first;
      print(widget.map);
      var days = await DataManager.shared.getWorkshopDays(widget.map);
      isLoading = false;
      Navigator.of(context).push(_createRoute(days: days));
    }


  }

  _item(Size size,Service service){
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                if (selectIds.contains(service.id)) {
                  selectIds.removeWhere((element) => element == service.id);
                }else{
                  selectIds.add(service.id);
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
                          color: selectIds.contains(service.id) ? HexColor.fromHex(DataManager.shared.business.pColor) : Colors.black
                      ),
                      image: service.image  == null ? null : DecorationImage(
                          image:CachedNetworkImageProvider(domainName + "/images/small/" + service.image),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                selectIds.contains(service.id) ? Stack(

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
          Text(service.name,textAlign: TextAlign.center,style: TextStyle(color: selectIds.contains(service.id)? HexColor.fromHex(DataManager.shared.business.pColor) : ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
        ],
      ),
    );
  }

  Route _createRoute({List<Employee> employes,List<Day> days}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => widget.isWorkshop != null ? ServiceTimeScreen(map: widget.map,days: days,orderResult: widget.orderResult,isWorkshop: true,) : ServiceNameScreen(employees: employes,map: this.map,orderResult: widget.orderResult,),
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

}/*

*/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/Day.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Service.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/models/Group.dart';

import '../../Extensions.dart';


class ServiceGroup extends StatefulWidget {


  OrderResult orderResult;
  Map map;
  bool isWorkshop = false;

  ServiceGroup({this.orderResult,this.map,this.isWorkshop});

  @override
  _ServiceGroupScreenState createState() => _ServiceGroupScreenState();
}

class _ServiceGroupScreenState extends State<ServiceGroup> {


  bool _darkModeEnabled = false;
  var selectIds = -1;
  var groups = DataManager.shared.groups;
  var isLoading = false;
  Map map;

  @override
  void initState() {
    print("ali66");
    print("isWorkshop");
    print(widget.isWorkshop);
    fetchData();
    super.initState();
  }

  fetchData() async{
    if (widget.isWorkshop == null) {
      var groups = await DataManager.shared.fetchGroups({"business_id": Buissness_id});
      print(groups);
      if (widget.orderResult != null) {
        print("update groups");
        this.selectIds = widget.orderResult.getGroupsIds();
      }else{
        print("not update groups");

      }
      setState(() {
        this.groups = DataManager.shared.groups;
      });
    }else{

      setState(() {
        this.groups = [];
      });
      var ListView = await DataManager.shared.getWorkshopService(widget.map);
      if (widget.orderResult != null) {
        print("update groups");
        this.selectIds = widget.orderResult.getServiceIds();
      }else{
        print("not update groups");

      }
      if (groups != null) {
        setState(() {
          this.groups = groups;
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
      title: Text(language["order_group"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
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
                  Text(language["choose_services"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                  SizedBox(height: 10,),
                  Container(
                      height:  size.height*0.21,
                      child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: groups.length, //users.length,
                          itemBuilder: (context, idx) {
                            var group = groups[idx];
                            return _item(size, group);
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
                  selectIds == -1 ? SizedBox() : Container(
                    height: 50,
                    width: (size.width * 0.9) * 0.44  ,
                    decoration: BoxDecoration(
                        color:HexColor.fromHex(DataManager.shared.business.pColor),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: ()=>{
                        if (isLoading == false) {
                          print("!!!!!!!!!!"),
                          print(selectIds),
                          print("isLoading"),
                          submitGroup()
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

  submitGroup() async{
    isLoading = true;
    if (widget.isWorkshop == null) {
      print("not workshop");
      map = {"groups_id":this.selectIds};
      var services = await DataManager.shared.fetchService(map);
      print(services);
      isLoading = false;
      Navigator.of(context).push(_createRoute(services: services));
    }else{
      print("is workshop");
      widget.map["workshop_id"] = this.selectIds;
      print(widget.map);
      var days = await DataManager.shared.getWorkshopDays(widget.map);
      isLoading = false;
      Navigator.of(context).push(_createRoute(days: days));
    }


  }

  _item(Size size,Group group){
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                if (group.id != selectIds) {
                  setState(() {
                    selectIds = group.id;
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
                          color: selectIds ==(group.id) ? HexColor.fromHex(DataManager.shared.business.pColor) : Colors.black
                      ),
                      image: group.image  == null ? null : DecorationImage(
                          image:CachedNetworkImageProvider(domainName + "/images/small/" + group.image),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                selectIds ==(group.id) ? Stack(

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
          Text(group.name,textAlign: TextAlign.center,style: TextStyle(color: selectIds ==(group.id)? HexColor.fromHex(DataManager.shared.business.pColor) : ( _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.8)),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
        ],
      ),
    );
  }

  Route _createRoute({List<Service> services,List<Day> days}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => widget.isWorkshop != null ? ServiceScreen() : ServiceScreen(map: this.map,orderResult: widget.orderResult,),
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
import 'dart:developer';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/edits/EditBusnissScreen.dart';
import 'package:salon_app/home/edits/EditUserScreen.dart';
import 'package:salon_app/home/edits/WebScreen.dart';
import 'package:salon_app/home/orderSteps/OrderFinishScreen.dart';
import 'package:salon_app/home/orderSteps/ServiceGroup.dart';
import 'package:salon_app/home/orderSteps/ServiceScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Menu.dart';
import 'package:salon_app/models/Order.dart';
import 'package:salon_app/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';



class OrdersScreen extends StatefulWidget{
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _darkModeEnabled = false;
  var indexHeaderSelected = 0;
  bool showMaxOrderPopup = false;

  List<Order> orders = new List<Order>();
  List<Order> archivedOrders = new List<Order>();
  List<Order> waitApproveOrders = new List<Order>();

  Order selectOrder;

  @override
  void initState() {
    fetchOrders();
    super.initState();
  }

  fetchOrders() async{

    archivedOrders = DataManager.shared.archivedOrders;
    orders = DataManager.shared.orders;
    waitApproveOrders = DataManager.shared.waitApproveOrders;

    if(DataManager.shared.user != null) {
      if (indexHeaderSelected == 0){
        var data = await DataManager.shared.fetchActiveOrders({"business_id": Buissness_id});
        print(orders.length);
        print("length");
        if (mounted) {
          setState(() {
            orders = DataManager.shared.orders;
          });
        }
      }else if(indexHeaderSelected == 1){
        var data = await DataManager.shared.fetchOldOrders({"business_id": Buissness_id});
        if (mounted) {
          setState(() {
            archivedOrders = DataManager.shared.archivedOrders;
          });
        }
      }else if(indexHeaderSelected == 2){
          var data = await DataManager.shared.fetchWaitOrders({"business_id": Buissness_id});
          if (mounted) {
            setState(() {
              waitApproveOrders = DataManager.shared.waitApproveOrders;
            });
          }
      }

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
      elevation: 0,
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DataManager.shared.user != null && DataManager.shared.user.suspended ? SizedBox() :
            InkWell(onTap: (){
              if (DataManager.shared.user == null) {
                print("user need auth");
                Navigator.of(context).push(_createRoute(false,false));
              }else if (DataManager.shared.orders.length < 3 &&  DataManager.shared.user.role == Role.client){
                Navigator.of(context).push(_createRoute(true,false)).then((value) => fetchOrders());
              }else if (DataManager.shared.user.role != Role.client){
                Navigator.of(context).push(_createRoute(true,false)).then((value) => fetchOrders());
              }else{
                setState(() {
                  showMaxOrderPopup = true;
                });
              }
            }, child: Container(width: 40,height: 40, child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.add,color: _darkModeEnabled ? Colors.white : Colors.black,),
              ],
            ))),
            Text(language["my_orders"],style: TextStyle(fontWeight: FontWeight.bold,color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
            InkWell(
              onTap: (){
                MenuView(context: context).presentMenu();
              },
              child: Container(
                width: 40,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.menu,
                      color: _darkModeEnabled ? Colors.white : Colors
                          .black,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      centerTitle: true,
    );

    return Scaffold(

      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 20,),
              _headerView(),
              SizedBox(height: 20,),
              // _infoCell(),
              hasData() == false ?  Container(height:size.height * 0.45,child:
              Center(child: Text(language["no_order_placeholder"],style: TextStyle(
                  color:Colors.grey, fontSize: 17,fontWeight: FontWeight.bold, fontFamily: DataManager.shared.fontName()),))) :
              Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: indexHeaderSelected == 0 ? orders.length :  indexHeaderSelected == 1 ?  archivedOrders.length : waitApproveOrders.length , //users.length,
                    itemBuilder: (context, idx) {
                      return _infoCell(idx);
                    }

                ),
              )
            ],
          ),
          showMaxOrderPopup ? _maxOrderPopup() : SizedBox()
        ],
      ),
    );
  }

  _maxOrderPopup(){
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: InkWell(
          onTap: (){
            setState(() {
              showMaxOrderPopup = false;
            });
          },
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color:Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height:10),

                Text(language["max_order_message"] ,textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 22,fontFamily:DataManager.shared.fontName()),),

                Spacer(),
                Text(language["cancel"]),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasData() {
    if (indexHeaderSelected == 0 && orders.length == 0) {
      return false;
    }
    if (indexHeaderSelected == 1 && archivedOrders.length == 0) {
      return false;
    }
    if (indexHeaderSelected == 2 && waitApproveOrders.length == 0) {
      return false;
    }
    return true;
  }

  _headerView(){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(onTap: (){
          setState(() {
            indexHeaderSelected = 0 ;
            fetchOrders();
          });
        }, child: Container(child: Text(language["actives"],style: TextStyle(fontSize: 19,color: indexHeaderSelected == 0 ? _darkModeEnabled ? Colors.white : Colors.black : Colors.grey,fontFamily: DataManager.shared.fontName()),))),
        SizedBox(width: 40,),
        InkWell(onTap: (){
          setState(() {
            indexHeaderSelected = 1;
            fetchOrders();
          });
        }, child: Container( child: Text(language["archives"],style: TextStyle(fontSize: 19,color: indexHeaderSelected == 1 ? _darkModeEnabled ? Colors.white : Colors.black : Colors.grey,fontFamily: DataManager.shared.fontName()),))),
        SizedBox(width: 40,),
        InkWell(onTap: (){
          setState(() {
            indexHeaderSelected = 2;
            fetchOrders();
          });
        }, child: Container( child: Text(language["wait_approve"],style: TextStyle(fontSize: 19,color: indexHeaderSelected == 2 ? _darkModeEnabled ? Colors.white : Colors.black : Colors.grey,fontFamily: DataManager.shared.fontName()),))),
        SizedBox(width: 20,),
      ],

    );
  }

  _infoCell(int index){
    print("ALASLDASLDLASLDALSDAL");
    var order = indexHeaderSelected == 0 ? orders[index] : indexHeaderSelected == 1 ? archivedOrders[index] : waitApproveOrders[index];

    ImageProvider image =CachedNetworkImageProvider(order.userImage);
    precacheImage(image, context);
    var showDate = this.showSectionTitle(index);
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
      child: InkWell(
        onTap: (){
          this.selectOrder = order;
          print("1!!!!!!");
          print(order.canCancel);
          print(order.canEdit);
          Navigator.of(context).push(_createRoute(true,true)).then((value) => fetchOrders());
        },
        child: Container(
          color: _darkModeEnabled ? Colors.black : Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.only(left: 0,right: 0),
            child: Column(
              children: [
                showDate == false ? SizedBox() : Container(
                    color: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
                    width: MediaQuery.of(context).size.width,

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${order.startingDate}",textAlign: TextAlign.center,style: TextStyle(fontSize: 14,color: _darkModeEnabled ?  Colors.white : Colors.black,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                    )),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Text(order.clientsCount > 0 ? language["group_appointment"] : language["normal_appointment"],style: TextStyle(fontSize: 14,color: Colors.grey,fontFamily: DataManager.shared.fontName()),),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(height: 25,width: 25,decoration: BoxDecoration(
                              color: _darkModeEnabled ? Colors.white : Colors.black.withOpacity(0.9),
                              borderRadius: BorderRadius.all(Radius.circular(12.5)),
                              image: DecorationImage(
                                      image: image,
                                      fit: BoxFit.cover
                                  )
                              )),
                              SizedBox(width: 5,),
                              Text(order.startingTime,style: TextStyle(fontSize: 14,color: _darkModeEnabled ?  Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.9),fontFamily: DataManager.shared.fontName()),),

                            ],
                          ),
                          Text("${order.clinetName}",style: TextStyle(fontSize: 14,color: _darkModeEnabled ?  Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.9),fontFamily: DataManager.shared.fontName()),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              order.notes == "" ? SizedBox():
                              Icon(
                                Icons.circle,color: Colors.red,size: 8,
                              ),
                              SizedBox(width: 3,),
                              Text(order.name,style: TextStyle(fontSize: 14,color: _darkModeEnabled ?  Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.9),fontFamily:DataManager.shared.fontName()),),
                            ],
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
      ),
    );
  }

  Route _createRoute(bool isOrder,bool isEdit) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => isOrder == true ? isEdit == true ? OrderFinishScreen(order: selectOrder,isEdit: false,) : ServiceGroup() : SigninScreen(fromHome:true),
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

  bool showSectionTitle(index){
    var ordersList = indexHeaderSelected == 0 ? orders : indexHeaderSelected == 1 ? archivedOrders : waitApproveOrders;

    if (index > 0) {
        if (ordersList[index].startingDate == ordersList[index-1].startingDate) {
          return false;
        }
        return true;
    }
    return  true;
  }
}

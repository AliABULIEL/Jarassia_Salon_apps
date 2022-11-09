import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceNameScreen.dart';
import 'package:salon_app/home/orderSteps/ServiceScreen.dart';
import 'package:salon_app/home/orderSteps/ServiceTimeScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Employe.dart';
import 'package:salon_app/models/Order.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/models/User.dart';
import '../../Extensions.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

import '../../shop/CreditCardWebView.dart';


class OrderFinishScreen extends StatefulWidget{


  Map map;
  OrderResult orderResult;
  Order order;
  bool isEdit = false;
  bool isWorkshop = false;

  OrderFinishScreen({this.map,this.orderResult,this.order,this.isEdit,this.isWorkshop});

  @override
  _OrderFinishScreenState createState() => _OrderFinishScreenState();
}

class _OrderFinishScreenState extends State<OrderFinishScreen> {

  bool _darkModeEnabled = false;
  var isLoading = false;
  var title = language["success_order_message"];
  var showAlert = false;
  var type = 0;
  bool maxTime = false;

  Map newMap;
  OrderResult orderResult;


  @override
  void initState() {

    newMap = widget.map;
    if (widget.order != null) {
      print("fetch Data in finish");
      fetchData();
    }else{
      print("order is null in initt State check");
      orderResult = widget.orderResult;
    }

    _children.clear();

    if (DataManager.shared.business.cashPayment == true && DataManager.shared.business.creditCardPayment == true){
      _children[0] = Text(language['cash']);
      _children[1] = Text(language['credit_card']);
    }else if (DataManager.shared.business.creditCardPayment == true){
      _children[0] = Text(language['credit_card']);
      if (this.newMap != null) {
        this.newMap["payment_method"] = "credit_card";
      }
    }else if (DataManager.shared.business.cashPayment == true){
      _children[0] = Text(language['cash']);
      if (this.newMap != null) {
        this.newMap["payment_method"] = "cash";
      }
    }
    print(_children);

    super.initState();
  }

  fetchData() async {
    orderResult = await DataManager.shared.getOrder(widget.order.id);
    setState(() {
      orderResult = orderResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white:Colors.black, //change your color here
      ),
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Text(widget.order != null ? language["order_details"] : language["sure_order"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isLoading || showAlert ? SizedBox() : Center(child: Container(
              width: 40,
              height: 40,
              child:  InkWell(onTap: ()=>{
                if (widget.order != null) {
                  Navigator.of(context).popUntil((route) => route.isFirst)
                }else{
                  Navigator.pop(context)
                  }
              }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
              ),
            )
            ),
            SizedBox(width: 10,),
          ],
        )
      ],

    );
    // TODO: implement build
    return Scaffold(
      appBar: isLoading ? null : appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF1F1F1),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left:28.0,right: 28.0),
              child: SingleChildScrollView( 
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height-30,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (orderResult == null || orderResult.user == null) && (this.newMap == null || this.newMap["first_name"] == null ) ? SizedBox() : _clientView(size),
                      _serviceView(size),
                      _serviceNameView(size),
                      _serviceDateView(size),
                      _serviceTimeView(),
                      (widget.order != null || widget.isEdit == true ) == false ? _serviceCashOrCard() : SizedBox(),
                      ((DataManager.shared.user.role != Role.client) && ((widget.order == null))) ? _serviceNoteView() : (widget.order != null && widget.order.notes != "") ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(widget.order.notes ,textDirection: TextDirection.rtl,style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,fontSize: 14,fontFamily: DataManager.shared.fontName()),),
                              SizedBox(width: 8,),
                              Text(":"),
                              Text(language["note"],textDirection: TextDirection.rtl,style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,fontSize: 14,fontFamily: DataManager.shared.fontName()),),
                            ],
                          )

                          : SizedBox(),
                       orderResult == null ? SizedBox() : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          (orderResult != null && orderResult.order != null && orderResult.order.canEdit == false) ? SizedBox() : Container(
                            height: 50,
                            //width: (size.width * 0.4) ,
                            decoration: BoxDecoration(
                                color:HexColor.fromHex(DataManager.shared.business.pColor),
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: FlatButton(
                              onPressed: ()=>{
                                print(this.newMap),
                                if(widget.order != null || widget.isEdit == true ) {
                                  editSubmitData()

                                }else{
                                  submitData()
                                }
                                },
                              child: Text(
                                (widget.order != null || widget.isEdit == true ) ? language[widget.isEdit == true ? "save" : "update"] : language["sure"],
                                style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: DataManager.shared.fontName()),
                              ),
                            ),
                          ),
                          (orderResult != null && orderResult.order != null && orderResult.order.canCancel == false || (orderResult == null) || widget.isEdit == true || this.newMap != null) ? SizedBox() :
                          Container(
                            height: 50,
                           // width: (size.width * 0.4) ,
                            decoration: BoxDecoration(
                                color:Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: FlatButton(
                              onPressed: ()=>{
                                print(this.newMap),
                                cancelOrder()
                              },
                              child: Text(
                                language["cancel"],
                                style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: DataManager.shared.fontName()),
                              ),
                            ),
                          ),
                          orderResult != null && orderResult.order != null &&
                              orderResult.order.canApprove == true && widget.isEdit == false ?


                          Container(
                            height: 50,
                            // width: (size.width * 0.4) ,
                            decoration: BoxDecoration(
                                color:Colors.orange,
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: FlatButton(
                              onPressed: ()=>{
                                print(this.newMap),
                                appoveOrder()
                              },
                              child: Text(
                                language["approve"],
                                style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),
                              ),
                            ),
                          )
                              : SizedBox()
                        ],
                      ),
                      SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
          isLoading ? _loading() : SizedBox(),
          showAlert ? _alertView() : SizedBox(),
          maxTime ? _maxOrderPopup(size) : SizedBox(),
        ],
      ),
    );
  }

  submitData() async{

    title = language["success_order_message"];
    _showLoadingAlert();
    this.newMap["business_id"] = Buissness_id;
    print(this.newMap);
    if (widget.isWorkshop == null) {
      var data = await DataManager.shared.submitOrder(this.newMap);
      print("zzzzzzzssscccsd*****");
      print(data);
      if (data != null) {
        if (data.paymentUrl != null && data.paymentUrl != "") {
          _goToCreditCardView(data.paymentUrl);
        }else{
          _showSuccesAlert();
        }
      }else{
        setState(() {
          maxTime = true;
        });
      }
    }else{
      var data = await DataManager.shared.submitWorkshopOrder(this.newMap);
      print("zzzzzzzssscccsd*****2");
      print(data);
      if (data != null) {
        if (data.paymentUrl != null && data.paymentUrl != "") {
          _goToCreditCardView(data.paymentUrl);
        }else{
          _showSuccesAlert();
        }
      }else{
        setState(() {
          maxTime = true;
        });
      }
    }
  }

  _goToCreditCardView(String url) {
    Navigator.of(context).push(_createRoute(CreditCardWebView(url: url ,isFromOrder: true,)));
  }

  cancelOrder() async{
    title = language["cancel_order_message"];
    _showLoadingAlert();
    var data = await DataManager.shared.cancelOrder(orderResult.order.id,{"business_id":Buissness_id});
    _showSuccesAlert();
  }

  appoveOrder() async{
    title = language["success_order_message"];
    _showLoadingAlert();
    var data = await DataManager.shared.approveOrder(orderResult.order.id,{"business_id":Buissness_id});
    _showSuccesAlert();
  }

  editSubmitData() async{
    title = language["edit_order_message"];

    print(widget.isEdit);
    if(widget.isEdit == false) {
      print("go to edit screens");
      if (orderResult.services.first.clientsCount > 0) {
        _goEmployeeScreen();
      }else{
        _goServicesScreen();
      }
      return;
    }
    if (this.newMap == null){
      print("no edit Data");
      return;}
    var map =
    {
      "services_id":this.newMap["services_id"] == null ? orderResult.getServiceIds():this.newMap["services_id"],
      "employee_id":this.newMap["employee_id"] == null ? orderResult.employee.id : this.newMap["employee_id"],
      "date": this.newMap["date"] == null ? orderResult.date : this.newMap["date"],
      "time":this.newMap["time"] == null ? orderResult.time : this.newMap["time"],
    };

    print("orderId");

    print(orderResult.order.id);

    if (orderResult.services.first.clientsCount > 0) {
      map["workshop_id"] = this.newMap["workshop_id"] == null ? orderResult.getServiceIds():this.newMap["workshop_id"];
      map.remove("services_id");
    }
    if (orderResult.order.id != null) {
      _showLoadingAlert();
      if (orderResult.services.first.clientsCount > 0) {
        print("start edit workshop *******");
        var data = await DataManager.shared.editWorkshopOrder(orderResult.order.id,map);
      }else{
        var data = await DataManager.shared.editOrder(orderResult.order.id,map);

      }
      _showSuccesAlert();
    }

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

  _showLoadingAlert(){
    setState(() {
      type = 1;
      showAlert = true;

    });

      // CoolAlert.show(
      //     context: context,
      //     type: CoolAlertType.loading,
      //     barrierDismissible: false,
      //
      // );
  }

  _showSuccesAlert(){
    // _showMyDialog();
    // return;
   setState(() {
     type = 2;
    });
    // Future.delayed(const Duration(seconds: 1), () {
    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   showAlertDialog();

      // CoolAlert.show(
      //     context: context,
      //     type: CoolAlertType.success,
      //     title: title,
      //     animType:CoolAlertAnimType.slideInDown,
      //     confirmBtnText:language["done"],
      //     barrierDismissible: false,
      //     onConfirmBtnTap: () {
      //       Navigator.of(context, rootNavigator: true).pop('dialog');
      //       Navigator.of(context).popUntil((route) => route.isFirst);
      //     }
      // );
   // });

  }

  showAlertDialog() {

    // set up the button
    Widget okButton = FlatButton(
      child: Text(language["done"]),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      title: Text(title),
    //  content: Text(null),

      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible:false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _clientView(Size size){
    print("show name");
    print(this.newMap);
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((this.newMap != null && this.newMap["first_name"] != null)  ? this.newMap["first_name"] : orderResult.user.name,style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
            SizedBox(width: 10,),
            Text((this.newMap != null && this.newMap["first_name"] != null) ? this.newMap["phone"] : orderResult.user.phone ,style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
          ],
        ),
      ),
    );
  }
  _serviceView(Size size){
    return  InkWell(
      onTap: (){
        _goServicesScreen();

      },
      child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: orderResult == null ? [] :
                orderResult.services.map((e){
                  return Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: orderResult == null ? [] :
                        [

                          Container(
                            width: size.width * 0.2,
                            height: size.width * 0.2,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(Radius.circular((size.width * 0.22)/2)),
                                image: e.image  == null ? null : DecorationImage(
                            image:CachedNetworkImageProvider(domainName + "/images/small/" + e.image),
                        fit: BoxFit.cover
                    )
                            ),

                          ),
                          orderResult == null ? SizedBox() : Text(e.name,textAlign: TextAlign.center,style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black,fontSize: 14,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                        ],
                      ),
                  );
                }).toList()

              ),
              Text(language["service"],textAlign: TextAlign.center,style: TextStyle(color: Colors.grey,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
            ],
          ),
      ),
    );
  }

  _serviceNameView(Size size){
    return InkWell(
      onTap: (){
        print("_serviceNameView");
        _goEmployeeScreen();

      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.2,
                  height: size.width * 0.2,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular((size.width * 0.5)/2)),
                      image: orderResult  == null ? null : DecorationImage(
                          image:CachedNetworkImageProvider(domainName + "/images/small/" + orderResult.employee.image),
                          fit: BoxFit.cover
                      )
                  ),
                  //

                ),
                orderResult  == null ? SizedBox() : Text(  orderResult.employee.first_name,textAlign: TextAlign.center,style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: DataManager.shared.fontName()),),
              ],
            ),
            Text(language["service_name"],textAlign: TextAlign.center,style: TextStyle(color: Colors.grey,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
          ],
        ),
      ),
    );
  }

  _serviceDateView(Size size){
    return InkWell(
      onTap: (){
        print("_serviceDateView");
        _goTimeScreen();
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: _darkModeEnabled?Colors.black:Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    orderResult  == null ? SizedBox():Text(orderResult.day,style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: DataManager.shared.fontName()),),
                    orderResult  == null ? SizedBox(): Text(orderResult.date,style: TextStyle(color: Colors.grey,fontSize: 13,fontFamily: DataManager.shared.fontName())),
                  ],
                ),
              ),
            ),
          Text(language["time_day_1"],textAlign: TextAlign.center,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
          ],
        ),
      ),
    );
  }

  _serviceTimeView(){
    return InkWell(
      onTap: (){
        print("_serviceTimeView");
        _goTimeScreen();
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              color: _darkModeEnabled?Colors.black:Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: orderResult  == null ? SizedBox(): Text(orderResult.time.start,textAlign: TextAlign.center,
                  style: TextStyle(color: _darkModeEnabled?Colors.grey:Colors.black,fontSize: 16,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
              ),
            ),
            Text(language["time_day_2"],textAlign: TextAlign.center,style: TextStyle(color: Colors.grey,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
          ],
        ),
      ),
    );
  }

  _serviceNoteView(){
    return  Container(
          child: TextField(
            style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 15,fontFamily: DataManager.shared.fontName()),
            onChanged: (value) {
              this.newMap["notes"] = value;
            },
            decoration: InputDecoration(
              hintText: language["note"] + "...",
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
          ),
      );
  }
  int _currentSelection = 0;
  _serviceCashOrCard(){
    if (DataManager.shared.business.creditCardPayment == false && DataManager.shared.business.cashPayment == false) {
      return SizedBox();
    }
    return  Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialSegmentedControl(
            horizontalPadding: EdgeInsets.all(14),
            children: _children,
            selectionIndex: _currentSelection,
            borderColor: Colors.grey,
            selectedColor: HexColor.fromHex(DataManager.shared.business.pColor),
            unselectedColor: Colors.white,
            borderRadius: 6.0,
            //disabledChildren: _disabledIndices,
            verticalOffset: 8.0,
            onSegmentChosen: (index) {
              setState(() {
                _currentSelection = index;
                if (DataManager.shared.business.creditCardPayment == true && DataManager.shared.business.cashPayment == true) {
                  if (index == 1) {
                    this.newMap["payment_method"] = "credit_card";
                  }else{
                    this.newMap["payment_method"] = "cash";
                  }
                }else {
                  if (DataManager.shared.business.creditCardPayment == true) {
                    this.newMap["payment_method"] = "credit_card";
                  }else{
                    this.newMap["payment_method"] = "cash";
                  }
                }
              });
            },
          ),
          Text(language["payment_method"],style: TextStyle(color: Colors.grey,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),

        ],
      )
    );
  }

  Map<int, Widget> _children = {
    0: Text(language['cash']),
    1 : Text( " " + language['credit_card'] + " ")

  };

  _maxOrderPopup(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: size.width * 0.7,
          height: (size.width * 0.6) * 0.65,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(language["max_time"],style: TextStyle(color:Colors.black.withOpacity(0.9),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
              Container(
                height: 50,
                width: (size.width * 0.9) * 0.44,
                decoration: BoxDecoration(
                    color:HexColor.fromHex(DataManager.shared.business.pColor),
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: FlatButton(
                  onPressed: () => {
                    setState(() {
                      this.maxTime = false;
                      this.showAlert = false;
                    })
                  },
                  child: Text(
                    language["cancel"],
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

  Route _createRoute(screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
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

  _goEmployeeScreen() async {
    if (orderResult != null && orderResult.order != null && orderResult.order.canEdit) {
      if (isLoading == true) {
      return;
    }
    isLoading = true;

      var map = {"services_id": orderResult.getServiceIds()};
      var employees = await DataManager.shared.submitService(map);
      isLoading = false;
      var mp = covertToMap();

      if (orderResult.services.first.clientsCount > 0) {
        List<Employee> employees = await DataManager.shared.getWorkshopEmpolyee({});
        Navigator.of(context).push(_createRoute(ServiceNameScreen(
            employees: employees, orderResult: orderResult, map: mp,isWorkshop:orderResult.services.first.clientsCount > 0)));
      }else{
        Navigator.of(context).push(_createRoute(ServiceNameScreen(
            employees: employees, orderResult: orderResult, map: mp,)));
      }

    }
  }

  _goServicesScreen() {
    if (orderResult != null && orderResult.order != null && orderResult.order.canEdit) {

     // ServiceScreen(map:{"employee_id":this.selectId},orderResult: widget.orderResult,isWorkshop: true,)
      if (orderResult.services.first.clientsCount > 0) {
        Navigator.of(context).push(_createRoute(ServiceScreen(orderResult: this.orderResult,map:{"employee_id":orderResult.employee.id},isWorkshop:orderResult.services.first.clientsCount > 0)));
      }else{
        Navigator.of(context).push(_createRoute(ServiceScreen(orderResult: this.orderResult)));
      }
    }
  }

  _goTimeScreen() async{
    if (orderResult != null && orderResult.order != null && orderResult.order.canEdit) {
      isLoading = true;


      if (orderResult.services.first.clientsCount > 0) {
        var map2 = {"employee_id": orderResult.employee.id,"workshop_id":orderResult.getServiceIds()};
        var days = await DataManager.shared.getWorkshopDays(map2);
        isLoading = false;
        if (days != null) {
          var map = covertToMapWorkshop();
          Navigator.of(context).push(_createRoute(ServiceTimeScreen(orderResult: this.orderResult,days: days,map: map,isWorkshop: orderResult.services.first.clientsCount > 0,)));
        }
      }else{
        var map = {"employee_id": orderResult.employee.id,"services_id":orderResult.getServiceIds()};
        print(map);
        var days = await DataManager.shared.submitEmployee(map);
        isLoading = false;
        if (days != null) {
          var map = covertToMap();
          Navigator.of(context).push(_createRoute(ServiceTimeScreen(orderResult: this.orderResult,days: days,map: map,isWorkshop: orderResult.services.first.clientsCount > 0,)));
        }
      }

       
  }

  }

  Map covertToMap(){
    var map =
    {
      "services_id": orderResult.getServiceIds(),
      "employee_id": orderResult.employee.id,
      "date": orderResult.date,
      "time": orderResult.time.start
    };

    return map;

  }

  Map covertToMapWorkshop(){
    var map =
    {
      "workshop_id": orderResult.services.first.id,
      "employee_id": orderResult.employee.id,
      "date": orderResult.date,
      "time": orderResult.time.start
    };

    return map;

  }


}

import 'package:flutter/material.dart';
import 'package:salon_app/home/orderSteps/ServiceUserDetailsScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/Day.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/OrderResult.dart';
import 'package:salon_app/models/User.dart';

import '../../Extensions.dart';
import 'OrderFinishScreen.dart';


class ServiceTimeScreen extends StatefulWidget {

  List<Day> days;
  Map map;
  OrderResult orderResult;
  bool isWorkshop = false;

  ServiceTimeScreen({this.map,this.days,this.orderResult,this.isWorkshop});

  @override
  _ServiceTimeScreenState createState() => _ServiceTimeScreenState();
}

class _ServiceTimeScreenState extends State<ServiceTimeScreen> {
  var selectDay = -1;
  var selectTime = -1;

  List<Time> times = List<Time>();

  bool _darkModeEnabled = false;

  bool firstTime = true;
  bool isLoading = false;
  bool maxTime = false;

  @override
  void initState() {
    super.initState();
    checkData();
  }

  checkData(){
    if(widget.orderResult != null) {
      var index = 0;
      print("start checking date");
      widget.days.forEach((element) {
        print(element.date);
        print(widget.orderResult.date);
        if(element.date == widget.orderResult.date) {
          selectDay = index;
          _fetchTime();
        }
        index++;
      });
    }
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
      title: Text(language["order_dower"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 18,fontFamily: DataManager.shared.fontName()),),
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
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF1F1F1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width-16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                [
                  Padding(
                    padding: const EdgeInsets.only(left:15.0,right: 15),
                    child: Text(language["choose_day"],style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.9),fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                  ),
                  _selectDays(size),
                  SizedBox(height: 10,),
                  selectDay == -1 ? SizedBox() : Container(
                    width: size.width,
                    height: 40,
                    child: Text(language["choose_time"],textAlign: TextAlign.right,style: TextStyle(color: _darkModeEnabled ? Colors.grey : Colors.black.withOpacity(0.9),fontSize: 17,fontFamily: DataManager.shared.fontName()))//
                  ),
                  selectDay == -1 ? SizedBox() : _selectTime(size),
                  SizedBox(height: 15,),
                  selectDay != -1 ? selectTime != -1 ? Container(
                    height: 50,
                    width: (size.width * 0.9) * 0.44,
                    decoration: BoxDecoration(
                        color:HexColor.fromHex(DataManager.shared.business.pColor),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: () => {

                        _submitTime()

                      },
                      child: Text(
                        language["next"],
                        style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
                      ),
                    ),
                  ) : SizedBox() : SizedBox(),
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
          maxTime ? _maxOrderPopup(size) : SizedBox()
        ],
      ),
    );
  }

  _selectDays(Size size){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 10,),
        Container(
          width: size.width-16,
          height: 100,
          child: ListView.builder(
              reverse: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.days.length,
              itemBuilder: (context, idx) {
                return GestureDetector(
                  onTap: (){
                    if (widget.days[idx].disabled == false) {
                        this.selectDay = idx;
                        selectTime = -1;

                        _fetchTime();
                    }
                  },
                  child: _itemDay(size,idx),
                );
              }
          ),
        )
      ],
    );
  }

  _selectTime(Size size){
    return Container(
           width: size.width-16,
           height: (times == null ||  times.length == 0) ? 100 : 65,
          child: (times == null ||  times.length == 0) ?  _waitingListButton(size) : ListView.builder(
              reverse: true,
              scrollDirection: Axis.horizontal,
              itemCount: times == null ? 0 : times.length,
              itemBuilder: (context, idx) {
                return GestureDetector(
                  onTap: (){
                    if (times[idx].disabled == false) {
                      setState(() {
                        this.selectTime = idx;
                      });
                    }

                  },
                  child: _itemTime(size,idx),
                );
              }
          ),
        );

  }

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


  _waitingListButton(Size size){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(language["no_times_day"],
              style: TextStyle(color: Colors.grey,fontSize: 17,fontFamily: DataManager.shared.fontName())),
       SizedBox(height: 5,),
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                    color:HexColor.fromHex(DataManager.shared.business.pColor),
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: FlatButton(
                  onPressed: () => {
                    if (isLoading == false) {
                      _submitWaitingList()
                    }
                  },
                  child: Text(
                    language["add_waiting_list"],
                    style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _submitWaitingList() async{
    print("start submit waiting list");
    isLoading = true;
    Map map;
    if (widget.isWorkshop == null) {
      map = {"employee_id":widget.map["employee_id"],"services_id":widget.map["services_id"],"date":widget.days[selectDay].date};
    }else{
      map = {"employee_id":widget.map["employee_id"],"workshop_id":widget.map["workshop_id"],"date":widget.days[selectDay].date};
    }
    isLoading = false;
    bool value = await DataManager.shared.addWaitngToList(map);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  _itemDay(Size size ,int index){
    var disabled = widget.days[index].disabled;
    var color = _darkModeEnabled ? Colors.black : Colors.white;
    if (disabled == true) {
      color = color.withOpacity(0.5);
    }
    return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: color,
            border: Border.all(
              width: selectDay == index ? 4 : 0,
              color: selectDay == index ? HexColor.fromHex(DataManager.shared.business.pColor): Color(0xffF1F1F1)
            )

          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.days[index].name,style: TextStyle(fontWeight:  selectDay == index ? FontWeight.bold:FontWeight.normal , color: _darkModeEnabled ? Colors.white.withOpacity(disabled == true ? 0.4 : 1) : Colors.black.withOpacity(disabled == true ? 0.4 : 1),fontSize: 14,fontFamily: DataManager.shared.fontName()),),
                Text(widget.days[index].date,style: TextStyle(fontWeight:  selectDay == index ? FontWeight.bold:FontWeight.normal ,color: Colors.grey,fontSize: 13,fontFamily: DataManager.shared.fontName())),
              ],
            ),
          ),
        ),
    );
  }

  _itemTime(Size size ,int index){
    var disabled = times[index].disabled;

    var color = _darkModeEnabled ? Colors.black : Colors.white;
    if (disabled == true) {
      color = color.withOpacity(0.5);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: color,
            border: Border.all(
                width: selectTime == index ? 4 : 0,
                color: selectTime == index ? HexColor.fromHex(DataManager.shared.business.pColor) : Color(0xffF1F1F1)
            )

        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(times[index].start,style: TextStyle(color: _darkModeEnabled ? Colors.white.withOpacity(disabled == true ? 0.4 : 1) : Colors.black.withOpacity(disabled == true ? 0.4 : 1),fontSize: 15,fontWeight: selectTime == index ? FontWeight.bold : FontWeight.w500,fontFamily: DataManager.shared.fontName()),),

        ),
      ),
    );
  }

  _fetchTime() async{
    widget.map["date"] = widget.days[selectDay].date;
    print(widget.map);
    if (widget.isWorkshop == null) {
      var times = await DataManager.shared.submitDay(widget.map);

      setState(() {
        this.times =  times;
      });
    }else{
      print("111");
      var times = await DataManager.shared.getWorkshopTimes(widget.map);
      setState(() {
        this.times = times;
      });
    }


    // if (widget.orderResult != null && firstTime == true) {
    //   firstTime = false;
    //   var index = 0;
    //   times.forEach((element) {
    //     if (widget.orderResult.time.start.contains(element.start)) {
    //       setState(() {
    //         this.selectTime = index;
    //       });
    //     }
    //     index ++;
    //   });
    // }
  }

  _submitTime() async{
    widget.map["time"] = times[selectTime].start;
    print(widget.map);
    OrderResult orderResult;
    if (widget.isWorkshop == null) {
      orderResult = await DataManager.shared.submitTime(widget.map);
      if (widget.orderResult != null && orderResult != null) {
        orderResult.order = widget.orderResult.order;
      }
    }else{
      orderResult = await DataManager.shared.getWorkshopSubmitTimes(widget.map);
      if (widget.orderResult != null && orderResult != null) {
        orderResult.order = widget.orderResult.order;
      }
    }
    if (orderResult == null) {
      setState(() {
        this.maxTime = true;
      });
      return;
    }
    print(widget.map);
    print("isEdit");
    print(widget.orderResult == null);
    if (DataManager.shared.user.role != Role.client && widget.orderResult == null){
      Navigator.of(context).push(_createRoute(orderResult,true));
    }else{
      Navigator.of(context).push(_createRoute(orderResult,false));
    }
  }

  Route _createRoute(OrderResult orderResult,bool isAdmin) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => isAdmin ? ServiceUserDetailsScreen(map: widget.map,orderResult: orderResult,isEdit: widget.orderResult == null ? false : true,isWorkshop: widget.isWorkshop,) :
      OrderFinishScreen(map: widget.map,orderResult: orderResult,isEdit: widget.orderResult == null ? false : true,isWorkshop: widget.isWorkshop,),
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
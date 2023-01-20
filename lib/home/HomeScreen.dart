import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/Signin/RegisterScreen.dart';
import 'package:salon_app/home/orderSteps/SelectOrderTypeScreen.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/Business.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Story.dart';
import 'package:salon_app/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Extensions.dart';
import 'CreateStoryScreen.dart';
import 'StoriesScreen.dart';
import 'edits/EditBusnissScreen.dart';
import 'orderSteps/ServiceScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _darkModeEnabled = false;
  bool showMaxOrderPopup = false;

  var accessToken = "";
  Business business = DataManager.shared.business;

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  ImageProvider logoImage;
  ImageProvider coverImage;



  @override
  void initState() {
    getAccessToken();
    fetchData(false);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    check();
  }
  check(){
    logoImage =CachedNetworkImageProvider( domainName + "/images/medium/" + DataManager.shared.business.logo);
    coverImage =CachedNetworkImageProvider( domainName + "/storage/" + DataManager.shared.business.cover);
    precacheImage(logoImage, context);
    precacheImage(coverImage, context);
  }

  void _onRefresh() async{

     var d = await fetchData(true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    print("_onLoading");
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if(mounted)
      setState(() {
      });
    _refreshController.loadComplete();
  }

  fetchData(bool isRef) async {

    var data = await DataManager.shared.fetchActiveOrders({"business_id": Buissness_id});

    if (mounted) {
      setState(() {
        DataManager.shared.orders = DataManager.shared.orders;
      });
    }
    if (business == null || isRef == true) {

      if (mounted) {
        setState(() {
          DataManager.shared.stories = [];
        });
        }

      var x = await DataManager.shared.fetchService({"business_id": Buissness_id});
      Business business = await DataManager.shared.fetchHome(
          {"business_id": Buissness_id});
      if (mounted) {
        setState(() {
          this.business = business;
          DataManager.shared.stories = DataManager.shared.stories;
        });
      }
    }
    return 1;

  }

  getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("api_token");
    if (token != null) {
      accessToken = token;
    }
  }

  @override
  Widget build(BuildContext context) {
    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var name = (DataManager.shared.user != null && DataManager.shared.user.name != null) ? DataManager.shared.user.name : "";
    var title = name + " " + language["hi_u"];
    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              child: SizedBox()
            ),
            Text(title , style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _darkModeEnabled ? Colors.white : Colors.black,
                fontSize: 17,
                fontFamily: DataManager.shared.fontName()),),
            InkWell(onTap: () =>
            {
              print(123)
            },
                child: InkWell(
                  onTap: (){
                    if (DataManager.shared.user == null){
                      Navigator.of(context).push(_createRoute(false));
                    }else{
                      MenuView(context: context,callback: (){
                        fetchData(true);
                      }).presentMenu();
                    }

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
                ) //Image.asset("assets/images/editProfile.png",color: Colors.black,)
            )
          ],
        ),
      ),
      centerTitle: true,
    );

    return Scaffold(
        appBar: appBar,
        backgroundColor: _darkModeEnabled
            ? Colors.black.withOpacity(0.9)
            : Color(0xffF1F1F1),
        body: Stack(
          children: [
            SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: WaterDropHeader(),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 4, //users.length,
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return _headerView();
                    } else if (idx == 1) {
                      return _storiesView();
                    } else if (idx == 2) {
                      return _infoView();
                    } else if (idx == 3) {
                      return _footerView();
                    } else if (idx == 4) {
                      return Center(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("1.1.2",style: TextStyle(color: Colors.red),),
                              DataManager.shared.token == null ? Text("token empty") : Text("token is ${DataManager.shared.token}")
                            ],
                          ),
                        ),
                      );
                    }
                    return _headerView();
                  }
              ),
            ),
            showMaxOrderPopup ? _maxOrderPopup() : SizedBox(),
            DataManager.shared.user != null && DataManager.shared.user.suspended ? _userBlockedPopup() : SizedBox()
          ],
        )
    );
  }

  _headerView() {
    var size = MediaQuery
        .of(context)
        .size;

    var imageSize = size.width * 0.27;
    return Container(
      width: size.width,
      height: size.height * 0.7, //edit
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                width: size.width,
                height: (size.height * 0.7) * 0.6, //edit
                decoration: BoxDecoration(
                  color: _darkModeEnabled ?  Color(0xff121416) : Color(0xffF1F1F1),//Color(0xff1F1D1E),//Colors.black.withOpacity(0.95),
                  image:  DecorationImage(
                    image: coverImage,
                    fit: BoxFit.cover
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: size.width,
                  color: _darkModeEnabled ?  Color(0xff121416) : Color(0xffF1F1F1),
                  child: Column(
                    children: [
                      SizedBox(height: imageSize / 2 + 5,),
                      Text(business != null ? business.name : "",
                        style: TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkModeEnabled ? Colors.white : Color(0xff121416),
                            fontFamily: DataManager.shared.fontName()),),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(child: Text(business != null ? business
                            .intro : "", maxLines: 2, textAlign: TextAlign
                            .center, style: TextStyle(fontSize: 16,
                            color: _darkModeEnabled ? Colors.white.withOpacity(
                                0.8) : Colors.black.withOpacity(0.7),
                            fontFamily: DataManager.shared.fontName()),)),
                      ),
                      SizedBox(height: 15,),

                      Container(
                        height: 42,
                        width: (size.width * 0.5),
                        decoration: BoxDecoration(
                            color: HexColor.fromHex(DataManager.shared.business.pColor),//_darkModeEnabled ? Colors.white : Colors
                                //.black.withOpacity(0.9),
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: FlatButton(
                          onPressed: () =>
                          {
                            if (DataManager.shared.orders.length >= 3 && DataManager.shared.user.role == Role.client) {
                              setState(() {
                                showMaxOrderPopup = true;
                              })
                            }else{
                              Navigator.of(context).push(_createRoute(false))
                            }

                          },
                          child: Text(
                            business != null ? language["order_now"] : "",
                            style: TextStyle(color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: DataManager.shared.fontName()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //edit
          Positioned(
              top: (size.height * 0.6) * 0.7 - (imageSize / 2),
              left: size.width * 0.5 - (imageSize / 2),
              child: Container(
                height: imageSize, width: imageSize, decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(imageSize / 2)),
                color: Colors.grey,
                image:  DecorationImage(

                    image: logoImage,

                    fit: BoxFit.cover
                ),
              ),
              )
          ),
          Positioned(bottom: 0,
              left: 0,
              child: Container(
                height: 1.5,
                width: size.width,
                color: _darkModeEnabled ? Colors.black : Colors.white,
              )
          )
        ],
      ),
    );
  }



  Route _createRoute(bool isStory,{int index}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
      isStory ?  StoriesScreen(index: index,) :
      DataManager.shared.user == null ? RegisterScreen(fromHome:true) : SelectOrderTypeScreen(),
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

  Route _createRouteEdit(screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
      screen,
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

  _storiesView() {
    var size = MediaQuery
        .of(context)
        .size;

    var user = DataManager.shared.user;
    print("[story]1");
    return user == null || (user != null && user.role == Role.client && DataManager.shared.stories.length == 0) ? SizedBox() : Container(

      color: _darkModeEnabled ? Color(0xff121416) : Color(0xffF1F1F1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: user != null  && user.role == Role.admin ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap:(){
                        Navigator.of(context).push(_createRouteEdit(EditBusnissScreen())).then((value) {
                          fetchData(true);
                        });
                      },
                      child: Text(language["edit_bus_home"], style: TextStyle(
                          color: HexColor.fromHex(DataManager.shared.business.pColor)
                              .withOpacity(0.8), fontSize: 14, fontFamily: DataManager.shared.fontName(),fontWeight: FontWeight.bold)),
                    ),
                    Text(language["last_stories"], style: TextStyle(
                        color: _darkModeEnabled ? Colors.grey : Colors.black
                            .withOpacity(0.8),fontWeight: FontWeight.bold ,fontSize: 16, fontFamily: DataManager.shared.fontName()))
                  ],
                )
                : Text(language["last_stories"], style: TextStyle(
                color: _darkModeEnabled ? Colors.grey : Colors.black
                    .withOpacity(0.8), fontSize: 16, fontFamily: DataManager.shared.fontName())),
          ),
          SizedBox(height: 10,),
          Container(
            height: size.width*0.27 + (size.width*0.135),
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ListView.builder(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: user == null ? DataManager.shared.stories.length : (user.role == Role.admin || user.role == Role.employee) ? DataManager.shared.stories.length + 1 : DataManager.shared.stories.length,
                  itemBuilder: (context, idx) {
                    print("[story]2");
                    var index =  DataManager.shared.user == null ? idx : ( (DataManager.shared.user.role == Role.admin || DataManager.shared.user.role == Role.employee) && idx > 0) ? idx-1 : idx;
                    Story story =  DataManager.shared.stories.length == 0 ? null : DataManager.shared.stories[index];
                    print("story.image");
                    return Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child:  InkWell(
                        onTap: (){
                          print(idx);
                          if (idx == 0 && user != null && (user.role == Role.admin || user.role == Role.employee)) {
                            Navigator.of(context).push(_createRouteEdit(CreateStoryScreen())).then((value) => fetchData(true));
                          }else{
                            DataManager.shared.viewStory(DataManager.shared.stories[index].id);
                            Navigator.of(context).push(_createRoute(true,index: index));
                          }
                        },
                        child: idx == 0 ? (user != null &&  (user.role == Role.admin || user.role == Role.employee)) ?
                        Container(
                            height: size.width/4, width: size.width*0.27, decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("+",style: TextStyle(fontSize: 30),),
                              Text(language["add_story"],style: TextStyle(fontFamily: DataManager.shared.fontName(),fontSize: 13),),
                            ],
                          ),
                        )

                            : Container(
                          height: size.width/4, width: size.width*0.27,
                          decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            // alignment: Alignment(-.2, 0),
                              image: CachedNetworkImageProvider(story.image),//"https://chalern-english.com/API/Dating/photos/photo_1608680864.318455.jpg") ,
                              fit: BoxFit.cover
                          ),
                        ),
                        ):Container(
                          height: size.width/3.2, width: size.width*0.27, decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            // alignment: Alignment(-.2, 0),
                              image: CachedNetworkImageProvider(story.image) ,
                              fit: BoxFit.cover
                          ),
                        ),
                        ),
                      ),
                    );
                  }
              ),
            ),
          ),
          SizedBox(height: 30,),

        ],
      ),
    );
  }

  _infoView() {
    return Container(
      color: _darkModeEnabled ? Color(0xff121416) : Color(0xffF1F1F1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(language["about_us"], textAlign: TextAlign.right,
                      style: TextStyle(
                          color: _darkModeEnabled ? Colors.grey : Colors.black
                              .withOpacity(0.8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: DataManager.shared.fontName())),
                  Text(business != null ? business.about : "",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: _darkModeEnabled ? Colors.white.withOpacity(
                              0.8) : Colors.black.withOpacity(0.95),
                          fontSize: 14,
                          fontFamily: DataManager.shared.fontName())),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(language["address"], textAlign: TextAlign.right,
                    style: TextStyle(
                        color: _darkModeEnabled ? Colors.grey : Colors.black
                            .withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: DataManager.shared.fontName())),
                Text(business != null ? business.address : "",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _darkModeEnabled
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.95),
                        fontSize: 14,
                        fontFamily: DataManager.shared.fontName())),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(language["job_hours"], textAlign: TextAlign.right,
                    style: TextStyle(
                        color: _darkModeEnabled ? Colors.grey : Colors.black
                            .withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: DataManager.shared.fontName())),
                Text(business != null ? business.working_days : "",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _darkModeEnabled
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.95),
                        fontSize: 14,
                        fontFamily: DataManager.shared.fontName())),
              ],
            ),
          )
        ],
      ),
    );
  }

  _footerView() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      color: _darkModeEnabled ? Color(0xff121416) : Color(0xffF1F1F1),
      child: Column(
        children: [
          SizedBox(height: 10,),
          business == null ? SizedBox() : business.social_links == null
              ? SizedBox()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: business.social_links.map<Widget>((e) {
              return InkWell(
                onTap: () {
                  print(e.type);
                  if (e.type == "waze"){
                    loc();
                  }else{
                    _launchURL(e.link);
                  }

                },
                child: _itemSocial(e),
              );
            }).toList(),
          ),
          SizedBox(height: 55,),
        ],
      ),
    );
  }

  _maxOrderPopup(){
    var size = MediaQuery.of(context).size;
    print(size);
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

                Text(language["max_order_message"] ,textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 22,fontFamily: DataManager.shared.fontName()),),

                Spacer(),
                Text(language["cancel"],style: TextStyle(fontFamily: DataManager.shared.fontName()),),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _userBlockedPopup(){
    var size = MediaQuery.of(context).size;
    print(size);
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: InkWell(
          onTap: (){

          },
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color:Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height:10),
                Text(language["user_block_message"] ,textAlign: TextAlign.right,style: TextStyle(color: Colors.black,fontSize: 18,fontFamily: DataManager.shared.fontName(),fontWeight: FontWeight.bold),),
                Spacer(),
                Text(language["cancel"],style: TextStyle(fontFamily: DataManager.shared.fontName()),),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _itemSocial(Social social) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Container(width: 45, height: 45,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22.5)),
            image: DecorationImage(
                image:AssetImage("assets/images/${social.type}.png")
        )
        ),
      ),
    );
  }
  _launchURL(String url) async {
    print("url is" );
    print(url);

    try {

      await launch(url);
    }
    on Exception catch(_) {
      throw 'Could not launch $url';
    }
  }

  loc(){
    var bus = DataManager.shared.business;
    var url = "https://waze.com/ul?ll=" + bus.latitude + "," + bus.longitude + "&navigate=yes&zoom=17";
    print(url);
    String mapRequest = url;
    _launchURL(mapRequest);

  }

  static Future<void> openMap(String latitude, String longitude, int flag) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query='+latitude+','+longitude;
    String appleUrl = 'https://maps.apple.com/?q='+latitude+','+longitude;
    if(flag ==1) {
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }

    }
    else {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        throw 'Could not open the map.';
      }

    }

  }


}




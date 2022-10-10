import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/home/ClientsListScreen.dart';
import 'package:salon_app/home/SelectLanguageScreen.dart';
import 'package:salon_app/home/edits/EditBusnissScreen.dart';
import 'package:salon_app/home/edits/EditUserScreen.dart';
import 'package:salon_app/home/edits/WebScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Menu.dart';
import 'package:salon_app/models/User.dart';
import 'package:salon_app/home/DeleteUserScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';



class MenuView {

  var context;
  Function callback;

  MenuView({this.context,this.callback});

  presentMenu() async{

    print("android 11");
    if (DataManager.shared.user == null) {
      print("user need auth");
      Navigator.of(context).push(_createRouteEdit(SigninScreen()));
      return;
    }

    print("android 2");

    var user = DataManager.shared.user;
    List<Menu> menuArray = List<Menu>();
    if (user.role != Role.admin) {
      menuArray = [
         Menu(index: 1,val: language["edit_user"],icon: Icon(Icons.perm_identity_rounded))
        ,Menu(index: 5,val:language["edit_order_menu"],icon: Icon(Icons.edit_outlined))
        ,Menu(index: -1,val: language["language"],icon: Icon(Icons.language))
        ,Menu(index: 2,val:language["who_we_are"],icon: Icon(Icons.help_outline_rounded))
        ,Menu(index: 3,val:language["privacy_"],icon: Icon(Icons.error_outline_rounded))
        ,Menu(index: 8,val:language["delete_user_label"],icon: Icon(Icons.delete))
        ,Menu(index: 4,val:language["logout"],icon: Icon(Icons.logout)),];
    }else{
      menuArray = [
        Menu(index: 0,val: language["edit_bus"],icon: Icon(Icons.business)),
        Menu(index: 1,val: language["edit_user"],icon: Icon(Icons.perm_identity_rounded)),
        Menu(index: 5,val:language["edit_order_menu"],icon: Icon(Icons.edit_outlined)),
        Menu(index: -1,val: language["language"],icon: Icon(Icons.language)),
        Menu(index: 2,val:language["who_we_are"],icon: Icon(Icons.help_outline_rounded)),
        Menu(index: 3,val:language["privacy_"],icon: Icon(Icons.error_outline_rounded)),
        Menu(index: 8,val:language["delete_user_label"],icon: Icon(Icons.delete)),
        Menu(index: 4,val:language["logout"],icon: Icon(Icons.logout)),];
    }

    if ( (user.role != Role.client)){
      menuArray.add(Menu(index: 6,val:language["clients"],icon: Icon(Icons.people)));
    }
    //var menuArray = [user.name +" "+ user.lastName,user.phone,"log out"];
    await showAdaptiveActionSheet(
      context: context,
      actions:  menuArray.map((e) => BottomSheetAction(
          trailing: e.icon,//e.index == 4 ? Icon(Icons.logout) : e.index == 3 ? Icon(Icons.edit_outlined) : Icon(Icons.edit_outlined),
          title: Text(e.val == null ? "" : e.val,textAlign: TextAlign.right,style:TextStyle(fontFamily: DataManager.shared.fontName(),color: Colors.black54,fontSize: 16)),
          onPressed: ()=>{
            if (Platform.isAndroid) {
                Navigator.of(context).pop(),
            } else if (Platform.isIOS) {
              Navigator.of(context, rootNavigator: true).pop('dialog'),
            },
            //Navigator.of(context, rootNavigator: true).pop('dialog'),
            if(e.index == 4) {
              _logout()
            }else if (e.index == 2){
              Navigator.of(context).push(_createRouteEdit(WebScreen(url: domainName + "/api/about",)))
            }else if (e.index == 3){
              Navigator.of(context).push(_createRouteEdit(WebScreen(url: domainName + "/api/terms-of-use",)))
            }else if (e.index == 1){
              Navigator.of(context).push(_createRouteEdit(EditUserScreen())).then((value) {if(callback != null){callback();}})
            }else if (e.index == 0){
              Navigator.of(context).push(_createRouteEdit(EditBusnissScreen())).then((value) {if(callback != null){callback();}})
            }else if (e.index == 5) {
              DataManager.shared.tabController.animateTo(3)
            }else if (e.index == 6) {
                  Navigator.of(context).push(_createRouteEdit(ClientsListScreen())).then((value) {if(callback != null){callback();}})
            }else if (e.index == -1) {
                  Navigator.of(context).push(_createRouteEdit(SelectLanguageScreen())).then((value) {if(callback != null){callback();}})
            }
            else if (e.index == 8){
                Navigator.of(context).push(_createRouteEdit(Delete_User_Screen())).then((value) {if(callback != null){callback();}})

              }


          }
      )).toList(),
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

  _logout() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("api_token");
    DataManager.shared.user = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SigninScreen(),
      ),
          (route) => false,
    );
  }
}
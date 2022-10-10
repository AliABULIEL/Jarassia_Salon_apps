
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:shared_preferences/shared_preferences.dart';


Map<String, dynamic> language;


class DemoLocalizations {
  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  String getText(String key) => language[key];
}



class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['he', 'ar','en'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) async {

    var fileName = locale.languageCode;
    if (fileName == "en" || isSupported(locale) == false){
      fileName = 'he';
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var lan = prefs.get("lan");
    if (lan != null) {
      fileName = lan;
    }
    DataManager.shared.lan=fileName;
    // print("locale");
    // print(fileName);
    // print(locale);

    String string = await rootBundle.loadString("assets/strings/${fileName}.json");
    print("rootBundle*****");
    print(string);
    language = json.decode(string);
   // DataManager.shared.fetchStrings();
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations());
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
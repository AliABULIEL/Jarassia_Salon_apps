import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:async';

class WebScreen extends StatefulWidget{

  String url;
  WebScreen({this.url});

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  bool _darkModeEnabled = false;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

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
      title: Text("",style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
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
      body: Container(
        child: WebView(
          initialUrl: widget.url,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
            navigationDelegate: (NavigationRequest request) {
      if (request.url.startsWith('https://www.youtube.com/')) {
      print('blocking navigation to $request}');
      return NavigationDecision.prevent;
      }
      print('allowing navigation to $request');
      return NavigationDecision.navigate;
      },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        gestureNavigationEnabled: true,

        ),
      ),
    );
  }
}
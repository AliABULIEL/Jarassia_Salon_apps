import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CreditCardWebView extends StatefulWidget {

  String url;
  bool isFromOrder;
  CreditCardWebView({this.url,this.isFromOrder});

  @override
  _CreditCardWebViewState createState() => _CreditCardWebViewState();
}

class _CreditCardWebViewState extends State<CreditCardWebView> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled =  qdarkMode == Brightness.dark;


    var appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white:Colors.black, //change your color here
      ),
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      //title: Text(language["my_cart"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              child:  InkWell(onTap: ()=>{
                if (widget.isFromOrder ) {
                  Navigator.of(context).popUntil((route) => route.isFirst)
                }else{
                  Navigator.pop(context)
                }
              }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
              ),
            )
          ],
        )
      ],

    );


    return Scaffold(
      appBar: appBar,
      body: Container(
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/Signin/SigninScreen.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Product.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:salon_app/shop/MyCartScreen.dart';

import '../Extensions.dart';



class ProductInfoScreen extends StatefulWidget {

  Product product;

  ProductInfoScreen({this.product});


  @override
  _ProductInfoScreenState createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {

  bool _darkModeEnabled = false;
  bool isLoading = false;

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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(_createRoute());
            },
            child: Container(
              width: 40,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.shopping_cart,
                    color: _darkModeEnabled ? Colors.white : Colors
                        .black,),
                ],
              ),
            ),
          ),
          Text(language["products"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
          Container(
            width: 40,
            height: 40,
            child: InkWell(onTap: ()=>{
              Navigator.pop(context)
            }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
            ),
          )
        ],
      ),
      centerTitle: true,
    );

    return Scaffold(
        backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
        appBar: appBar,
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _headerView(size) ,
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.name,style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${widget.product.price}₪",style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                          ],
                        ),
                        Text(widget.product.description,style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.grey,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _addCartButton()
                          ],
                        )

                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  _headerView(Size size){
    return Container(
      width: size.width,
      height: size.height * 0.45,
      color: Colors.red,
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          return Container(
            decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
                image:CachedNetworkImageProvider(domainName + "/images/original/" + widget.product.images[index]),
                fit: BoxFit.cover
            ),
          ),
          );
        },
        itemCount: widget.product.images.length,
        pagination: new SwiperPagination(builder:DotSwiperPaginationBuilder(activeColor: HexColor.fromHex(DataManager.shared.business.pColor))),
        control: new SwiperControl(color: Colors.black),
      ),
    );
  }

  _addCartButton(){
    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      height: 50,
      width: (size.width * 0.8)  ,
      decoration: BoxDecoration(
          color:HexColor.fromHex(DataManager.shared.business.pColor),
          borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: FlatButton(
        onPressed: ()=>{
            if (isLoading == false){
              addToCart()
            }
        },
        child: Text(
          language["add_to_cart"],
          style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
        ),
      ),
    );
  }
  
  addToCart() async{

    if (DataManager.shared.user == null){
      Navigator.of(context).push(_createRoute());
      return;
    }
    isLoading = true;
    var added = await DataManager.shared.addToCart({"product_id":"${widget.product.id}"});
    isLoading = false;
    final snackBar = SnackBar(
      content: Text(language["added_to_cart_success"]),
      action: SnackBarAction(
        label: '',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => DataManager.shared.user == null ? SigninScreen(fromHome:true) : MyCartScreen(),
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
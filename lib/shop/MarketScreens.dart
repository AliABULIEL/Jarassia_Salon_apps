import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/home/widgets/menu.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Product.dart';
import 'package:salon_app/models/ProductGroups.dart';
import 'package:salon_app/shop/MyCartScreen.dart';
import 'package:salon_app/shop/ProductInfoScreen.dart';

import 'MyOrdersScreen.dart';


class MarketScreens extends StatefulWidget {
  ProductGroups productGroup ;

  MarketScreens(this.productGroup);



  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreens> {
  bool _darkModeEnabled = false;
  bool isLoading = false;
  int indexHeaderSelected = 0;
  List<Product> products = new List<Product>();


  @override
  void initState() {
    fetchProducts();
    fetchMyProducts();
    super.initState();
  }

  fetchProducts() async{
    isLoading = true;
    var products = await DataManager.shared.getProducts(widget.productGroup.id);
    setState(() {
      products = products;
      isLoading = false;
    });

    print(products.length);
  }

  fetchMyProducts() async{
    // isLoading = true;
    // var products = await DataManager.shared.getProducts();
    // setState(() {
    //   products = products;
    //   isLoading = false;
    // });
    //
    // print(products.length);
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    var qdarkMode = MediaQuery.of(context).platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var appBar = AppBar(
      elevation: 0,
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      backgroundColor: _darkModeEnabled ? Colors.black : Colors.white,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart, color: _darkModeEnabled ? Colors.white : Colors.black,),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  language["select_product"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _darkModeEnabled ? Colors.white : Colors.black,
                    fontSize: 17,
                    fontFamily: DataManager.shared.fontName(),
                  ),
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu, color: _darkModeEnabled ? Colors.white : Colors.black,),
                ],
              ),
            ),
          ],
        )



      ),

      centerTitle: true,

    );
    return Scaffold(
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.9) : Color(0xffF5F5F5),
      appBar: appBar,
      body: (isLoading == false && DataManager.shared.products.length == 0) ?
      Center(
        child:Text(language["product_empty"],style: TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
      )
          : Column(
        children: [
          _headerView(),
          this.indexHeaderSelected == 1 ? Expanded(child: MyOrdersScreen()) :
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(4.0),
              childAspectRatio: 8.0/10.0,
              children: DataManager.shared.products.map((e) => itemList(e)).toList(),
            ),
          ),
        ],
      ),
    );


  }

  _headerView(){
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(onTap: (){
            setState(() {
              indexHeaderSelected = 0;
            });
          }, child: Container(child: Text(language["products"],style: TextStyle(fontSize: 19,color: indexHeaderSelected == 0 ? _darkModeEnabled ? Colors.white : Colors.black : Colors.grey,fontFamily: DataManager.shared.fontName()),))),
          SizedBox(width: 110,),
          InkWell(onTap: (){
            setState(() {
              indexHeaderSelected = 1;
            });
          }, child: Container( child: Text(language["my_orders"],style: TextStyle(fontSize: 19,color: indexHeaderSelected == 1 ? _darkModeEnabled ? Colors.white : Colors.black : Colors.grey,fontFamily: DataManager.shared.fontName()),))),
          SizedBox(width: 110,),
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
    );
  }

  Widget itemList(Product product){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: (){
          Navigator.of(context).push(_createRoute(product:product));
        },
        child: Container(
          decoration:  product.images.length == 0 ? null : BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                image:CachedNetworkImageProvider(domainName + "/images/small/" + product.images.first),
                fit: BoxFit.cover
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(

                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.name,style: TextStyle(color: Colors.white,fontFamily: DataManager.shared.fontName()),),
                        SizedBox(height: 5,),
                        Text("${product.price}₪",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                      ],
                    ),
                  ),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute({Product product,bool isCart = false}) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => isCart ? MyCartScreen() : ProductInfoScreen(product: product,),
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
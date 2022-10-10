import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Product.dart';

import '../Extensions.dart';


class MyCartScreen extends StatefulWidget {

  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  bool _darkModeEnabled = false;
  bool isLoading = false;
  int totalCount = 0;
  List<Cart> cartList = new List<Cart>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async{
    var carl = await DataManager.shared.getMyCart();
    setState(() {
      cartList = carl;
    });
    checkTotal();
  }

  checkTotal(){
    var t = 0;
    this.cartList.forEach((element) {
      t += element.price*element.quantity;
    });
    setState(() {
      this.totalCount = t;
    });
  }

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
      title: Text(language["my_cart"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      centerTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              child:  InkWell(onTap: ()=>{
                Navigator.pop(context)
              }, child: Icon(Icons.arrow_forward_ios,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
              ),
            )
          ],
        )
      ],

    );

    return Scaffold(
      appBar:appBar,
      backgroundColor: _darkModeEnabled ? Color(0xff252322) : Color(0xffF1F1F1),
      body: (isLoading == false && cartList.length == 0 )  ? Center(child:
      Text(language["cart_empty"],style: TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),

          ): Container(
        child: SingleChildScrollView(
          child: Column(
            children: this.cartList.map((e) {
              return itemCell(e);
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: cartList.length == 0 ? SizedBox() :
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 100,
          child: Column(
            children: [
              Divider(height: 1,),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("${totalCount}₪",style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                  Text(language["total"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 45,
                width:  double.infinity,
                decoration: BoxDecoration(
                    color:HexColor.fromHex(DataManager.shared.business.pColor),
                    borderRadius: BorderRadius.all(Radius.circular(22.5))
                ),
                child: FlatButton(
                  onPressed: ()=>{
                    if(isLoading == false) {
                       submitProduct()
                    }
                  },
                  child: Text(
                    language["submit"],
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

  Widget itemCell(Cart cart) {
    var size =  MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
          color: !_darkModeEnabled ? Colors.white:Colors.black45,
          borderRadius: BorderRadius.circular(5),

        ),
        child:  Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5,),
                Container(
                  width: 40,
                  height: 40,
                  child:  InkWell(onTap: ()=>{
                    this.deleteItem(cart)

                  }, child: Icon(Icons.cancel,color: _darkModeEnabled ? Colors.white:Colors.black,)//Image.asset("assets/images/editProfile.png",color: Colors.black,)
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: size.width * 0.2,
                      height: size.width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image:CachedNetworkImageProvider(domainName + "/images/small/" +cart.image),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cart.name,style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),
                    Text("${cart.price*cart.quantity}₪",style: TextStyle(color: Colors.grey,fontSize: 15,fontFamily: DataManager.shared.fontName()),)
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${cart.quantity}",style: TextStyle(color: Colors.grey,fontSize: 16,fontFamily: DataManager.shared.fontName()),)
                      ],
                    ),
                  ),
                )

              ],
            ),
          ],
        ),
      ),
    );

  }



  deleteItem(Cart cart){
    DataManager.shared.removeFromCart({"product_id":cart.id});
    setState(() {
      this.cartList.removeWhere((element) => element.id == cart.id);
    });
    checkTotal();

  }

  submitProduct() async{
    isLoading = true;
    var sub = await DataManager.shared.submitCart({"":""});
    isLoading = false;
    setState(() {
      this.cartList = [];
    });
    Navigator.pop(context);
  }


}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Product.dart';
import 'package:group_list_view/group_list_view.dart';

class MyOrdersScreen extends StatefulWidget{
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {

  bool _darkModeEnabled = false;
  bool isLoading = false;
  List<UserOrder> myOrders = new List<UserOrder>();


  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async{
    isLoading = true;
    var orders = await DataManager.shared.getMyOrders();
    isLoading = true;
    setState(() {
      this.myOrders = orders;
      DataManager.shared.myOrders = orders;
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
      title: Text(language["product_empty"],style: TextStyle(color: _darkModeEnabled ? Colors.white : Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
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
        //appBar:appBar,
        backgroundColor: _darkModeEnabled ? Color(0xff252322) : Color(0xffF1F1F1),
    body: (isLoading == false && DataManager.shared.myOrders.length == 0 )  ? Center(child:
    Text(language["cart_empty"],style: TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: DataManager.shared.fontName()),),

    ): Container(
      child: GroupListView(
        sectionsCount: DataManager.shared.myOrders.length,
        countOfItemInSection: (int section) {
          return DataManager.shared.myOrders[section].items.length;
        },
        itemBuilder: _itemBuilder,
        groupHeaderBuilder: (BuildContext context, int section) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(DataManager.shared.myOrders[section].stringDate,style: TextStyle(color: Colors.grey),)
                  ],
                ),
              ),
            );
       },
        sectionSeparatorBuilder: (context, section) => SizedBox(),
    ),
    )
    );
  }

  Widget _itemBuilder(BuildContext context, IndexPath index) {
    var cart = DataManager.shared.myOrders[index.section].items[index.index];
    return itemCell(cart);
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


}
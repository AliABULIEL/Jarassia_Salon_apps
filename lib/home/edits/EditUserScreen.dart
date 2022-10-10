import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Extensions.dart';




class EditUserScreen extends StatefulWidget{

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {

  Future<File> imageFile;
  String base64Image;
  File tmpFile;
  final picker = ImagePicker();

  String url;

  bool _darkModeEnabled = false;

  var selectLanguage = -1;

  var isLoading = false;
  var type = 0;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();


  @override
  void dispose() {

    _controllerName.dispose();
    _controllerLastName.dispose();
    _controllerPhone.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    AppBar appBar = AppBar(
      elevation: 0,
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
      title: Text(language["edit_user"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      leading: IconButton(
        icon: Icon(Icons.close, color: _darkModeEnabled ? Colors.white : Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );

    var size = MediaQuery
        .of(context)
        .size;
    var user = DataManager.shared.user;
    if (_controllerPhone.text.length  == 0) {_controllerPhone.text = user.phone;}
    if (_controllerName.text.length  == 0) {_controllerName.text = user.name;}
    if (_controllerLastName.text.length  == 0) {_controllerLastName.text = user.lastName;}

    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(height: 15,),
                  _image(),
                  SizedBox(height: 15,),
                  _textField(language["main_name"],_controllerName),
                  SizedBox(height: 15,),
                  _textField(language["last_name"],_controllerLastName),
                  SizedBox(height: 15,),
                  _textField(language["phone_number"],_controllerPhone),
                  // SizedBox(height: 15,),
                  // _languageList(),
                  SizedBox(height: 15,),
                  _saveButton()
                ],
              ),
            ),
          ),
          type != 0 ? _loading() : SizedBox(),
          type == 2 ? _alertView() : SizedBox()

        ],
      ),

    );
  }

  _image(){
    var user = DataManager.shared.user;
    var size = MediaQuery
        .of(context)
        .size;
    print(1111111111);
    print(user.image);
    return ClipOval(
      child: InkWell(
        onTap: (){
          pickImageFromGallery(ImageSource.gallery);
        },
        child: this.tmpFile != null ? Container(
          child: getImage(
              size.width * 0.3,size.width * 0.3 ,
              tmpFile),//showImage(size.width * 0.3,size.width * 0.3 ,imageFile,tmpFile),
        ) : Container(
          height: size.width * 0.3,
          width: size.width * 0.3,
            decoration: BoxDecoration(
              color: _darkModeEnabled ?  Color(0xff121416) : Color(0xffF1F1F1),//Color(0xff1F1D1E),//Colors.black.withOpacity(0.95),
              image: user.image == null ?  null : DecorationImage(
                  image:CachedNetworkImageProvider(domainName + "/images/large/" + user.image),
                  fit: BoxFit.cover
              ),
            ),
          child: Icon(
            Icons.camera_alt,
            color:HexColor.fromHex(DataManager.shared.business.pColor),
            size:25,
        ),
        ),
      ),
    );
  }

  _textField(String placeHolder,TextEditingController controller) {

    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: size.width * 0.9,
      height: 50,
      decoration: BoxDecoration(
        color: _darkModeEnabled?Colors.black:Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
            width: 1,
            color: Colors.grey.withOpacity(0.3)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8,right: 8),

        child: TextFormField(
          controller: controller,
          style: TextStyle(color: _darkModeEnabled?Colors.white:Colors.black,),
          decoration: InputDecoration(
            // labelText: text,
              hintText: placeHolder,
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey,fontFamily: "Heebo")
          ),
          textAlign:TextAlign.right,
        ),
      ),
    );
  }

  _languageList(){
    var size = MediaQuery
        .of(context)
        .size;

    return Container(
      height: 70,
      width: size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                this.selectLanguage = 0;
              });
            },
            child: _langaugeCell(language["arabic"],0),
          ),
           SizedBox(width: 10,),
          InkWell(
            onTap: (){
              setState(() {
                this.selectLanguage = 1;
              });
            },
            child: _langaugeCell(language["hebrew"],1),
          ),
           SizedBox(width: 10,),
          // InkWell(
          //   onTap: (){
          //     setState(() {
          //       this.selectLanguage = 2;
          //     });
          //   },
          //   child: _langaugeCell(language["english"],2),
          // ),
        ],
      ),
    );
  }

  _langaugeCell(name,index){
    var size = MediaQuery
        .of(context)
        .size;

    return Container(
      width: size.width * 0.25,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          width: 2,
          color: selectLanguage == index ?HexColor.fromHex(DataManager.shared.business.pColor):Colors.grey
        )
      ),
      child: Center(child:
      Text(name,style:TextStyle(color: selectLanguage == index ? HexColor.fromHex(DataManager.shared.business.pColor):Colors.grey,fontSize: 16,fontFamily: DataManager.shared.fontName()),),
      ),
    );
  }

  pickImageFromGallery(ImageSource source) async {
    var tmpF =  await picker.pickImage(source: source,
        imageQuality: 50, // <- Reduce Image quality
        maxHeight: 500,  // <- reduce the image size
        maxWidth: 500);

    setState(() {
      tmpFile = File(tmpF.path);
    });
    print(33333);
    getUrl();
  }

  getUrl(){
    if (tmpFile == null) {
      print("tmp file is null");
      return;
    }

    DataManager.shared.uploadImage(tmpFile,{"business_id": Buissness_id},(url)=>{
    print("url-${url}"),
      this.url = url
    });
  }

  getImage(width,height,tmpFile){

    return Image.file(
      tmpFile,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  _saveButton(){
    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      height: 50,
      width: (size.width * 0.9) * 0.6  ,
      decoration: BoxDecoration(
          color:HexColor.fromHex(DataManager.shared.business.pColor),
          borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: FlatButton(
        onPressed: ()=>{
          _save()
        },
        child: Text(
          language["save"],
          style: TextStyle(color: Colors.white,fontSize: 17,fontFamily: DataManager.shared.fontName()),
        ),
      ),
    );
  }

  _save() async{

    var user = DataManager.shared.user;
    var first = _controllerName.value.text ?? user.name;
    var last = _controllerLastName.value.text ?? user.lastName;
    var phone = _controllerPhone.value.text ?? user.phone;
    var map = {"first_name":first,"last_name":last};
    if (phone != user.phone) {
      map.addAll({"phone":phone});
    }
    if (this.url != null) {
      map["image"] = this.url;
      user.image = this.url;
    }
    user.name = first;
    user.lastName = last;
    user.phone = phone;
    print(map);
    _showLoadingAlert();
    DataManager.shared.editUser(map);
    _showSuccesAlert();
  }

  _showLoadingAlert(){
    setState(() {
      type = 1;
      isLoading = true;
    });
    // CoolAlert.show(
    //   context: context,
    //   type: CoolAlertType.loading,
    //   barrierDismissible: false,
    // );
  }

  _showSuccesAlert(){
    Future.delayed(const Duration(seconds: 2), () {

      setState(() {
        type = 2;
      });

      //       Navigator.of(context).popUntil((route) => route.isFirst);

      // Navigator.of(context, rootNavigator: true).pop('dialog');
      // CoolAlert.show(
      //     context: context,
      //     type: CoolAlertType.success,
      //     barrierDismissible: false,
      //     onConfirmBtnTap: () {
      //       Navigator.of(context, rootNavigator: true).pop('dialog');
      //       Navigator.of(context).popUntil((route) => route.isFirst);
      //     }
      // );
    });
  }

  _loading(){
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: type !=2 ? SizedBox() : Container(
        width: size.width,
        height: size.height,
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Text("Success",style: TextStyle(color: Colors.white,fontSize: 22),),
        ),
      ),
    );
  }

  _alertView(){
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: InkWell(
          onTap: (){
            if (type == 2) {
              isLoading = false;
              type = 0;
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: type != 2 ? SizedBox() : Container(
            width: size.width * 0.65,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color:Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height:10),
                Text(type == 2 ? language["edit_mess"] : "Loading...",style: TextStyle(color: Colors.black,fontSize: 22),),
                Spacer(),
                type == 2 ? Text(language["done"]) : SizedBox(),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
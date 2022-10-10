import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:salon_app/models/DemoLocalizations.dart';

import '../../Extensions.dart';


class EditBusnissScreen extends StatefulWidget{

  @override
  _EditBusnissScreenState createState() => _EditBusnissScreenState();
}

class _EditBusnissScreenState extends State<EditBusnissScreen> {
  bool _darkModeEnabled = false;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerAbout = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerGlance = TextEditingController();
  final TextEditingController _controllerJobHours = TextEditingController();
  final TextEditingController _controllerFacebook = TextEditingController();
  final TextEditingController _controllerInstagram = TextEditingController();
  final TextEditingController _controllerWhatsapp = TextEditingController();
  final TextEditingController _controllerWebsite = TextEditingController();

  String urlCover;
  String urlLogo;
  Image image;
  String base64Image;
  File tmpFile;

  var isLoading = false;
  var type = 0;

  Image imageLOGO;
  String base64ImageLOGO;
  File tmpFileLOGO;
  final picker = ImagePicker();

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerAbout.dispose();
    _controllerAddress.dispose();
    _controllerGlance.dispose();
    _controllerJobHours.dispose();
    _controllerFacebook.dispose();
    _controllerInstagram.dispose();
    _controllerWhatsapp.dispose();
    _controllerWebsite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var business = DataManager.shared.business;

    if (_controllerName.text.length == 0) {_controllerName.text =  business.name;}
    if (_controllerAddress.text.length == 0) {_controllerAddress.text =  business.address;}
    if (_controllerGlance.text.length == 0) {_controllerGlance.text =  business.intro;}
    if (_controllerJobHours.text.length == 0) {_controllerJobHours.text =  business.working_days;}
    if (_controllerFacebook.text.length == 0) {_controllerFacebook.text =  business.getSocialLink("facebook");}
    if (_controllerInstagram.text.length == 0) {_controllerInstagram.text =  business.getSocialLink("instagram");}
    if (_controllerWhatsapp.text.length == 0) {_controllerWhatsapp.text =  business.getSocialLink("whatsapp");}
    if (_controllerWebsite.text.length == 0) {_controllerWebsite.text =  business.getSocialLink("website");}
    if (_controllerAbout.text.length == 0) {_controllerAbout.text =  business.about;}


    AppBar appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
      title: Text(language["edit_bus"],style: TextStyle(color: _darkModeEnabled ? Colors.white:Colors.black,fontSize: 17,fontFamily: DataManager.shared.fontName()),),
      leading: IconButton(
        icon: Icon(Icons.close, color: _darkModeEnabled ? Colors.white : Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
    return Scaffold(
      appBar: appBar,
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                _headerView(),
                 SizedBox(height: 10,),
                _textField(language["business_name"],business.name,this._controllerName,50),
                SizedBox(height: 10,),
                _textField(language["glance"],business.intro,this._controllerGlance,50),
                SizedBox(height: 10,),
                _textField(language["about_us"],business.about,this._controllerAbout,50),
                SizedBox(height: 10,),
                _textField(language["address"],business.address,this._controllerAddress,50),
                SizedBox(height: 10,),
                _textField(language["job_hours"],business.working_days,this._controllerJobHours,200),
                SizedBox(height: 10,),
                // _textField(language["facebook"],business.getSocialLink("facebook"),this._controllerFacebook),
                // SizedBox(height: 10,),
                // _textField(language["insta"],business.getSocialLink("instagram"),this._controllerInstagram),
                // SizedBox(height: 10,),
                // _textField(language["whatsapp"],business.getSocialLink("whatsapp"),this._controllerWhatsapp),
                // SizedBox(height: 10,),
                // _textField(language["website"],business.getSocialLink("website"),this._controllerWebsite),
                //SizedBox(height: 15,),
                _saveButton(),
                SizedBox(height: 50,),

              ],
            ),
            type != 0 ? _loading() : SizedBox(),
            type == 2 ? _alertView() : SizedBox()

          ],
        ),
      ),
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

  _textField(String placeHolder,String text,TextEditingController controller,double height) {

    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: size.width * 0.9,
      height: height,
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

  _headerView() {
    var size = MediaQuery
        .of(context)
        .size;
    var business = DataManager.shared.business;
    var imageSize = size.width * 0.27;
    return Container(
      width: size.width,
      height: (size.height * 0.6) * 0.4 + (imageSize / 2) + 15, //edit
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: (){
                  print(13);
                  pickImageFromGallery(ImageSource.gallery);
                },
                child: this.tmpFile != null ? Container(
                  child: getImage(size.width,(size.height * 0.6) * 0.4 ,tmpFile),
                ) : Container(
                  width: size.width,
                  height: (size.height * 0.6) * 0.4, //edit
                  decoration: BoxDecoration(
                    color: _darkModeEnabled ?  Color(0xff121416) : Color(0xffF1F1F1),//Color(0xff1F1D1E),//Colors.black.withOpacity(0.95),
                    image:  DecorationImage(
                        image:CachedNetworkImageProvider(domainName + "/storage/" + business.cover),
                        fit: BoxFit.cover
                    ),
                  ),
                  child:Icon(
                    Icons.camera_alt,
                    color:HexColor.fromHex(DataManager.shared.business.pColor),
                    size:25,
                  ),
                ),
              ),

            ],
          ),
          //edit
          Positioned(
              top: (size.height * 0.6) * 0.4 - (imageSize / 2),
              left: size.width * 0.5 - (imageSize / 2),
              child: InkWell(
                onTap: (){
                  print(1333);
                  pickImageFromGalleryLOGO(ImageSource.gallery);
                },
                child:  this.tmpFileLOGO != null ?  ClipOval(
                  child: Container(
                    child: getImage(imageSize,imageSize,tmpFileLOGO),
                  ),
                ): Stack(
                  children: [
                    Container(
                      height: imageSize, width: imageSize,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(imageSize / 2)),
                      color: Colors.grey,
                      image:  DecorationImage(

                          image:CachedNetworkImageProvider(domainName + "/images/medium/" + DataManager.shared.business.logo),

                          fit: BoxFit.cover
                      ),

                    ),
                    ),

                    Positioned(
                      left: 4,
                      bottom: 4,
                      child:Icon(
                        Icons.camera_alt,
                        color:HexColor.fromHex(DataManager.shared.business.pColor),
                        size:25,
                      ),
                    ),
                  ],
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

  pickImageFromGallery(ImageSource source) async {

    var tmpF =  (await picker.pickImage(source: source,imageQuality: 80,maxHeight: 500,maxWidth: 500));
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
    print("get URL");
    DataManager.shared.uploadImage(tmpFile,{"":""},(url)=>{
      this.urlCover = url
    });
  }

  pickImageFromGalleryLOGO(ImageSource source)  async {
    var tmpF =  (await picker.pickImage(source: source,imageQuality: 80,maxHeight: 500,maxWidth: 500));

    setState(() {
      tmpFileLOGO = File(tmpF.path);
    });
    print(33333);
    getUrlLOGO();
  }

  getUrlLOGO(){
    if (tmpFileLOGO == null) {
      print("tmp file is null");
      return;
    }

    DataManager.shared.uploadImage(tmpFileLOGO,{"":""},(url)=>{
      this.urlLogo = url
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

  _save(){

    var business = DataManager.shared.business;

    var name = _controllerName.value.text ?? business.name;
    var about = _controllerAbout.value.text ?? business.about;
    var address =  _controllerAddress.value.text ?? business.address;
    var glance = _controllerGlance.value.text ?? business.intro;
    var hours = _controllerJobHours.value.text ?? business.working_days;
    var face = _controllerFacebook.value.text ?? business.getSocialLink("facebook");
    var insta = _controllerInstagram.value.text ?? business.getSocialLink("instagram");
    var whats = _controllerWhatsapp.value.text ?? business.getSocialLink("whatsapp");
    var web =  _controllerWebsite.value.text ?? business.getSocialLink("website");

    var cover =  this.urlCover ?? business.cover;
    var logo =  this.urlLogo  ?? business.logo;

    var map = {
      "name": name,
      "intro": glance,
      "about": about,
      "address": address,
      "working_days": hours,
      "logo": logo,
      "cover": cover,
      "facebook": face,
      "whatsapp": whats,
      "instagram": insta,
      "website": web
    };

    print(map);
    print("zzzzzzzzzzzzzz");
    business.working_days = hours;
    business.name = name;
    business.about = about;
    business.intro = glance;
    business.address = address;
    business.logo = logo;
    business.cover = cover;
    _showLoadingAlert();
    DataManager.shared.editBusiness(map);
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
        isLoading = true;
      });
    });


    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   CoolAlert.show(
    //       context: context,
    //       type: CoolAlertType.success,
    //       barrierDismissible: false,
    //       onConfirmBtnTap: () {
    //         Navigator.of(context, rootNavigator: true).pop('dialog');
    //         Navigator.of(context).popUntil((route) => route.isFirst);
    //       }
    //   );
    // });
  }

  _loading(){
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){

      },
      child: type !=2 ? SizedBox() : Container(
        width: size.width,
        height: size.height,
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Text("Success",style: TextStyle(color: Colors.white,fontSize: 22,fontFamily: DataManager.shared.fontName()),),
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
                Text(type == 2 ? language["edit_mess"] : "...",style: TextStyle(color: Colors.black,fontSize: 22),),
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
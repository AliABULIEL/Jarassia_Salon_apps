import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'dart:convert';

import 'package:salon_app/models/DemoLocalizations.dart';
import 'package:salon_app/models/Story.dart';

import '../Extensions.dart';


class CreateStoryScreen extends StatefulWidget {

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {

  var url = '';
  var error = false;
  Image image;
  File imageFile;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  bool isLoading = false;
  bool _darkModeEnabled = false;
  var picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async{

  }

  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    AppBar appBar = AppBar(
      brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
      automaticallyImplyLeading: false,
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
      backgroundColor: _darkModeEnabled ?  Color(0xff121416) : Color(0xffF1F1F1),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 80,),
              Text(
                "" ,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 19,fontFamily: DataManager.shared.fontName()),textAlign: TextAlign.center,
              ),
              SizedBox(height: 30,),


              Center(
                child: Column(
                  children:[
                    Container(
                      width: MediaQuery.of(context).size.width*0.6,height: MediaQuery.of(context).size.width*0.6,
                      decoration: BoxDecoration(
                        color: _darkModeEnabled ? Colors.black : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.grey
                        )
                      ),
                      child:  showImage(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,),
              error == false ? SizedBox() : Text("error_image",style: TextStyle(color: Colors.red),),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 5,),
                  Container(
                    height: 42,
                    width: (200),
                    decoration: BoxDecoration(
                        color: HexColor.fromHex(DataManager.shared.business.pColor),//_darkModeEnabled ? Colors.white : Colors
                        //.black.withOpacity(0.9),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: () =>
                      {
                        pickImageFromCamera(ImageSource.camera)
                      },
                      child: Text(language["camera"],
                        style: TextStyle(color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: DataManager.shared.fontName()),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: 42,
                    width: (200),
                    decoration: BoxDecoration(
                        color: HexColor.fromHex(DataManager.shared.business.pColor),//_darkModeEnabled ? Colors.white : Colors
                        //.black.withOpacity(0.9),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: FlatButton(
                      onPressed: () =>
                      {
                        pickImageFromGallery(ImageSource.gallery)
                      },
                      child: Text(language["gallery"],
                        style: TextStyle(color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: DataManager.shared.fontName()),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
          this.tmpFile == null ? SizedBox() : Positioned(
            bottom: 20,
            left: 30,
            right: 30,
            child: SafeArea(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,// * 0.9,
                  height: 45,
                  child: FlatButton(
                    onPressed: ()=>{
                      onClickNext(context)
                    },
                    color: HexColor.fromHex(DataManager.shared.business.pColor),


                    child: Text(this.isLoading ? "..." : language["next"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 20,fontFamily: DataManager.shared.fontName(),),),


                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  pickImageFromGallery(ImageSource source) async{

    var nFile = await picker.pickImage(source: source);

    final bytes = File(nFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    this.base64Image =  img64;

    var xd = File(nFile.path);
    if (mounted) {
      setState(() {
        imageFile =  xd;
        tmpFile = xd;
      });
    }
  }

  pickImageFromCamera(ImageSource source) async {
    var nFile = await picker.pickImage(source: source);

    final bytes = File(nFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    this.base64Image =  img64;

    var xd = File(nFile.path);
    if (mounted) {
      setState(() {
        imageFile =  xd;
        tmpFile = xd;
      });
    }
  }



  Widget showImage() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {setState(() { });}

    });


    return tmpFile == null ? SizedBox() : Image.file(
      tmpFile,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
    );
    // return FutureBuilder<File>(
    //   future: imageFile,
    //
    //   builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done &&
    //         snapshot.data != null) {
    //       tmpFile = snapshot.data;
    //
    //       base64Image = base64Encode(snapshot.data.readAsBytesSync());
    //       return Image.file(
    //         snapshot.data,
    //         width: 300,
    //         height: 300,
    //         fit: BoxFit.cover,
    //       );
    //
    //     } else if (snapshot.error != null) {
    //       return const SizedBox();
    //     } else {
    //       return const SizedBox();
    //     }
    //   },


   // );
  }

  upload(File imageFile,Map map,BuildContext context) async {

   Story story = await DataManager.shared.uploadStory(imageFile, {"business_id": Buissness_id});
   Navigator.pop(context);


  }

  void onClickNext(BuildContext context) async{



    if (this.imageFile != null && isLoading == false) {
      if (mounted){
        setState(() { this.isLoading = true;});
      }
      upload(tmpFile,{"isProfile":"1"},context);
    }

  }


}
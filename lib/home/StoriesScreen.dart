import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/managers/Datamanager.dart';
import 'package:cube_transition/cube_transition.dart';
import 'package:salon_app/models/Story.dart';
import 'package:salon_app/models/User.dart';


class StoriesScreen extends StatefulWidget{

  int index;
  StoriesScreen({this.index});

  @override
  _StoriesScreenState createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  bool _darkModeEnabled = false;
  var stories = List<Story>();
  DragStartDetails startVerticalDragDetails;
  DragUpdateDetails updateVerticalDragDetails;

  var _controller = PageController();

  var firstUrl = "";
  var canUseArray  = false;
  var selectedIndex = 0;
  @override
  void initState() {

    if (stories.length == 0 ) {
      stories = DataManager.shared.stories;
      stories = new List.from(stories.reversed);
      var newIndex = (stories.length-1) - widget.index;
      widget.index =  newIndex;
      firstUrl = stories[newIndex].image;
      Future.delayed(Duration(seconds: 1),(){
        _controller.jumpToPage(newIndex);
        canUseArray = true;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
   // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var qdarkMode = MediaQuery
        .of(context)
        .platformBrightness;
    _darkModeEnabled = qdarkMode == Brightness.dark;

    var appBar = AppBar(
      iconTheme: IconThemeData(
        color: _darkModeEnabled ? Colors.white : Colors.black, //change your color here
      ),
      elevation: 0,
      backgroundColor: _darkModeEnabled ? Colors.black : Color(0xffF5F5F5),
    );
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _darkModeEnabled ? Colors.black.withOpacity(0.95) : Color(0xffF5F5F5),
      appBar: null,
      body: GestureDetector(
        onVerticalDragStart: (dragDetails) {
          startVerticalDragDetails = dragDetails;
        },
        onVerticalDragUpdate: (dragDetails) {
          updateVerticalDragDetails = dragDetails;
        },
        onVerticalDragEnd: (endDetails) {
          double dx = updateVerticalDragDetails.globalPosition.dx -
              startVerticalDragDetails.globalPosition.dx;
          double dy = updateVerticalDragDetails.globalPosition.dy -
              startVerticalDragDetails.globalPosition.dy;
          double velocity = endDetails.primaryVelocity;

          //Convert values to be positive
          if (dx < 0) dx = -dx;
          if (dy < 0) dy = -dy;

          if (velocity < 0) {
            print("up");
          } else {
            Navigator.pop(context);
            //widget.onSwipeDown();
          }
        },
        child: Stack(
          children: [
          SizedBox(
          height: size.height,
          child: CubePageView.builder(
          itemCount: stories.length,
          controller: _controller,
          onPageChanged: (index){
            print("**************");
            selectedIndex = index;

            DataManager.shared.viewStory(stories[index].id);
          },
          itemBuilder: (context, index, notifier) {

            final transform = Matrix4.identity();
            final t = (index - notifier).abs();
            final scale = lerpDouble(1.5, 0, t);
            transform.scale(scale, scale);

            return CubeWidget(index: index, pageNotifier: notifier,

                child: Stack(
                  children: [


                    Image.network(
                      canUseArray == true ?  stories[index].image : firstUrl,
                      height:size.height,
                      width:size.width,
                      fit: BoxFit.cover,
                    ),

                    Positioned(
                        right: 10,
                        top: 50,
                        child: Row(
                          children: [
                            SizedBox(width: 50,),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Text("${stories[index].user.name}",
                                style: TextStyle(color: Colors.white,fontSize: 15,fontFamily: DataManager.shared.fontName()
                              ),),
                            ),
                            SizedBox(width: 15,),
                            Container(
                              width: 45,
                              height: 45,

                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(Radius.circular(22.5)),
                                image: stories[index].user == null || stories[index].user.image == null ? null : DecorationImage(
                                  // alignment: Alignment(-.2, 0),
                                    image: CachedNetworkImageProvider(domainName + "/storage/" + stories[index].user.image) ,
                                    fit: BoxFit.cover
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),

                    Positioned(
                        left: 10,
                        bottom: 20,
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined,color: Colors.white,),
                                SizedBox(width: 5,),
                                Text("${stories[index].views}",style: TextStyle(color: Colors.white,fontSize: 17),)
                              ],
                            ),
                          ),
                        )
                    ),
                  ],
                ),
                );
            })
          ),
            Positioned(
                left: 10,
                top: 50,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:(){
                        print(123);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                              Icons.close_sharp,color: Colors.white,
                          ),
                        ),
                      ),

                    ),
                    InkWell(

                        child: Text("    ")
                    ),
                   DataManager.shared.user.role != Role.client ? GestureDetector(
                      onTap:(){
                        Story s = stories[selectedIndex];
                        DataManager.shared.deleteStory({"story_id":"${s.id}"});
                        DataManager.shared.stories.removeWhere((element) => element.id == s.id);
                        setState(() {
                          stories.removeAt(this.selectedIndex);
                        });
                        Navigator.pop(context);
                        print(123);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.delete,color: Colors.white,
                          ),
                        ),
                      ),
                    ) : SizedBox(),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
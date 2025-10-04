import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/view/screens/comment_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/AlbumRotator.dart';
import 'package:tiktok_clone/TikTok/view/widgets/ProfileButton.dart';
import 'package:tiktok_clone/TikTok/view/widgets/TikTokVideoPlayer.dart';
import '../../controller/video_controller.dart';


class DisplayVideo_Screen extends StatelessWidget {
  DisplayVideo_Screen({Key? key}) : super(key: key);

  final VideoController videoController = Get.put(VideoController());



  @override
  Widget build(BuildContext context) {

    final DraggableScrollableController draggableController =
    DraggableScrollableController();

    return Scaffold(
      body: Obx(() {
        if (videoController.videoList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            itemCount: videoController.videoList.length,
            itemBuilder: (context, index) {
              final data = videoController.videoList[index];
              return InkWell(
                onTap: (){

                },
                onDoubleTap: (){
                  videoController.likedVideo(data.id);
                },
                child: Stack(
                  children: [
                    TikTokVideoPlayer( 
                      videoUrl: data.videoUrl,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10, left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.username,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                          Text(
                            data.caption,
                          ),
                          Text(
                            data.songName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.height - 400,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: data.uid,)));
                              },
                              child: ProfileButton(
                                profilePhotoUrl: data.profilePic,
                              ),
                            ),

                            InkWell(
                              onTap: (){
                                videoController.likedVideo(data.id);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    data.likes.contains(FirebaseAuth.instance.currentUser!.uid) ?  Icons.favorite : Icons.favorite_border_outlined ,
                                    size: 45,
                                    color: data.likes.contains(FirebaseAuth.instance.currentUser!.uid) ?  Colors.pinkAccent : Colors.white ,
                                  ),
                                  Text(
                                    data.likes.length.toString(),
                                    style:
                                    TextStyle(fontSize: 15, color: Colors.white),
                                  )
                                ],
                              ),
                            ),


                           ///comment
                            GestureDetector(
                              onTap: () {
                                showBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: DraggableScrollableSheet(
                                        controller: draggableController,
                                        maxChildSize: 1.0,
                                        initialChildSize: 0.5,
                                        minChildSize: 0.25,
                                        builder: (BuildContext context,ScrollController scrollController) {
                                          return CommentScreen(id: data.id, scrollController: scrollController , draggableController: draggableController);
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 41,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    data.commentsCount.toString(),
                                    style:
                                    TextStyle(fontSize: 15, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),


                            ///Share
                            InkWell(
                              onTap: (){
                                // share(data.id);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.reply_outlined,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    data.shareCount.toString(),
                                    style:
                                    TextStyle(fontSize: 15, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            ///Album rotator
                            SizedBox(height: 10,),
                            Column(
                              children: [
                                AlbumRotator(profilePicUrl: data.profilePic)
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      }
      ),
    );
  }
}
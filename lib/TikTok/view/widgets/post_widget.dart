import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/post_controller.dart';
import 'package:tiktok_clone/TikTok/model/post.dart';
import 'package:tiktok_clone/TikTok/view/screens/comment_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/TikTokVideoPlayer.dart';
import 'package:timeago/timeago.dart' as tago;

class PostWidget extends StatelessWidget {
  final Post data;   // Firestore doc snapshot
  PostWidget({super.key, required this.data});
  final DraggableScrollableController draggableController = DraggableScrollableController();
  final PostController postController = Get.put(PostController());
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------
        // 1. POST HEADER (ListTile equivalent)
        // ------------------------------------
        InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: data.uid)));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 35, // Matching width from the screenshot (line 14)
                    height: 35, // Matching height from the screenshot (line 15)
                    child: Image.network(
                      data.profilePic,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.username,
                        // Style matching line 28/29: fontSize: 13.sp
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold
                        ),
                      ),

                      /// Date/Time
                      Text(
                        tago.format(data.datePub.toDate()),
                        // Style matching line 31/32: fontSize: 11.sp
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700]
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz), // Trailing icon from line 33
              ],
            ),
          ),
        ),


        ///CAPTION
        Padding(
          padding: const EdgeInsets.only(left:8.0,right:8.0,bottom: 8.0),
          child: Text(
            data.caption,
            // Style matching line 31/32: fontSize: 11.sp
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700]
            ),
          ),
        ),

        /// ------------------------------------
        /// 2. MAIN POST IMAGE OR VIDEO
        ///------------------------------------
        /// MAIN CONTENT (image or video)
        Container(
          width: double.infinity,
          child: data.type == "video"
              ? TikTokVideoPlayer(videoUrl: data.postUrl)
              : Image.network(
            data.postUrl,
            fit: BoxFit.cover,
          ),
        ),


        // ------------------------------------
        // 3. LIKES AND COMMENTS
        // ------------------------------------
        Padding(
          padding: EdgeInsets.symmetric(horizontal:12.0 ,vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              ///comments , Likes Count
              RichText(
                text:
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.likes.length} likes',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                    TextSpan(
                      text: '  ${data.commentsCount} comments',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${data.shareCount} shares',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),

            ],
          ),
        ),

        /// ------------------------------------
        /// 4. ACTION BUTTONS ROW
        /// ------------------------------------
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  postController.likedPost(data.id);
                },
                child: Icon(
                  data.likes.contains(FirebaseAuth.instance.currentUser!.uid) ?  Icons.favorite : Icons.favorite_border_outlined ,
                  size: 28,
                  color: data.likes.contains(FirebaseAuth.instance.currentUser!.uid) ?  Colors.pinkAccent : Colors.white ,
                ),
              ),
              SizedBox(width: 15),

              ///comment Icon
              IconButton(
                 onPressed: (){
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
                             return CommentScreen(
                               whereCommentStores: "posts",
                                 id: data.id, scrollController: scrollController , draggableController: draggableController);
                           },
                         ),
                       );
                     },
                   );
                 },
                    icon: const Icon(Icons.comment_outlined, size: 28,)),
              SizedBox(width: 15),
              // Placeholder for "Send/Share" icon
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 28,),
            ],
          ),
        ),



        // Separator between posts
        SizedBox(height: 10),
        const Divider(height: 2),
      ],
    );
  }
}

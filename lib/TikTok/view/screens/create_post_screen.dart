import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/Chat/view/widgets/MediaPreviewScreen.dart';
import 'package:tiktok_clone/TikTok/constants.dart';
import 'package:tiktok_clone/TikTok/controller/post_upload_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_info_controller.dart';
import 'package:tiktok_clone/TikTok/view/widgets/MediaVideoPlayer.dart';
import 'package:tiktok_clone/TikTok/view/widgets/button.dart';
import 'package:tiktok_clone/TikTok/view/widgets/text_input.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
   CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
 final TextEditingController captionController = TextEditingController();
 PostUploadController postUploadController = Get.put(PostUploadController());
 final ProfileInfoController profileInfoController = Get.put(ProfileInfoController());


 @override
 void initState() {
   super.initState();
   profileInfoController.fetchUserProfile();
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create post"),
        leading: IconButton(
            onPressed: (){
             postUploadController.mediaFiles.clear();
              Navigator.pop(context);
            }
            , icon: Icon(Icons.arrow_back)),
        actions: [
          TButton(text:"POST",onTap: (){
            postUploadController.uploadPost(
              captionController.text// "image" or "video"
            );
          },backgroundColor:primary,width: 75,height: 40,radius: 8,),
        ],
      ),
      // showDialogOpt(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Profile info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 35, // Matching width from the screenshot (line 14)
                      height: 35, // Matching height from the screenshot (line 15)
                      child: Obx(() {
                        if (profileInfoController.isLoading.value) {
                          return CircularProgressIndicator(strokeWidth: 2);
                        }
                        return Image.network(
                          profileInfoController.userProfilePic,
                          fit: BoxFit.cover,
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: 8),
                  Obx( () {
                      return Text(
                        profileInfoController.userName,
                        style: TextStyle(
                            fontSize:16,
                            fontWeight: FontWeight.bold
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),

            ///CAPTION
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextInputField(
                  controller:captionController ,
                  myIcon:Icons.edit_outlined,
                  myLabelText: "What's on your mind?"),
            ),
            /// Selected Media Preview
            Obx(() {
              if (postUploadController.mediaFiles.isEmpty) {
                return const SizedBox();
              }
              return _buildMediaGrid(context);
            }),

            /// Pick Image/Video Options
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Photo/Video"),
              onTap: () => postUploadController.pickMultipleMedia(),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () => postUploadController.pickCamera(),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text("Take Video"),
              onTap: () => postUploadController.pickVideo(),
            ),
          ],
        ),
      ),
    );
  }

 /// Media Grid (Local Preview)
 Widget _buildMediaGrid(BuildContext context) {
   final mediaItems = postUploadController.mediaFiles;
   int itemCount = mediaItems.length;

   return Padding(
     padding: const EdgeInsets.all(8.0),
     child: GridView.builder(
       shrinkWrap: true,
       physics: const NeverScrollableScrollPhysics(),
       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
         crossAxisCount: itemCount == 1 ? 1 : 2,
         mainAxisSpacing: 4,
         crossAxisSpacing: 4,
       ),
       itemCount: itemCount > 4 ? 4 : itemCount,
       itemBuilder: (context, index) {
         final file = mediaItems[index];
         final isVideo = file.path.endsWith('.mp4');

         Widget mediaWidget;

         if (isVideo) {
           final controller = VideoPlayerController.file(File(file.path));
           mediaWidget = FutureBuilder(
             future: controller.initialize(),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.done) {
                 return Stack(
                   alignment: Alignment.center,
                   children: [
                     AspectRatio(
                       aspectRatio: controller.value.aspectRatio,
                       child: VideoPlayer(controller),
                     ),
                     const Icon(Icons.play_circle_fill,
                         color: Colors.white, size: 40),
                   ],
                 );
               } else {
                 return const Center(
                     child: CircularProgressIndicator(strokeWidth: 2));
               }
             },
           );
         } else {
           mediaWidget = Image.file(
             File(file.path),
             fit: BoxFit.cover,
           );
         }

         // Show "+N" overlay if more than 4 media
         if (index == 3 && itemCount > 4) {
           return Stack(
             fit: StackFit.expand,
             children: [
               mediaWidget,
               Container(
                 color: Colors.black54,
                 child: Center(
                   child: Text(
                     "+${itemCount - 4}",
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 26,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ),
             ],
           );
         }

         return GestureDetector(
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => MediaPreviewScreen(
                   mediaItems: mediaItems
                       .map((x) => {"url": x.path, "type": x.path.endsWith('.mp4') ? "video" : "image"})
                       .toList(),
                   initialIndex: index,
                 ),
               ),
             );
           },
           child: ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: mediaWidget,
           ),
         );
       },
     ),
   );
 }
}

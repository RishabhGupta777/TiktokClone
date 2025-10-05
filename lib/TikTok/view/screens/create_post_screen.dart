import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/TikTok/constants.dart';
import 'package:tiktok_clone/TikTok/controller/post_upload_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_info_controller.dart';
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

 XFile? selectedFile;
   String? fileType;   // "image" or "video"
   VideoPlayerController? _videoController;
   String path=" ";

  // ------------------- MEDIA PICK (PHOTO or VIDEO) -------------------
  mediaPick(ImageSource src, BuildContext context) async {

   final ImagePicker picker = ImagePicker();
   XFile? file;

   if (src == ImageSource.gallery) {
   // Gallery can be both photo or video
   file = await picker.pickMedia();
   } else {
   // Camera: You must choose explicitly image or video
   file = await picker.pickImage(source: ImageSource.camera);
   /// OR: file = await picker.pickVideo(source: ImageSource.camera);
   }

   if (file != null) {
   path = file.path;
   final String extension = path.split('.').last.toLowerCase();

      // Check if image or video
      if (["jpg", "jpeg", "png", "gif", "heic", "webp"].contains(extension)) {
        // It's an image
        Get.snackbar("Photo Selected", path);
        setState(() {
          selectedFile = file;
          fileType = "image";
          _videoController?.dispose();
          _videoController = null;
        });

      } else {
        // It's a video
        Get.snackbar("Video Selected", path);
        setState(() {
          selectedFile = file;
          fileType = "video";
          _videoController = VideoPlayerController.file(File(path))
            ..initialize().then((_) {
              setState(() {}); // Refresh once video is ready
              _videoController!.play();
            });
        });
      }
    } else {
      Get.snackbar("Error", "No media selected");
    }
  }

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
        leading: Icon(Icons.arrow_back_ios),
        actions: [
          TButton(text:"POST",onTap: (){
            if (selectedFile == null) {
              Get.snackbar("Error", "Please select an image or video first");
              return;
            }

            // Call your upload controller with both file & type
            postUploadController.uploadPost(
              captionController.text,
              File(path),
              fileType!, // "image" or "video"
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

            /// SELECTED POST
            if (selectedFile != null)
              Container(
                width: double.infinity,
                height: 350,
                color: Colors.black12,
                child: fileType == "image"
                    ? Image.file(File(selectedFile!.path), fit: BoxFit.cover)
                    : (_videoController != null &&
                    _videoController!.value.isInitialized)
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
                    : const Center(child: CircularProgressIndicator()),
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "No media selected",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            ///SELECT PHOTO OR VIDEO

            ListTile(
              leading:Icon(Icons.photo_library_outlined),
              title: Text("Photo/Video"),
              onTap: () => mediaPick(ImageSource.gallery, context),
            ),
            ListTile(
              leading:Icon(Icons.camera),
              title: Text("camera"),
              onTap: () => mediaPick(ImageSource.camera, context),
            )

          ],
        ),
      ),
    );
  }
}

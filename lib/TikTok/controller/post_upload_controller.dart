import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/TikTok/model/post.dart';
import 'package:tiktok_clone/TikTok/view/screens/Home.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as pathLib; // for file extensions

class PostUploadController extends GetxController {
  static PostUploadController instance = Get.find();
  var uuid = Uuid();

  // ---------- Generate Video Thumbnail ----------
  Future<File> _getThumb(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }



  final ImagePicker picker = ImagePicker();

  RxList<XFile> mediaFiles = <XFile>[].obs;

  Future<void> pickMultipleMedia() async {
    mediaFiles.value = await picker.pickMultipleMedia();
  }

  Future<void> pickCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      mediaFiles.value = [image]; // Convert single file to list
    }
  }

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      mediaFiles.value = [video]; // Convert single file to list
    }
  }



  Future<List<String>> uploadMedia(List<XFile> files) async {
  List<String> downloadUrls = [];

  for (var file in files) {
  final ref = FirebaseStorage.instance
      .ref()
      .child('posts/${DateTime.now().millisecondsSinceEpoch}_${pathLib.basename(file.path)}');

  final uploadTask = await ref.putFile(File(file.path));
  final url = await uploadTask.ref.getDownloadURL();
  downloadUrls.add(url);
  }

  return downloadUrls;
  }



  // ---------- Upload Post (Image or Video) ----------
  Future<void> uploadPost(String caption) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      String id = uuid.v1();
      String thumbnail = "";

      RxList<Map<String, String>> mediaList = <Map<String, String>>[].obs;

      if (mediaFiles.isNotEmpty) {
        // Upload all files
        final urls = await uploadMedia(mediaFiles);

        //  Pair each uploaded file with its type
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          final url = urls[i];
          final fileType = file.path.endsWith('.mp4') ? 'video' : 'image';
          mediaList.add({'url': url, 'type': fileType});
        }
      }

      // Allow posting even if caption only (no media)
      if (caption.trim().isEmpty && mediaList.isEmpty) {
        Get.snackbar("Error", "Please write something or add media first");
        return;
      }

      Post post = Post(
        uid: uid,
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        mediaUrl: mediaList,
        shareCount: 0,
        commentsCount: 0,
        likes: [],
        profilePic: (userDoc.data()! as Map<String, dynamic>)['profilePic'],
        caption: caption,
        id: id,
        datePub : DateTime.now(),
      );

      await FirebaseFirestore.instance.collection("posts").doc(id).set(post.toJson());

      Get.snackbar("Success", "Post Uploaded Successfully");
      Get.to(HomeScreen());

      // Clear selected media after posting
      mediaFiles.clear();
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
    }
  }

  // // ---------- Helpers ----------
  // Future<String> _uploadFileToStorage(String path, File file) async {
  //   Reference reference = FirebaseStorage.instance.ref().child(path);
  //   UploadTask uploadTask = reference.putFile(file);
  //   TaskSnapshot snapshot = await uploadTask;
  //   String downloadUrl = await snapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  // Future<String> _uploadPostThumbToStorage(String id, String videoPath) async {
  //   Reference reference = FirebaseStorage.instance.ref().child("thumbnails").child(id);
  //   UploadTask uploadTask = reference.putFile(await _getThumb(videoPath));
  //   TaskSnapshot snapshot = await uploadTask;
  //   String downloadUrl = await snapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  // Future<String> _uploadVideoToStorage(String postID, String videoPath) async {
  //   Reference reference = FirebaseStorage.instance.ref().child("posts").child(postID);
  //
  //   UploadTask uploadTask = reference.putFile(await _compressVideo(videoPath));
  //   TaskSnapshot snapshot = await uploadTask;
  //   String downloadUrl = await snapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  // Future<File> _compressVideo(String videoPath) async {
  //   final compressedVideo = await VideoCompress.compressVideo(
  //     videoPath,
  //     quality: VideoQuality.MediumQuality,
  //   );
  //   return compressedVideo!.file!;
  // }
}

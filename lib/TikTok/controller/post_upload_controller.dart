import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
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

  Future<String> _uploadPostThumbToStorage(String id, String videoPath) async {
    Reference reference = FirebaseStorage.instance.ref().child("thumbnails").child(id);
    UploadTask uploadTask = reference.putFile(await _getThumb(videoPath));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // ---------- Upload Post (Image or Video) ----------
  Future<void> uploadPost(String caption, File file, String fileType) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      String id = uuid.v1();
      String postUrl = "";
      String thumbnail = "";

      if (fileType == "image") {
        // -------- IMAGE UPLOAD --------
        postUrl = await _uploadFileToStorage("posts/$id", file);

        // thumbnail can just be same image for now
        thumbnail = postUrl;
      } else if (fileType == "video") {
        // -------- VIDEO UPLOAD --------
        postUrl = await _uploadVideoToStorage(id, file.path);

        // upload thumbnail
        thumbnail = await _uploadPostThumbToStorage(id, file.path);
      }

      Post post = Post(
        uid: uid,
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        postUrl: postUrl,
        thumbnail: thumbnail,
        shareCount: 0,
        commentsCount: 0,
        likes: [],
        profilePic: (userDoc.data()! as Map<String, dynamic>)['profilePic'],
        caption: caption,
        id: id,
        type: fileType
      );

      await FirebaseFirestore.instance.collection("posts").doc(id).set(post.toJson());

      Get.snackbar("Success", "Post Uploaded Successfully");
      Get.to(HomeScreen());
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
    }
  }

  // ---------- Helpers ----------
  Future<String> _uploadFileToStorage(String path, File file) async {
    Reference reference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadVideoToStorage(String postID, String videoPath) async {
    Reference reference = FirebaseStorage.instance.ref().child("posts").child(postID);

    UploadTask uploadTask = reference.putFile(await _compressVideo(videoPath));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<File> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file!;
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final _auth = FirebaseAuth.instance; //_auth is object and FirebaseAuth isa class
  final ImagePicker picker = ImagePicker();
  Rx<XFile?> proImg = Rx<XFile?>(null);

  void pickImageFromGallery() async{
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      proImg.value = image;
      _uploadProfilePic(File(image.path));
    }
  }
  void pickImageFromCamera() async{
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      proImg.value = image;
    }
  }

  Future<void> _uploadProfilePic(File image) async {
    try {
      String userId = _auth.currentUser!.uid;

      // Upload to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('profilePics').child(userId);
      UploadTask uploadTask = storageRef.putFile(image);

      // Get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with the new profile picture URL
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'profilePic': downloadUrl},
        SetOptions(merge: true),
      );
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

}
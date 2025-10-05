import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';

class ProfileInfoController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<myUser?> currentUser = Rx<myUser?>(null);
  RxBool isLoading = false.obs;

  /// Fetch current user's profile from Firestore
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        currentUser.value = myUser.fromSnap(userDoc);
      } else {
        print("User document not found!");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get name directly
  String get userName => currentUser.value?.name ?? '';

  /// Get profile photo directly
  String get userProfilePic => currentUser.value?.profilePhoto ?? '';

  ///Get current user Uid
  String get userUid => currentUser.value?.uid ?? '';
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController{
final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
Map<String, dynamic> get user => _user.value;
RxBool isLoading = false.obs;
  Rx<String> _uid = "".obs;

  updateUseId(String uid){

    _uid.value = uid;
    getUserDat();
  }

  getUserDat() async {
    try{
      isLoading.value = true;

      List<String> thumbnails = [];
    var myVideos = await FirebaseFirestore.instance.collection("videos").where(
        "uid", isEqualTo: _uid.value).get();
    for (int i = 0; i < myVideos.docs.length; i++) {
      thumbnails.add((myVideos.docs[i].data() as dynamic)['thumbnail']);
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        "users").doc(_uid.value).get();
    DocumentSnapshot userInfoDoc = await FirebaseFirestore.instance.collection(
        "usersInfo").doc(_uid.value).get();

    String name = userDoc['name'];
    String profilePic = userDoc['profilePic'];
    String about = " ";
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;

    ///For about
    if (userInfoDoc.exists) {
      // only access field if the document exists
      final data = userInfoDoc.data() as Map<String, dynamic>;
      about = data['about'] ?? " ";
    }

    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }

    var followerDoc = await FirebaseFirestore.instance.collection("users").doc(
        _uid.value).collection("followers").get();
    var followingDoc = await FirebaseFirestore.instance.collection("users").doc(
        _uid.value).collection("following").get();

    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_uid.value)
        .collection("followers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((value) {
      if (value.exists) {
        //FOLLOW KRTA HAI
        isFollowing = true;
      } else {
        //FOLLOW NHI KRTA HAI
        isFollowing = false;
      }
    });


    _user.value = {
      'followers': followers.toString(),
      'following': following.toString(),
      'likes': likes.toString(),
      'profilePic': profilePic,
      'name': name,
      'about': about,
      'isFollowing': isFollowing,
      'thumbnails': thumbnails
    };

    update();
  }catch (e) {
      print("Error loading user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  followUser() async{
    var doc = await FirebaseFirestore.instance.collection("users").doc(_uid.value).collection("followers").doc(FirebaseAuth.instance.currentUser!.uid).get();

    if(!doc.exists){
      await FirebaseFirestore.instance.collection("users").doc(_uid.value).collection("followers").doc(FirebaseAuth.instance.currentUser!.uid).set({});
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("following").doc(_uid.value).set({});
      _user.value.update('followers', (value) => (int.parse(value) + 1).toString());
    }else{
      await FirebaseFirestore.instance.collection("users").doc(_uid.value).collection("followers").doc(FirebaseAuth.instance.currentUser!.uid).delete();
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("following").doc( _uid.value).delete();
      _user.value.update('followers', (value) => (int.parse(value) - 1).toString());
    }

    _user.value.update('isFollowing', (value) => !value);
    update();
  }

}
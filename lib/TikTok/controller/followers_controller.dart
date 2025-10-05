import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';

class FollowersController extends GetxController {
  final Rx<List< myUser >> _followers = Rx<List<myUser>>([]);
  List<myUser> get followers => _followers.value;

  void follower(String uid) {
    _followers.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("followers")
          .snapshots()
          .asyncMap((QuerySnapshot querySnapshot) async {
        List<myUser> users = [];

        for (var doc in querySnapshot.docs) {
          // doc.id is the follower UID
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .get();

          if (userDoc.exists) {
            users.add(myUser.fromSnap(userDoc));
          }
        }
        return users;
      }),
    );
  }

}

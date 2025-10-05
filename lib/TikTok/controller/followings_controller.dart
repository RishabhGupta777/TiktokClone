import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';

class FollowingsController extends GetxController {
  final Rx<List< myUser >> _followings = Rx<List<myUser>>([]);
  List<myUser> get followings => _followings.value;

  void following(String uid) {
    _followings.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("following")
          .snapshots()
          .asyncMap((QuerySnapshot querySnapshot) async {
        List<myUser> users = [];

        for (var doc in querySnapshot.docs) {
          // doc.id is the following UID
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

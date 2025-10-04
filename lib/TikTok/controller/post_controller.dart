import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiktok_clone/TikTok/controller/auth_controller.dart';
import 'package:tiktok_clone/TikTok/model/post.dart';
import 'package:get/get.dart';


class PostController extends GetxController{
  final Rx<List<Post>> _postList = Rx<List<Post>>([]);
  List<Post> get postList => _postList.value;

  @override
  void onInit() {
    super.onInit();
    _postList.bindStream(FirebaseFirestore.instance.collection("posts").snapshots().map((QuerySnapshot query){
      List<Post> retVal  = [];
      for(var element in query.docs){
        retVal.add(Post.fromSnap(element));
      }
      return retVal;
    }));
  }

  sharePost(String vidId) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("posts").doc(vidId).get();

    int newShareCount  =  (doc.data() as dynamic)["shareCount"] + 1;
    await FirebaseFirestore.instance.collection("posts").doc(vidId).update(
        {
          "shareCount" : newShareCount
        });
  }
  likedPost(String id) async{

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("posts").doc(id).get();
    var uid = AuthController.instance.user.uid;
    if((doc.data() as dynamic)['likes'].contains(uid)){
      await FirebaseFirestore.instance.collection("posts").doc(id).update({
        'likes' : FieldValue.arrayRemove([uid]),
      });
    }else{
      await FirebaseFirestore.instance.collection("posts").doc(id).update(
          {
            'likes' : FieldValue.arrayUnion([uid]),
          });
    }
  }
}
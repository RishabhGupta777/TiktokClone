import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';

class SearchUserController extends GetxController{
  final Rx<List<myUser>> _searchUsers = Rx<List<myUser>>([]);
  
  List<myUser> get searchedUsers => _searchUsers.value;
  
  searchUser(String query) async{

    if (query.isEmpty) {
      _searchUsers.value = [];  //taki textField khali rhe to purana wala search return na kare
      return;
    }

    _searchUsers.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("name" , isGreaterThanOrEqualTo: query)
          .where("name", isLessThan: query + 'z') // ensures partial matches
          .snapshots().
      map((QuerySnapshot queryRes){
        List<myUser> retVal = [];
        for(var element in queryRes.docs ){
          retVal.add(myUser.fromSnap(element));
        }
        return retVal;

      })
    );
  }
}
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

  // New list to hold the currently filtered users (what the UI will display)
  final Rx<List<myUser>> _filteredFollowers = Rx<List<myUser>>([]);
  List<myUser> get filteredFollowers => _filteredFollowers.value;

  // Rx variable to hold the current search query
  final RxString _searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Reactively set the filtered list whenever the main list changes
    // or when the search query changes.
    ever( _followers , (_) {
      _applyFilter(_searchQuery.value);
    });
    // 2. Also reactively filter when the search query itself changes
    ever(_searchQuery, (query) {
      _applyFilter(query);
    });
  }

  // Method to update the search query from the UI
  void searchUser(String query) {
    _searchQuery.value = query.trim();
  }

  // Core filtering logic
  void _applyFilter(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.isEmpty) {
      // If the search query is empty, show the entire list.
      _filteredFollowers.value = List.from(_followers.value);
    } else {
      // Filter the list by username (case-insensitive).
      _filteredFollowers.value = _followers.value.where((user) {
        return user.name.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    // Force update to ensure Obx reacts if list reference didn't change (rare, but safe)
    _filteredFollowers.refresh();
  }


  @override
  void onClose() {
    // 1. Reset the state variables
    _searchQuery.value = '';
    _filteredFollowers.value = [];

    super.onClose();
  }


}

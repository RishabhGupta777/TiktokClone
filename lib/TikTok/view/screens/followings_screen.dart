import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/followings_controller.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';

class FollowingsScreen extends StatefulWidget {
  final String uid;
  const FollowingsScreen({super.key, required this.uid});

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  final TextEditingController searchQuery = TextEditingController();
  // Get.put() is used once in initState, but accessing it here for scope
  final FollowingsController followingsController = Get.put(FollowingsController());

  @override
  void initState() {
    super.initState();
    // Start fetching the followings list
    followingsController.following(widget.uid);
  }

  @override
  void dispose() {
    // IMPORTANT: Remove the controller instance when the screen is closed.
    // This triggers the onClose() method in the controller,
    // where we reset the state and cancel the stream subscription.
    Get.delete<FollowingsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            decoration: const InputDecoration( // Added const
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "Search Username"
            ),
            controller: searchQuery ,
            onChanged: (value){
              // 1. Call the controller method to update the search query and trigger filtering
              followingsController.searchUser(value);
            },),
        ),
        // 2. Observe the filtered list from the controller
        body:Obx(() {
          final List<myUser> displayList = followingsController.filteredFollowings;
          final bool isInitialLoading = followingsController.followings.isEmpty && searchQuery.text.isEmpty;

          if (isInitialLoading) {
            return const Center(
              child: Text("No any Followings!"),
            );
          } else if (displayList.isEmpty && searchQuery.text.isNotEmpty) {
            return Center(
              child: Text("No users found for \"${searchQuery.text}\""),
            );
          }

          return ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index){
                myUser user = displayList[index];

                return ListTile(
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: user.uid)));},
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.profilePhoto),),
                  title: Text(user.name),
                );
              });
        })
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/followers_controller.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';


class FollowersScreen extends StatefulWidget {
  String uid;
  FollowersScreen({super.key, required this.uid});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  TextEditingController searchQuery = TextEditingController();
  final FollowersController followersController = Get.put(FollowersController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    followersController.follower(widget.uid);
  }

  @override
  void dispose() {
    // IMPORTANT: Remove the controller instance when the screen is closed.
    // This triggers the onClose() method in the controller,
    // where we reset the state and cancel the stream subscription.
    Get.delete<FollowersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
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
          onChanged: (value){  // this runs on every keystroke
            followersController.searchUser(value);
          },),


      ),
      body:Obx(() {
        final List<myUser> displayList = followersController.filteredFollowers;
        final bool isInitialLoading = followersController.followers.isEmpty && searchQuery.text.isEmpty;

        if (isInitialLoading) {
          return const Center(
            child: Text("No any Followers!"),
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

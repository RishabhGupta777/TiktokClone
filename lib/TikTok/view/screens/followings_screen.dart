import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/followings_controller.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';

class FollowingsScreen extends StatefulWidget {
  String uid;
  FollowingsScreen({super.key, required this.uid});

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  TextEditingController searchQuery = TextEditingController();
  final FollowingsController followingsController = Get.put(FollowingsController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    followingsController.following(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: TextFormField(
            decoration: new InputDecoration(
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
              // followersController.searchUser(value.trim());
            },),


        ),
        body:Obx(() {return followingsController.followings.isEmpty ?   Center(
          child: Text("No any Followers!"),
        ) :
        ListView.builder(
            itemCount: followingsController.followings.length,
            itemBuilder: (context, index){
              myUser user = followingsController.followings[index];

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

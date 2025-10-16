import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/Chat/view/screens/ChatScreen.dart';
import 'package:tiktok_clone/TikTok/controller/auth_controller.dart';
import 'package:tiktok_clone/TikTok/controller/edit_profile_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_controller.dart';
import 'package:tiktok_clone/TikTok/view/screens/edit_profile_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/followers_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/followings_screen.dart';

class ProfileScreen extends StatefulWidget {
  String uid;
  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.updateUseId(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        // init: ProfileController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  controller.user.isEmpty
                      ? '' //can be Loading... here
                      : controller.user['name'] ?? 'No Name',
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      widget.uid == FirebaseAuth.instance.currentUser!.uid
                          ? authController.signOut()
                          : //Get.snackbar("NanoGram App", "Current Version 1.0")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  receiver: widget.uid,
                                ),
                              ),
                            );
                    },
                    icon: Icon(
                        widget.uid == FirebaseAuth.instance.currentUser!.uid
                            ? Icons.logout  //info_outline-->icon tha
                            : Icons.chat),
                  )
                ],
              ),
              body: controller.user.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 55, // Adjust the size
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: null,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          profileController.user['profilePic'],
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        radius: 55,
                                        backgroundImage: imageProvider,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowersScreen(
                                                          uid: widget.uid)));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.user['followers'],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text("Followers",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowingsScreen(
                                                          uid: widget.uid)));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.user['following'],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text("Followings",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                                      ),
                                      /*SizedBox(width: 25,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(controller.user['likes'] , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w700),),
                                SizedBox(height:2,),
                                Text("Likes" , style: TextStyle(fontSize: 14 , fontWeight: FontWeight.w400))
                              ],
                            ),
                            */
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(controller.user['about']),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                onTap: () {
                                  if (widget.uid ==
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen(),
                                      ),
                                    );
                                  } else {
                                    controller.followUser();
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white60, width: 0.6),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: Text(widget.uid ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
                                          ? "Edit Profile"
                                          : controller.user['isFollowing']
                                              ? "Following"
                                              : "Follow")),
                                ),
                              ),
                              SizedBox(height: 25,),
                              Divider(
                                // indent: 30,
                                // endIndent: 30,
                                thickness: 2,
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 5),
                                  itemCount:
                                      controller.user['thumbnails'].length,
                                  itemBuilder: (context, index) {
                                    String thumbnail =
                                        controller.user['thumbnails'][index];
                                    return CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: thumbnail,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ));
        });
  }
}

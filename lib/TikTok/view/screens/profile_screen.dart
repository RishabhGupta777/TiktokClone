import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/Chat/view/screens/ChatScreen.dart';
import 'package:tiktok_clone/TikTok/constants.dart';
import 'package:tiktok_clone/TikTok/controller/auth_controller.dart';
import 'package:tiktok_clone/TikTok/controller/edit_profile_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_controller.dart';
import 'package:tiktok_clone/TikTok/view/screens/edit_profile_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/followers_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/followings_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/button.dart';
import 'package:tiktok_clone/TikTok/view/widgets/post_widget.dart';

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
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar:AppBar(
                title: Text(
                  controller.isLoading.value
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
              body:   controller.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        automaticallyImplyLeading: false, // This removes the back arrow
                        floating: true,
                        pinned: true,
                        snap: true,
                        expandedHeight: 343.0,
                        forceElevated: innerBoxIsScrolled,
                        flexibleSpace: FlexibleSpaceBar( // Simplified the flexibleSpace
                          background: SafeArea(
                              child: Column(
                                children: [
                                  Padding(
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

                                              ],
                                            ),
                                          ],
                                        ),
                                        controller.user['about'].trim().isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                          children: [
                                            const SizedBox(height: 30),
                                            Text(controller.user['about']),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        TButton(
                                          height: 35,
                                          width: 130,
                                          radius: 8,
                                          backgroundColor:primary,
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
                                          text:widget.uid ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
                                              ? "Edit Profile"
                                              : controller.user['isFollowing']
                                              ? "Following"
                                              : "Follow",
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    // indent: 10,
                                    // endIndent: 10,
                                    thickness: 2,
                                  ),
                                ],
                              ),
                            ),
                        ),
                        bottom:  PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight),  //here KTooBarHeight is byDefault and use hatana ho agar then use 48 there
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: const TabBar(
                              // isScrollable: true,
                              indicatorColor:primary,
                              unselectedLabelColor: Colors.grey,
                              labelColor:primary,
                              tabs: [
                                Tab(icon: Icon(Icons.grid_on)),
                                Tab(icon: Icon(Icons.play_circle_outline)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body:  SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    children:[
                      /// Posts tab
                  Padding(
                    padding: const EdgeInsets.only(top:60.0),
                    child: CustomScrollView(
                    slivers: [
                    SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) {
                                    final data = controller.posts[index];
                                    return PostWidget(data: data);
                                    },
                    childCount: controller.posts.length,
                                    ),
                                  ),
                    ]),
                  ),


                      /// Videos tab (placeholder)
                      GridView.builder(
                          padding: EdgeInsets.only(top:60),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: controller.user['thumbnails'].length,
                          itemBuilder: (context,index) {
                            String thumbnail =
                            controller.user['thumbnails'][index];
                            return CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: thumbnail,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            );
                          }),
                    ],
                  ),
                ),
              ),

            ),
          );
        });
  }
}

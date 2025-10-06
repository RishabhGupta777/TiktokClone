import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/post_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_info_controller.dart';
import 'package:tiktok_clone/TikTok/view/screens/create_post_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/search_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/button.dart';
import 'package:tiktok_clone/TikTok/view/widgets/post_widget.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostController postController = Get.put(PostController());

  final ProfileController profileController = Get.put(ProfileController());

  final ProfileInfoController profileInfoController = Get.put(ProfileInfoController());

  @override
  void initState() {
    super.initState();
    profileInfoController.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// Create Post Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:42.0,left:10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("NanoGram",
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),),
                      IconButton(
                          onPressed:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen()));
                          },
                          icon: Icon(Icons.search_rounded))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom:20.0,top:10,left:2,right:10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid:profileInfoController.userUid)));
                          },
                          child: ClipOval(
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child:Obx(() {
                                if (profileInfoController.isLoading.value) {
                                  return CircularProgressIndicator(strokeWidth: 2);
                                }
                                return Image.network(
                                  profileInfoController.userProfilePic,
                                  fit: BoxFit.cover,
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                          TButton(
                              text: "Create a Post",
                              height: 35,
                              textColor: Colors.black,
                              onTap:(){
                                Get.to(() => CreatePostScreen());
                              }))
                    ],
                  ),
                ),
                const Divider(height: 2),
              ],
            ),
          ),

          /// Posts Section
          Obx(() {
            if (postController.postList.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final data = postController.postList[index];
                  return PostWidget(data: data);
                },
                childCount: postController.postList.length,
              ),
            );
          })
        ],
      ),
    );
  }
}
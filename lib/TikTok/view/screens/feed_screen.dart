import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/post_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_controller.dart';
import 'package:tiktok_clone/TikTok/model/user.dart';
import 'package:tiktok_clone/TikTok/view/screens/create_post_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/button.dart';
import 'package:tiktok_clone/TikTok/view/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final PostController postController = Get.put(PostController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// Create Post Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height:30,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipOval(
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.network(
                              profileController.user['profilePic'] ?? "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg",
                              fit: BoxFit.cover,
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
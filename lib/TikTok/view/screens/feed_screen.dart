import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/post_controller.dart';
import 'package:tiktok_clone/TikTok/view/screens/create_post_screen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/button.dart';
import 'package:tiktok_clone/TikTok/view/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final PostController postController = Get.put(PostController());

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
                              'https://firebasestorage.googleapis.com/v0/b/oyes-63857.appspot.com/o/profilePics%2FFAfBzyJJEkRQOQRYFFeezEglcJr2?alt=media&token=8a166954-1144-4c79-992b-6b443d7b2ddb',
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
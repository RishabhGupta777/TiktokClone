import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/TikTok/controller/comment_controller.dart';
import 'package:tiktok_clone/TikTok/view/widgets/text_input.dart';
import 'package:timeago/timeago.dart' as tago;
class CommentScreen extends StatelessWidget {
  final String id;
  final ScrollController ? scrollController;
  final DraggableScrollableController  draggableController ;
  CommentScreen({
      required this.id,
      required this.scrollController,
    required this.draggableController
  }
      );
  final TextEditingController _commentController  = TextEditingController();

  CommentController commentController = Get.put(CommentController());


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    commentController.updatePostID(id);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async{

              await draggableController.animateTo(
                  1.0, // expand to full screen
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );

      },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // drag handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      "Comments",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                  return ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,itemCount: commentController.comments.length,
                      itemBuilder: (context , index){
                    final comment  = commentController.comments[index];
                    return ListTile(
                      leading : CircleAvatar(
                        backgroundImage: NetworkImage(comment.profilePic),
                      ),
                      title: Row(
                        children: [
                          Text(comment.username , style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent
                          ),),
                          SizedBox(
                            width: 5,
                          ),
                          Text(comment.comment,  style: TextStyle(
                              fontSize: 13,

                          ),)
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(tago.format(comment.datePub.toDate()) , style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                          SizedBox(width: 5,),
                          Text("${comment.likes.length} Likes" , style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                          ), )
                        ],
                      ),
                      trailing: InkWell(
                          onTap: (){
                            commentController.likeComment(comment.id);
                          },
                          child: Icon(Icons.favorite , color : comment.likes.contains(FirebaseAuth.instance.currentUser!.uid) ? Colors.red : Colors.white)),
                    );
                  });
                }
              ),
            ),
            Divider(),
            ListTile(
              title : TextInputField(controller: _commentController, myIcon: Icons.comment, myLabelText: "Comment"),
              trailing: TextButton(
                onPressed: (){
                  commentController.postComment(_commentController.text);
                  _commentController.clear();
                },
                child: Text("Send"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

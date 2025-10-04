import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Post{
  String username;
  String uid;
  String id;
  List likes;
  int commentsCount;
  int shareCount;
  String caption;
  String postUrl;
  String thumbnail;
  String profilePic;
  String type;


  Post({
    required this.username,
    required this.uid,
    required this.thumbnail,
    required this.caption,
    required this.commentsCount,
    required this.id,
    required this.likes,
    required this.profilePic,
    required this.shareCount,
    required this.postUrl,
    required this.type,
  });

  Map<String, dynamic> toJson()=>{
    "username" : username,
    "uid" : uid,
    "profilePic" : profilePic,
    "id" : id,
    "likes" : likes,
    "commentsCount" : commentsCount,
    "shareCount" : shareCount,
    "caption" : caption,
    "postUrl" : postUrl,
    "thumbnail" : thumbnail,
    "type": type,

  };

  static Post fromSnap(DocumentSnapshot snap){
    var sst = snap.data() as Map<String,dynamic>;

    return Post(
        username: sst["username"],
        uid: sst["uid"],
        id: sst["id"],
        likes: sst["likes"],
        commentsCount:  sst['commentsCount'],
        caption:  sst["caption"],
        shareCount: sst["shareCount"],
        thumbnail: sst["thumbnail"],
        profilePic: sst["profilePic"],
        postUrl: sst["postUrl"],
       type: sst["type"] ?? "image",
    );
  }

}
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
  List<Map<String,String>> mediaUrl; //here two maps exist one for url and another for type-->each item: {"url": "...", "type": "..."}
  String profilePic;
  final datePub;

  Post({
    required this.username,
    required this.uid,
    required this.caption,
    required this.commentsCount,
    required this.id,
    required this.likes,
    required this.profilePic,
    required this.shareCount,
    required this.mediaUrl,
    required this.datePub,
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
    "mediaUrl":mediaUrl,
    "datePub" : datePub,
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
        profilePic: sst["profilePic"],
      mediaUrl: (sst["mediaUrl"] as List)
          .map((e) => Map<String, String>.from(e))
          .toList(),
       datePub : sst["datePub"],
    );
  }

}
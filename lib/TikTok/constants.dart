import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_clone/TikTok/view/screens/add_video.dart';
import 'package:tiktok_clone/TikTok/view/screens/display_screen.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/TikTok/view/screens/feed_screen.dart';
import 'package:tiktok_clone/TikTok/view/screens/profile_screen.dart';
import 'dart:math';
import 'package:tiktok_clone/TikTok/view/screens/search_screen.dart';



// getRandomColor() => Colors.primaries[Random().nextInt(Colors.primaries.length)];

getRandomColor() => [
  Colors.blueAccent,
  Colors.redAccent,
  Colors.greenAccent,
][Random().nextInt(3)];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;
const Color primary=Color(0xFF4b68ff);

var pageindex = [
  DisplayVideo_Screen(),
  SearchScreen(),
  addVideoScreen(),
  FeedScreen(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];
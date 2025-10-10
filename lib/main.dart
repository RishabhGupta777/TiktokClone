import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';
import 'package:tiktok_clone/Chat/controller/select_person_provider.dart';
import 'package:tiktok_clone/TikTok/view/screens/Home.dart';

import 'TikTok/constants.dart';
import 'TikTok/controller/auth_controller.dart';
import 'TikTok/view/screens/auth/signup_screen.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value){
    Get.put(AuthController());

  });
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => SelectPersonProvider()),
        ],
        child: const MyApp(), // Use 'const' with the constructor to improve performance.
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TikTok Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(

          scaffoldBackgroundColor: backgroundColor
      ),
      home: HomeScreen(),
    );
  }
}
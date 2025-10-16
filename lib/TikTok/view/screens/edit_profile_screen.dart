import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/Chat/view/widgets/attach_icons.dart';
import 'package:tiktok_clone/TikTok/controller/edit_profile_controller.dart';
import 'package:tiktok_clone/TikTok/controller/profile_controller.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}


class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController textEditingController = TextEditingController();
  EditProfileController editProfileController = Get.put(EditProfileController());
  final ProfileController profileController = Get.put(ProfileController());

  void _editInfo(String title, VoidCallback onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "Enter new $title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      onSave();
                      Navigator.pop(context);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0), // Height of the line
            child: Container(
              color: Colors.black12, // Line color
              height: 1.0, // Thickness of the line
            ),
          ),
        ),
        body:Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25,),
                Center(
                  child: Stack(
                      children:[
                        CircleAvatar(
                              radius: 77, // Adjust the size
                              backgroundColor: Colors.grey[200],
                              backgroundImage: null,
                              child: CachedNetworkImage(
                                imageUrl: profileController.user['profilePic'],
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 77,
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                        // Camera Icon Positioned Bottom Right
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green, // Background color of the icon
                            ),
                            child: IconButton(
                                onPressed: (){
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.only(top:40),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    AttachIcons(
                                                      onPressed: () {
                                                        editProfileController.pickImageFromGallery();
                                                        Navigator.pop(context);
                                                      },
                                                      icon: const Icon(Icons.photo, color: Colors.blue),
                                                      iconName: const Text('Gallery'),
                                                    ),
                                                    AttachIcons(
                                                      onPressed: () {
                                                        editProfileController.pickImageFromCamera();
                                                        Navigator.pop(context);
                                                      },
                                                      icon: const Icon(Icons.camera_alt, color: Colors.red),
                                                      iconName: const Text('Camera'),
                                                    ),
                                                  ],
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, 'Cancel'),
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                                icon:  const Icon(Icons.camera_alt_outlined, color: Colors.white, size:26)),
                          ),
                        ),
                      ]
                  ),
                ),
                const SizedBox(height: 40,),
                Information(
                  onTap:(){
                    textEditingController.text=profileController.user['name'];
                    _editInfo(
                      "Name",
                        () {
                          editProfileController.updateName(textEditingController.text);
                          textEditingController.clear();
                        }
                    );
                  },
                  icon:const Icon(Icons.person_outline_sharp),
                  infoName:'Name',
                  info: profileController.user['name'],
                ),
                Information(
                  onTap:(){
                    textEditingController.text=profileController.user['about'];
                    _editInfo(
                        "About",
                            () {
                          editProfileController.updateAbout(textEditingController.text);
                          textEditingController.clear();
                        }
                    );
                  },
                  icon:const Icon(Icons.info_outline),
                  infoName:'About',
                  info: profileController.user['about'],
                ),
                Information(
                  onTap:(){},
                  icon:const Icon(Icons.email_outlined),
                  infoName:'Email',
                  info: editProfileController.getUserUid(),
                )
              ],
            );
          }
        )
    );
  }
}

class Information extends StatelessWidget {
  const Information({
    super.key,
    required this.icon,
    required this.infoName,
    required this.info,
    required this.onTap
  });
  final Icon icon;
  final String infoName;
  final String info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 25,),
            icon,
            const SizedBox(width: 25,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(infoName),
                Text(info),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




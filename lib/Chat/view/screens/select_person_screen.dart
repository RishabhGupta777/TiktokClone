import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';
import 'package:tiktok_clone/Chat/controller/select_person_provider.dart';
import 'package:tiktok_clone/TikTok/constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SelectPersonScreen extends StatefulWidget {
  final List<String> selectedMessageIds;
  const SelectPersonScreen({super.key, required this.selectedMessageIds});

  @override
  State<SelectPersonScreen> createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends State<SelectPersonScreen> {
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser;
    context.read<SelectPersonProvider>().getInitialAllChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    final selectPersonProvider = Provider.of<SelectPersonProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: (){
                selectPersonProvider.clearSelectedChatRooms();
                Navigator.pop(context);
              }
              , icon: Icon(Icons.arrow_back)),
          title: Text(
            selectPersonProvider.selectedChatRoomIds.isEmpty
                ? 'Forward message to'
                : '${selectPersonProvider.selectedChatRoomIds.length} selected',
          ),
          actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                },
              ),
          ],
        ),
        body: SafeArea(
          child: loggedInUser == null
              ? const Center(child: Text("Not logged in"))
              : Consumer<SelectPersonProvider>(
                  builder: (context, provider, child) {
                    final chatRooms = provider.getAllChatRooms();
                    if (chatRooms.isEmpty) {
                      return const Center(child: Text("No chats yet"));
                    }

                    return ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatRooms[index];
                        final chatRoomData =
                            chatRoom.data() as Map<String, dynamic>;
                        final users =
                            List<String>.from(chatRoom['users'] ?? []);
                        final otherUser =
                            users.firstWhere((u) => u != loggedInUser!.uid);

                        return UserBubble(
                          chatRoom: chatRoom as QueryDocumentSnapshot,
                          otherUser: otherUser,
                        );
                      },
                    );
                  },
                ),
        ),
        floatingActionButton:
            selectPersonProvider.selectedChatRoomIds.isNotEmpty
                ? FloatingActionButton(
                    backgroundColor: primary,
                    tooltip: 'Send message to Selected Person',
                    child: Icon(Icons.send),
                    onPressed: () async {
                      Navigator.pop(context);
                      await selectPersonProvider
                          .forwardMessage(widget.selectedMessageIds);
                      chatProvider.clearSelection();
                    },
                  )
                : null);
  }
}

class UserBubble extends StatefulWidget {
  final QueryDocumentSnapshot chatRoom;
  final String otherUser;

  const UserBubble({
    super.key,
    required this.chatRoom,
    required this.otherUser,
  });

  @override
  State<UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends State<UserBubble> {
  String? userProfileUrl;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUser)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          userProfileUrl = data?['profilePic'];
          userName = data?['name'] ?? widget.otherUser;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectPersonProvider>(context);
    final isSelected =
        provider.selectedChatRoomIds.contains(widget.chatRoom.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () => provider.toggleChatRoomSelection(widget.chatRoom.id),
        leading: userProfileUrl != null
            ? CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(userProfileUrl!),
              )
            : const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),
        title: Text(
          userName ?? widget.otherUser,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.circle_outlined),
      ),
    );
  }
}

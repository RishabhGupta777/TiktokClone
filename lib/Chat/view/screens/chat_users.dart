import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_clone/Chat/view/screens/ChatScreen.dart';
import 'package:tiktok_clone/TikTok/view/screens/search_screen.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatUsers extends StatefulWidget {
  static const String id = 'home_page';

  const ChatUsers({super.key});
  @override
  State<ChatUsers> createState() => _ChatUsersState();
}

class _ChatUsersState extends State<ChatUsers> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    setState(() {
      loggedInUser =_auth.currentUser;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡️ Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black12),
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [MessageStream()],
        ),
      ),
    );
  }
}

// 🔹 Stream that shows only chatrooms where the current user is part of `users` list
class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = loggedInUser?.uid.split('@').first;

    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ChatRoom')
          .where('users', arrayContains: currentUser)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatRooms = snapshot.data!.docs;
        List<UserBubble> userBubbles = [];

        for (var chatRoom in chatRooms) {
          final users = List<String>.from(chatRoom['users']);
          final otherUser = users.firstWhere((u) => u != currentUser);

          userBubbles.add(UserBubble(chatRoom: chatRoom, otherUser: otherUser));
        }

        if (userBubbles.isEmpty) {
          return const Expanded(
            child: Center(child: Text("No chats yet")),
          );
        }

        return Expanded(
          child: ListView(
            children: userBubbles,
          ),
        );
      },
    );
  }
}

// 🔹 Each chat entry
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
  String? lastMessage;
  Timestamp? lastTimestamp;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchLastMessage();
  }

  // Get other user's info
  void _fetchUserInfo() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUser)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          userProfileUrl = data?['profilePic'];
          userName = data?['name'] ?? ' ';
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  // Get latest message from chats subcollection
  void _fetchLastMessage() {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(widget.chatRoom.id)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final msg = snapshot.docs.first.data();
        setState(() {
          lastMessage = msg['messageText'] ?? '';
          lastTimestamp = msg['timestamp'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = lastTimestamp != null
        ? TimeOfDay.fromDateTime(lastTimestamp!.toDate()).format(context)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(receiver: widget.otherUser), // 👈 keep your ChatScreen
            ),
          );
        },
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
          userName ?? " ",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          lastMessage ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }
}

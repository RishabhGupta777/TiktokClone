import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';
import 'package:tiktok_clone/Chat/controller/select_person_provider.dart';
import 'package:tiktok_clone/Chat/model/message.dart';
import 'package:tiktok_clone/Chat/view/widgets/message_bubble.dart';


class MessageStream extends StatelessWidget {
  final String receiver;
  const MessageStream({super.key, required this.receiver});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = chatProvider.loggedInUser?.uid ?? "";

    // Generate same chatRoomId as in ChatProvider
    String getChatRoomId(String user1, String user2) {
      List<String> sorted = [user1, user2]..sort();
      return "${sorted[0]}_${sorted[1]}";
    }

    final chatRoomId = getChatRoomId(currentUser, receiver);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> bubbles = [];

        for (var doc in messages) {
          final msg = Message.fromSnap(doc);

          ///Skip messages deleted for current user
          final deletedFor = (doc['deletedFor'] ?? []) as List;
          if (deletedFor.contains(currentUser)) continue;

          ///for blue tick or read done
          if (msg.sendBy != currentUser && !msg.isRead) {
            chatProvider.markMessageAsRead(doc.id,receiver);
          }

          bubbles.add(
            MessageBubble(
              id: doc.id,
              text: msg.messageText,
              sender: msg.sendBy,
              isMe: msg.sendBy == currentUser,
              timestamp: msg.timestamp,
              mediaUrls: msg.mediaUrl,
              isRead:msg.isRead,
            ),
          );
        }


        return Expanded(
          child: ListView(
            reverse: true,
            children: bubbles,
          ),
        );
      },
    );
  }
}

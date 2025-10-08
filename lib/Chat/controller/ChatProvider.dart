import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;


class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? loggedInUser;
  bool? isMe;
  String? messageText;
  String? userProfileUrl;
  String? userName;

  // Multiple selection
  final List<String> selectedMessageIds = [];
  final Map<String, String> selectedMessages = {}; // id → text
  final Map<String, bool> selectedOwnership = {}; // id → isMe

  ChatProvider() {
    getCurrentUser();
  }

  void getCurrentUser() {
    loggedInUser = _auth.currentUser;
    notifyListeners();
  }

  Future<void> fetchUserInfo(String receiver) async {
    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(receiver).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;
      userProfileUrl = data?['profilePic'];
      userName = data?['name'];
      notifyListeners();
    }
  }

  // Create a chatroomId based on sender + receiver
  String getChatRoomId(String user1, String user2) {
    List<String> sorted = [user1, user2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  // Toggle selection
  void selectMessage(String id, String text, bool isMine) {
    if (selectedMessageIds.contains(id)) {
      selectedMessageIds.remove(id);
      selectedMessages.remove(id);
      selectedOwnership.remove(id);
    } else {
      selectedMessageIds.add(id);
      selectedMessages[id] = text;
      selectedOwnership[id] = isMine;
      isMe = isMine;
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedMessageIds.clear();
    selectedMessages.clear();
    selectedOwnership.clear();
    isMe = null;
    notifyListeners();
  }

  void updateMessageText(String text) {
    messageText = text;
    notifyListeners();
  }


  Future<List<String>> uploadMedia(List<XFile> files) async {
    List<String> downloadUrls = [];

    for (var file in files) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_media/${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}');

      final uploadTask = await ref.putFile(File(file.path));
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }


  Future<void> sendMessage(String receiver, {List<XFile>? mediaFiles}) async {
    final senderUid = loggedInUser?.uid ?? '';
    final chatRoomId = getChatRoomId(senderUid, receiver);
    final chatRoomRef = _firestore.collection('ChatRoom').doc(chatRoomId);

    await chatRoomRef.set({
      'chatroomId': chatRoomId,
      'users': [senderUid, receiver],
    }, SetOptions(merge: true));

    final chatsRef = chatRoomRef.collection('chats');


    String type = 'text';

    // Upload media if available
    // Prepare media list
    List<Map<String, String>> mediaList = [];

    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      // Upload all files
      final urls = await uploadMedia(mediaFiles);

      // ✅ Pair each uploaded file with its type
      for (int i = 0; i < mediaFiles.length; i++) {
        final file = mediaFiles[i];
        final url = urls[i];
        final fileType = file.path.endsWith('.mp4') ? 'video' : 'image';
        mediaList.add({'url': url, 'type': fileType});
      }
    }

    // Don’t send empty messages
    if (messageText == null &&
        (mediaList.isEmpty)) return;


    // If exactly 1 message selected → edit
    if (selectedMessageIds.length == 1) {
      await chatsRef.doc(selectedMessageIds.first)
          .update({
        'messageText': messageText,
        'isRead': false,
      });
      clearSelection();
    } else {
    await chatsRef.add({
      'messageText': messageText ?? '',
      'sendBy': senderUid,
      'timestamp': FieldValue.serverTimestamp(),
      'mediaUrl': mediaList,
      'isRead': false,
    });
  }
    messageText = null;
    notifyListeners();
  }


  Future<void> deleteMessages(String receiver) async {
    final senderUid = loggedInUser?.uid ?? '';
    final chatRoomId = getChatRoomId(senderUid, receiver);
    final chatsRef = _firestore.collection('ChatRoom').doc(chatRoomId).collection('chats');

    for (String id in selectedMessageIds) {
      await chatsRef.doc(id).delete();
    }
    clearSelection();
  }

  Future<void> markMessageAsRead(String messageId,String receiver) async {
    final senderUid = loggedInUser?.uid ?? '';
    final chatRoomId = getChatRoomId(senderUid, receiver);
    await _firestore.collection('ChatRoom').doc(chatRoomId).collection('chats').doc(messageId).update({
      'isRead': true,
    });
  }

  bool get isSelectionActive => selectedMessageIds.isNotEmpty;

  bool isMessageSelected(String id) => selectedMessageIds.contains(id);
}

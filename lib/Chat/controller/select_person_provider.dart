import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SelectPersonProvider with ChangeNotifier {
  String currentChatRoomId = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Keep track of selected chatrooms
  final Set<String> _selectedChatRoomIds = {};
  Set<String> get selectedChatRoomIds => _selectedChatRoomIds;

  /// Select or unselect a chatroom
  void toggleChatRoomSelection(String chatRoomId) {
    if (_selectedChatRoomIds.contains(chatRoomId)) {
      _selectedChatRoomIds.remove(chatRoomId);
    } else {
      _selectedChatRoomIds.add(chatRoomId);
    }
    notifyListeners();
  }

  /// Clear all selected chatrooms
  void clearSelectedChatRooms() {
    _selectedChatRoomIds.clear();
    notifyListeners();
  }

  /// Set current chatroom ID (from which messages are being forwarded)
  void getCurrentChatRoomId(String chatRoomId) {
    currentChatRoomId = chatRoomId;
    notifyListeners();
  }


  /// Forward selected messages to selected chatrooms
  Future<void> forwardMessage(List<String> selectedMessageIds) async {
    if (_selectedChatRoomIds.isEmpty || selectedMessageIds.isEmpty) return;

    try {
      for (final chatRoomId in _selectedChatRoomIds) {
        for (final messageId in selectedMessageIds) {
          final messageDoc = await FirebaseFirestore.instance
              .collection('ChatRoom')
              .doc(currentChatRoomId)
              .collection('chats')
              .doc(messageId)
              .get();

          if (!messageDoc.exists) continue;
          final message = messageDoc.data()!;

          await FirebaseFirestore.instance
              .collection('ChatRoom')
              .doc(chatRoomId)
              .collection('chats')
              .add({
            'messageText': message['messageText'],
            'mediaUrl': message['mediaUrl'],
            'sendBy': _auth.currentUser!.uid,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'deletedFor': [],
            'isForwarded': true,
          });
        }
      }

      clearSelectedChatRooms(); // clear after forwarding
    } catch (e) {
      debugPrint("Error forwarding message: $e");
    }
  }


  ///give list of all recent chat user list
  List<DocumentSnapshot> _mData = [];
  List<DocumentSnapshot> getAllChatRooms() => _mData;

  void getInitialAllChatRooms() {
    _firestore
        .collection('ChatRoom')
        .where('users', arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      _mData = snapshot.docs;
      notifyListeners();
    });
  }

}

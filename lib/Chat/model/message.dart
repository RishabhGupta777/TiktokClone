import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  String messageText;
  String sendBy;
  Timestamp ? timestamp;
  List<dynamic> mediaUrl;
  bool isRead;
  String type;

  Message({
    required this.messageText,
    required this.sendBy,
    required this.timestamp,
    required this.mediaUrl,
    required this.isRead,
    required this.type,
  });

  Map<String, dynamic> toJson()=>{
    "messageText" : messageText,
    "sendBy" : sendBy,
    "timestamp" : timestamp,
    "mediaUrl":mediaUrl,
    "isRead":isRead,
    "type":type,
  };

  static Message fromSnap(DocumentSnapshot snap){
    var sst = snap.data() as Map<String,dynamic>;

    return Message(
        messageText: sst["messageText"],
        sendBy: sst["sendBy"],
        timestamp: sst["timestamp"],
        mediaUrl:sst["mediaUrl"],
        isRead:sst["isRead"],
        type: sst["type"],
    );
  }

}
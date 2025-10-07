import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  String messageText;
  String sendBy;
  Timestamp ? timestamp;
  List<Map<String,String>> mediaUrl; //here two maps exist one for url and another for type-->each item: {"url": "...", "type": "..."}
  bool isRead;

  Message({
    required this.messageText,
    required this.sendBy,
    required this.timestamp,
    required this.mediaUrl,
    required this.isRead,
  });

  Map<String, dynamic> toJson()=>{
    "messageText" : messageText,
    "sendBy" : sendBy,
    "timestamp" : timestamp,
    "mediaUrl":mediaUrl,
    "isRead":isRead,
  };

  static Message fromSnap(DocumentSnapshot snap){
    var sst = snap.data() as Map<String,dynamic>;

    return Message(
        messageText: sst["messageText"],
        sendBy: sst["sendBy"],
        timestamp: sst["timestamp"],
      mediaUrl: (sst["mediaUrl"] as List)
          .map((e) => Map<String, String>.from(e))
          .toList(),
        isRead:sst["isRead"],
    );
  }

}
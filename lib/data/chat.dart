import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This manages the basic functions for sending and receiving chat Messages
class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /// For sending chat messages
  Future<void> sendMessage(String recieverID, String message) async {
    // data
    final currentUserID = _auth.currentUser!.uid;
    final currentUserEmail = _auth.currentUser!.email!;
    final timestamp = Timestamp.now();

    // setup msg
    var newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: recieverID,
        message: message,
        timestamp: timestamp);

    // add new message to db
    String chatroomID = userChatroomID([currentUserID, recieverID]);
    await _store
        .collection("ChatRooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// For recieving chat messages
  Stream<QuerySnapshot> getMessages(String userID, String subjectID) {
    String chatroomID = userChatroomID([userID, subjectID]);

    return _store
        .collection("ChatRooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// For creating the chatroom id reliably
  String userChatroomID(List<String> ids) {
    var userIDs = ids.toList(); // clone for safety
    userIDs.sort();
    return userIDs.join('_');
  }
}

/// A chat message
class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message(
      {required this.senderID,
      required this.senderEmail,
      required this.receiverID,
      required this.message,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': receiverID,
      'message': message,
      'timestamp': timestamp
    };
  }
}

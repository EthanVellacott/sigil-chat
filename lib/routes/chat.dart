import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'package:sigil/data/auth.dart';
import 'package:sigil/data/chat.dart';
import 'package:sigil/widgets.dart';

/// A chat screen, between the current user and one of their friends
class ChatScreen extends StatelessWidget {
  ChatScreen({super.key, required this.subjectEmail, required this.subjectID});

  final String subjectEmail;
  final String subjectID;

  final TextEditingController messageController = TextEditingController();

  final ChatService _chat = ChatService();
  final AuthService _auth = AuthService();

  Timestamp? _lastTimestamp;

  void sendMessage() async {
    // exit early if text is empty
    if (messageController.text.isEmpty) {
      return;
    }

    await _chat.sendMessage(subjectID, messageController.text);

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    _lastTimestamp = null;
    return Scaffold(
        appBar: AppBar(
          title: Text(subjectEmail),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            Container(
                padding: const EdgeInsets.all(5),
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: SigilEntryField(
                        controller: messageController,
                        hintText: '...',
                        onSubmit: (value) => sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: sendMessage, icon: const Icon(Icons.send))
                  ],
                ))
          ],
        ));
  }

  Widget _buildMessageList() {
    String senderID = _auth.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chat.getMessages(senderID, subjectID),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        }));
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _auth.getCurrentUser()!.uid;

    Widget messageItem;
    if (isCurrentUser) {
      messageItem = Row(
        children: [
          const Spacer(),
          messageBubble(data['message'], data['timestamp'], Colors.blue)
        ],
      );
    } else {
      messageItem = Row(
        children: [
          messageBubble(data['message'], data['timestamp'], Colors.blueGrey),
          const Spacer()
        ],
      );
    }

    if (_lastTimestamp == null) {
      _lastTimestamp = data['timestamp'];
      messageItem = Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(DateFormat('d MMMM, kk:mm')
                  .format(_lastTimestamp!.toDate()))),
          messageItem
        ],
      );
    }

    return messageItem;
  }
}

Widget messageBubble(String text, Timestamp timestamp, Color color) {
  return JustTheTooltip(
      preferredDirection: AxisDirection.right,
      content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(DateFormat('d MMMM, kk:mm').format(timestamp.toDate()))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(30)),
        child: Text(
          text,
          overflow: TextOverflow.fade,
        ),
      ));
}

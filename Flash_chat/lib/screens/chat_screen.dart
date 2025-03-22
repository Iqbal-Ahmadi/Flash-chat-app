// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User? loginUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String? userMessage;
  final textController = TextEditingController(text: '');

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loginUser = user;
        print(loginUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var msg in messages.docs) {
  //     print(msg.data());
  //   }
  // }
  // void getmessageStream() async {
  //   final messages = _firestore.collection('messages').snapshots();
  //   await for (var msg in messages) {
  //     for (var data in msg.docs.reversed) {
  //       print(data.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        userMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      textController.clear();
                      _firestore.collection('messages').add({
                        'text': userMessage,
                        'sender': loginUser!.email,
                        'timestamp': Timestamp.now()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
          final messages = asyncSnapshot.data!.docs;
          List<TextBubble> messegeWidgets = [];
          for (var message in messages) {
            final sender = message.data()['sender'];
            final text = message.data()['text'];
            final currentUser = loginUser!.email;
            final messegeWidget = TextBubble(
              text: text,
              sender: sender,
              isme: currentUser == sender,
            );
            messegeWidgets.add(messegeWidget);
          }
          return Expanded(
              child: ListView(
            children: messegeWidgets,
            reverse: true,
          ));
        });
  }
}

class TextBubble extends StatelessWidget {
  const TextBubble({super.key, this.sender, this.text, this.isme});
  final String? text;
  final String? sender;
  final bool? isme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment:
              isme == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender.toString(),
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Material(
              borderRadius: isme == true
                  ? BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30))
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
              elevation: 5,
              color: isme == true ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '$text',
                  style: TextStyle(
                      fontSize: 15.0,
                      color: isme == true ? Colors.white : Colors.black54),
                ),
              ),
            ),
          ]),
    );
  }
}

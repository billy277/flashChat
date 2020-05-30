import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'msg_bubble.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  String messageText = '';

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print('this is in the chat screen ${loggedInUser.email}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /* code to pull data from firestore */
//  void pullMessages() async {
//    final messages = await _firestore.collection('messages').getDocuments();
//    for (var doc in messages.documents) {
//      print(doc.data);
//    }
//  }
  /*code to push data from firestore*/
  void pushMessages() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var doc in snapshot.documents) {
        print(doc.data);
      }
    }
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
                //Implement logout functionality

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
            MsgStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      print(
                          'adding message to firestore by ${loggedInUser.email}');
                      _firestore.collection('messages').add(
                        {
                          'sender': loggedInUser.email,
                          'text': messageText,
                          'createdDate': DateTime.now(),
                        },
                      );
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

class MsgStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //taking streams and turning them into widgets using a streamBuilder - this takes a stream: and also a builder: property
    //stream can be the firebase stream
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('createdDate').snapshots(),
      builder: (context, snapshot) {
        // ignore: missing_return
        //builder takes a build strategy callback with 2 inputs (context, snapshot). This is a flutter async snapshot - which contains the snapshot from firebase inside its .data property.
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MsgBubble> list = [];
        for (var doc in messages) {
          final docText = doc.data['text'];
          final docSender = doc.data['sender'];
          final currentUser = loggedInUser.email;
          final tmp = MsgBubble(
              sender: docSender,
              text: docText,
              thisSender: currentUser == docSender);

          list.add(tmp);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            children: list,
          ),
        );
      },
    );
  }
}

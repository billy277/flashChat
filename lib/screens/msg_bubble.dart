import 'package:flutter/material.dart';

class MsgBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool thisSender;

  MsgBubble({this.sender, this.text, this.thisSender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            thisSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text('$sender',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 8,
              )),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: thisSender ? Radius.circular(30) : Radius.circular(0),
              topRight: thisSender ? Radius.circular(0) : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 10,
            color: thisSender ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: Text(
                '$text',
                style: TextStyle(
                  color: thisSender ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

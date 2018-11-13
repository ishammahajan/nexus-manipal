import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal/onesignal.dart';

class ChatPage extends StatefulWidget {
  DocumentSnapshot chatWith;

  ChatPage({@required this.chatWith});

  @override
  _ChatPageState createState() => _ChatPageState(chatWith: chatWith);
}

class _ChatPageState extends State<ChatPage> {
  DocumentSnapshot chatWith;
  DocumentSnapshot ownerDoc;

  _ChatPageState({@required this.chatWith});

  var _editControl = TextEditingController();

  Future<FirebaseUser> mainFuture() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    ownerDoc = await Firestore.instance.collection("Users").document(owner.uid).get();
    return owner;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: mainFuture(),
        builder: (_, owner) {
          if (!owner.hasData) return Center(child: CircularProgressIndicator());
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: <Widget>[
                  CircleAvatar(backgroundImage: NetworkImage(chatWith['PhotoUrl']),),
                  Container(width: 8.0,),
                  Text(chatWith['DisplayName']),
                ],
              ),
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection("Chats")
                          .document(owner.data.uid)
                          .collection(chatWith['Uid'])
                          .orderBy("Timestamp", descending: true)
                          .snapshots(),
                      builder: (_, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) return Center(child: CircularProgressIndicator());
                        return ListView(
                            reverse: true,
                            children: snapshot.data.documents.map((chat) {
                              /*return Column(
                                children: <Widget>[
                                  ListTile(
                                    trailing: Container(
                                      padding: EdgeInsets.all(14.0),
                                      child: Text(chat['String']),
                                      decoration: chat['Sender']
                                          ? BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(0.0),
                                                  bottomLeft: Radius.circular(20.0),
                                                  bottomRight: Radius.circular(20.0),
                                                  topLeft: Radius.circular(20.0)))
                                          : BoxDecoration(
                                              border: Border.all(color: Theme.of(context).primaryTextTheme.body1.color),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20.0),
                                                  bottomLeft: Radius.circular(20.0),
                                                  bottomRight: Radius.circular(20.0),
                                                  topLeft: Radius.circular(0.0))),
                                    ),
                                    dense: true,
                                  ),
                                  Container(height: 8.0,)
                                ],
                              );*/
                              if (chat['Sender']) {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      trailing: Container(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(chat['String']),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(0.0),
                                                bottomLeft: Radius.circular(20.0),
                                                bottomRight: Radius.circular(20.0),
                                                topLeft: Radius.circular(20.0))),
                                      ),
                                      dense: true,
                                    ),
                                    Container(height: 8.0)
                                  ],
                                );
                              } else {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(chat['String']),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).primaryTextTheme.body1.color),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomLeft: Radius.circular(20.0),
                                                bottomRight: Radius.circular(20.0),
                                                topLeft: Radius.circular(0.0))),
                                      ),
                                      dense: true,
                                    ),
                                    Container(height: 8.0)
                                  ],
                                );
                              }
                            }).toList());
                      }),
                ),
                Container(
                  height: 8.0,
                ),
                Divider(
                  color: Theme.of(context).primaryTextTheme.body1.color,
                ),
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                        icon: CircleAvatar(
                          backgroundImage: NetworkImage(ownerDoc['PhotoUrl']),
                        ),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
                    controller: _editControl,
                    focusNode: FocusNode(),
                  ),
                  dense: true,
                  trailing: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        String str = _editControl.text;
                        _editControl.clear();
                        await Firestore.instance
                            .collection("Chats")
                            .document(owner.data.uid)
                            .collection(chatWith['Uid'])
                            .add({"Timestamp": DateTime.now(), "String": str, "Sender": true});
                        await Firestore.instance
                            .collection("Chats")
                            .document(chatWith['Uid'])
                            .collection(owner.data.uid)
                            .add({"Timestamp": DateTime.now(), "String": str, "Sender": false});
                        print(1);
                        await Firestore.instance
                            .collection("Chats")
                            .document(owner.data.uid)
                            .collection(chatWith['Uid'])
                            .document("LastNotification")
                            .get()
                            .then((doc) async {
                          if (!doc.exists) {
                            var notif = OSCreateNotification(
                                content: "has sent you a new message!\n" + str,
                                playerIds: <String>[chatWith['NotificationId']],
                                heading: owner.data.displayName,
                                additionalData: {"chatWith": ownerDoc['Uid']});
                            var response = await OneSignal.shared.postNotification(notif);
                            await Firestore.instance
                                .collection("Chats")
                                .document(owner.data.uid)
                                .collection(chatWith['Uid'])
                                .document("LastNotification")
                                .setData({"Value": DateTime.now()});
                            await Firestore.instance
                                .collection("Chats")
                                .document(chatWith['Uid'])
                                .collection(owner.data.uid)
                                .document("LastNotification")
                                .setData({"Value": DateTime.now()});
                            print(response);
                          } else if (DateTime.now().difference(doc['Value']).inHours >= 1) {
                            var notif = OSCreateNotification(
                                content: "has sent you a new message!\n" + str,
                                playerIds: <String>[chatWith['NotificationId']],
                                heading: owner.data.displayName,
                                additionalData: {"chatWith": ownerDoc['Uid']});
                            var response = await OneSignal.shared.postNotification(notif);
                            await Firestore.instance
                                .collection("Chats")
                                .document(owner.data.uid)
                                .collection(chatWith['Uid'])
                                .document("LastNotification")
                                .setData({"Value": DateTime.now()});
                            await Firestore.instance
                                .collection("Chats")
                                .document(chatWith['Uid'])
                                .collection(owner.data.uid)
                                .document("LastNotification")
                                .setData({"Value": DateTime.now()});
                            print(response);
                          } //aeefffd6-31e8-4e6f-afac-258a83ee1366
                        });
                        print(2);
                      }),
                )
              ],
            ),
          );
        });
  }
}

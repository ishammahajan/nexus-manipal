import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfessionsPage extends StatefulWidget {
  @override
  _ConfessionsPageState createState() => _ConfessionsPageState();
}

class _ConfessionsPageState extends State<ConfessionsPage> {
  TextEditingController control = new TextEditingController();
  DocumentSnapshot conf;
  DocumentSnapshot userDoc;

  Future<DocumentSnapshot> getConf() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    userDoc = await Firestore.instance.collection("Users").document(user.uid).get();
    conf = await Firestore.instance.collection("Confessions").document(userDoc['confDoc']).get();
    return conf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confessions"),
      ),
      floatingActionButton: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (_, snapshot) {
          if(!snapshot.hasData || snapshot.data == null) return Container(height: 0.0, width: 0.0,);
          return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                showDialog(
                    context: context,
                    child: SimpleDialog(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                              child: Text(
                                "What do you confess to?",
                                textScaleFactor: 1.7,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                              child: Text(
                                "Don't worry, we post it anonymously.",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
                              child: Text(
                                "(this will be verified to root out spam\nand strict confidentiality will be maintained)",
                                textScaleFactor: 0.8,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: control,
                                maxLines: null,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                                  child: FlatButton(
                                      onPressed: () async {
                                        String rand = "${new Random().nextInt(10000)}";
                                        await Firestore.instance.collection("Confessions").add({
                                          "Title": rand,
                                          "Content": control.text,
                                          "Timestamp": DateTime.now(),
                                          "Valid": false,
                                          "Uid": user.uid
                                        }).then((doc) async {
                                          await Firestore.instance.collection("Users").document(userDoc.documentID).updateData({
                                            "confDoc": doc.documentID,
                                          });
                                        });
                                        control.clear();
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                      child: Text("Submit")),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ));
              });
        },
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getConf(),
        builder: (_, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                child: Text(
                  "My Latest Entry",
                  textScaleFactor: 1.7,
                ),
              ),
              Divider(
                indent: 16.0,
                color: Theme.of(context).primaryTextTheme.body1.color,
              ),
              ListTile(
                title: (conf != null && conf.exists && conf['Valid']) ? Text(conf['Title']) : Text("No entry, or pending approval"),
                subtitle: (conf != null && conf.exists && conf['Valid']) ? Text(conf['Content']) : Text(""),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ExpandedConfession(
                      conf: conf,
                      uid: userDoc.documentID,
                    );
                  }));
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Other Confessions",
                  textScaleFactor: 1.7,
                ),
              ),
              Divider(
                indent: 16.0,
                color: Theme.of(context).primaryTextTheme.body1.color,
              ),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection("Confessions")
                          .where("Valid", isEqualTo: true)
                          .orderBy("Timestamp", descending: true)
                          .snapshots(),
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                        if (snapshot.data == null) return Center(child: CircularProgressIndicator());
                        return ListView(
                          children: snapshot.data.documents.map((doc) {
                            return ListTile(
                              title: Text(doc['Title']),
                              subtitle: Text(doc['Content']),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                  return ExpandedConfession(uid: doc['Uid'], conf: doc);
                                }));
                              },
                            );
                          }).toList(),
                        );
                      }))
            ],
          );
        },
      ),
    );
  }
}

class ExpandedConfession extends StatefulWidget {
  String uid;
  DocumentSnapshot conf;

  ExpandedConfession({this.uid, this.conf});

  @override
  _ExpandedConfessionState createState() => _ExpandedConfessionState(uid: uid, conf: conf);
}

class _ExpandedConfessionState extends State<ExpandedConfession> {
  String uid;
  DocumentSnapshot conf;

  _ExpandedConfessionState({this.uid, this.conf});

  TextEditingController _editControl = new TextEditingController();
  DocumentSnapshot ownerDoc;

  Future<DocumentSnapshot> defaultFuture() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    ownerDoc = await Firestore.instance.collection("Users").document(owner.uid).get();
    return ownerDoc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: defaultFuture(),
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return Scaffold(
            appBar: AppBar(title: Text(conf['Title'])),
            body: Center(child: CircularProgressIndicator()),
          );
        return Scaffold(
          appBar: AppBar(
            title: Text(conf['Title']),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(conf['Content']),
              ),
              Divider(color: Theme.of(context).primaryTextTheme.body1.color),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("Confessions")
                    .document(conf.documentID)
                    .collection("Comments")
                    .orderBy("Timestamp", descending: true)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    reverse: true,
                    children: snapshot.data.documents.map((doc) {
                      return ListTile(
                        title: Text(doc['Content']),
                        subtitle: Text(doc['OwnerName']),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(doc['OwnerPhotoUrl']),
                        ),
                      );
                    }).toList(),
                  );
                },
              )),
              Divider(color: Theme.of(context).primaryTextTheme.body1.color),
              ListTile(
                  title: TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                        icon: CircleAvatar(
                          backgroundImage: NetworkImage(ownerDoc['PhotoUrl']),
                        ),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
                    controller: _editControl,
                    focusNode: FocusNode(),
                    onSubmitted: (str) async {
                      _editControl.clear();
                      FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                      await Firestore.instance.collection("Confessions").document(conf.documentID).collection("Comments").add({
                        "Content": str,
                        "OwnerName": owner.displayName,
                        "OwnerUid": owner.uid,
                        "OwnerPhotoUrl": owner.photoUrl,
                        "Timestamp": DateTime.now()
                      });
                    },
                  ),
                  dense: true,
                  trailing: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        String str = _editControl.text;
                        _editControl.clear();
                        FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                        await Firestore.instance.collection("Confessions").document(conf.documentID).collection("Comments").add({
                          "Content": str,
                          "OwnerName": owner.displayName,
                          "OwnerUid": owner.uid,
                          "OwnerPhotoUrl": owner.photoUrl,
                          "Timestamp": DateTime.now()
                        });
                      })),
            ],
          ),
        );
      },
    );
  }
}

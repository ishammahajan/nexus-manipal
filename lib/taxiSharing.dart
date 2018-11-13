import 'dart:async';

import 'package:chill_bruh/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:onesignal/onesignal.dart';

class TaxiSharingPage extends StatefulWidget {
  DocumentSnapshot owner;

  TaxiSharingPage({@required this.owner});

  @override
  _TaxiSharingPageState createState() => _TaxiSharingPageState(ownerDoc: owner);
}

class _TaxiSharingPageState extends State<TaxiSharingPage> {
  DocumentSnapshot ownerDoc;

  _TaxiSharingPageState({@required this.ownerDoc});

  var _stream =
      Firestore.instance.collection("TaxiRequests").where("Timestamp", isGreaterThan: DateTime.now()).orderBy("Timestamp").snapshots();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Taxi Sharing")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool ToManipal;
          bool edit;
          if (ownerDoc['TaxiRequestTime'] != null) {
            if (DateTime.now().isBefore(ownerDoc['TaxiRequestTime']) && ownerDoc['HasValidRequest'] == true) {
              await showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text(
                          "You already have a request pending. You can have only one request at a time. Do you want to edit the request?"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel")),
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              edit = true;
                            },
                            child: Text("Edit"))
                      ],
                    );
                  });
            } else {
              await showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("Are you going to the airport or the university?"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              ToManipal = false;
                              Navigator.pop(context);
                            },
                            child: Text("Airport")),
                        FlatButton(
                            onPressed: () {
                              ToManipal = true;
                              Navigator.pop(context);
                            },
                            child: Text("University")),
                      ],
                    );
                  });
            }
          } else {
            edit = true;
          }
          if (edit != null) {
            await showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("Are you going to the airport or the university?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            ToManipal = false;
                            Navigator.pop(context);
                          },
                          child: Text("Airport")),
                      FlatButton(
                          onPressed: () {
                            ToManipal = true;
                            Navigator.pop(context);
                          },
                          child: Text("University")),
                    ],
                  );
                });
          }
          if (ToManipal != null) {
            DateTime requestTime = await showDatePicker(
              context: context,
              initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              lastDate: DateTime.now().add(Duration(days: 60)),
              initialDatePickerMode: DatePickerMode.day,
            );
            if (requestTime != null) {
              TimeOfDay nd = await showTimePicker(
                initialTime: new TimeOfDay.now(),
                context: context,
              );
              if (nd != null) {
                DateTime dtn = DateTime(requestTime.year, requestTime.month, requestTime.day, nd.hour, nd.minute);
                FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                await Firestore.instance.collection("TaxiRequests").document(owner.uid).setData({
                  "OwnerName": owner.displayName,
                  "OwnerUid": owner.uid,
                  "Timestamp": dtn,
                  "ToManipal": ToManipal,
                  "Participants": 1
                }).then((docRef) async {
                  await Firestore.instance
                      .collection("Users")
                      .document(owner.uid)
                      .updateData({"HasValidRequest": true, "TaxiRequestTime": dtn, "TaxiRequestId": owner.uid}).then((docREF) {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Taxi Sharing request placed!")));
                  });
                  ownerDoc = await ownerDoc.reference.get();
                  setState(() {});
                });
                setState(() {});
              }
            }
          }
        },
        child: Icon(Icons.local_taxi),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 16.0),
            child: Text(
              "My Request",
              textScaleFactor: 1.7,
            ),
          ),
          Divider(
            indent: 16.0,
            color: Theme.of(context).primaryTextTheme.body1.color,
          ),
          (ownerDoc['HasValidRequest'] != null && ownerDoc['HasValidRequest']) && DateTime.now().isBefore(ownerDoc['TaxiRequestTime'])
              ? Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.local_taxi),
                    onTap: () async {
                      DocumentSnapshot request = await Firestore.instance.collection("TaxiRequests").document(ownerDoc['Uid']).get();
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ExpandedPage(request: request, owner: ownerDoc);
                      }));
                    },
                    title: Text(DateFormat.yMMMEd().format(ownerDoc['TaxiRequestTime']) +
                        ", at " +
                        DateFormat.jm().format(ownerDoc['TaxiRequestTime'])),
                    subtitle: Text("Request Owner: " + ownerDoc['DisplayName']),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ListTile(
                      leading: Icon(Icons.local_taxi),
                      title: Text(
                        "You don't have any pending request",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 16.0),
            child: Text(
              "Other Taxi Requests",
              textScaleFactor: 1.7,
            ),
          ),
          Divider(
            indent: 16.0,
            color: Theme.of(context).primaryTextTheme.body1.color,
          ),
          Expanded(
            child: Container(
              //padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (_, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) return Center(child: CircularProgressIndicator());
                    print(snapshot.data.documents);
                    return ListView(
                        children: snapshot.data.documents.map((request) {
                      return request['Participants'] <= 4
                          ? ListTile(
                              leading: request['ToManipal'] ? Icon(Icons.airplanemode_active) : Icon(Icons.school),
                              trailing: request['ToManipal'] ? Icon(Icons.school) : Icon(Icons.airplanemode_active),
                              title: Text(DateFormat.yMMMEd().format(request['Timestamp']) +
                                  ", at " +
                                  DateFormat.jm().format(request['Timestamp'])),
                              subtitle: Text("Request Owner: " + request['OwnerName']),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                                  return ExpandedPage(
                                    request: request,
                                    owner: ownerDoc,
                                  );
                                }));
                              },
                            )
                          : Container();
                    }).toList());
                  }),
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(onPressed: () async {
        var status = await OneSignal.shared.getPermissionSubscriptionState();
        print(status.subscriptionStatus.userId);
        var notif = OSCreateNotification(content: "testing", playerIds: <String>["aeefffd6-31e8-4e6f-afac-258a83ee1366"], heading: "Test");
        var response = OneSignal.shared.postNotification(notif);
        print(response);
      }),*/
    );
  }
}

class ExpandedPage extends StatefulWidget {
  DocumentSnapshot request;
  DocumentSnapshot owner;

  ExpandedPage({@required this.request, @required this.owner});

  @override
  _ExpandedPageState createState() => _ExpandedPageState(request: request, ownerDoc: owner);
}

class _ExpandedPageState extends State<ExpandedPage> {
  DocumentSnapshot request;
  DocumentSnapshot ownerDoc;
  QuerySnapshot allParticipants;

  _ExpandedPageState({this.request, this.ownerDoc});

  var _editControl = TextEditingController();

  Future<QuerySnapshot> buttonFuture() async {
    request = await request.reference.get();
    allParticipants = await request.reference.collection("Participants").getDocuments();
    return request.reference.collection("Participants").where("Uid", isEqualTo: ownerDoc.documentID).getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Taxi Request")),
      body: FutureBuilder<QuerySnapshot>(
          future: buttonFuture(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.local_taxi),
                    title: Text(DateFormat.yMMMEd().format(request['Timestamp']) + ", at " + DateFormat.jm().format(request['Timestamp'])),
                    subtitle: Text("Request Owner: " + request['OwnerName']),
                    trailing: Builder(builder: (_) {
                      if (!snapshot.hasData)
                        return FlatButton(
                          onPressed: () {},
                          child: Text("Join"),
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color)),
                        );
                      if (request['OwnerName'] == ownerDoc['DisplayName'])
                        return Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: Text("Are you sure you want to delete the request?"),
                                          actions: <Widget>[
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("No")),
                                            FlatButton(
                                                onPressed: () async {
                                                  await Firestore.instance.collection("TaxiRequests").document(request.documentID).delete();
                                                  QuerySnapshot toDelete = await Firestore.instance
                                                      .collection("TaxiRequests")
                                                      .document(request.documentID)
                                                      .collection("Participants")
                                                      .getDocuments();
                                                  for (int i = 0; i < toDelete.documents.length; i++) {
                                                    await Firestore.instance
                                                        .collection("Users")
                                                        .document(toDelete.documents.getRange(i, i + 1).first.documentID)
                                                        .updateData({"HasValidRequest": false});
                                                    await toDelete.documents.getRange(i, i + 1).first.reference.delete();
                                                  }
                                                  toDelete = await Firestore.instance
                                                      .collection("TaxiRequests")
                                                      .document(request.documentID)
                                                      .collection("Comments")
                                                      .getDocuments();
                                                  for (int i = 0; i < toDelete.documents.length; i++) {
                                                    await toDelete.documents.getRange(i, i + 1).first.reference.delete();
                                                  }
                                                  ownerDoc.reference.updateData({"HasValidRequest": false});
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Yes"))
                                          ],
                                        );
                                      });
                                },
                                child: Text("Delete")),
                            FlatButton(
                                onPressed: () async {
                                  bool ToManipal;
                                  await showDialog(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: Text("Are you going to the airport or the university?"),
                                          actions: <Widget>[
                                            FlatButton(
                                                onPressed: () {
                                                  ToManipal = false;
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Airport")),
                                            FlatButton(
                                                onPressed: () {
                                                  ToManipal = true;
                                                  Navigator.pop(context);
                                                },
                                                child: Text("University")),
                                          ],
                                        );
                                      });
                                  if (ToManipal != null) {
                                    DateTime requestTime = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                      lastDate: DateTime.now().add(Duration(days: 60)),
                                      initialDatePickerMode: DatePickerMode.day,
                                    );
                                    if (requestTime != null) {
                                      TimeOfDay nd = await showTimePicker(
                                        initialTime: new TimeOfDay.now(),
                                        context: context,
                                      );
                                      if (nd != null) {
                                        DateTime dtn = DateTime(requestTime.year, requestTime.month, requestTime.day, nd.hour, nd.minute);
                                        requestTime.add(Duration(hours: nd.hour, minutes: nd.minute));
                                        FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                                        Firestore.instance.collection("TaxiRequests").document(owner.uid).setData({
                                          "OwnerName": owner.displayName,
                                          "OwnerUid": owner.uid,
                                          "Timestamp": dtn,
                                          "ToManipal": ToManipal,
                                          "Participants": 1
                                        }).then((docRef) {
                                          Firestore.instance.collection("Users").document(owner.uid).updateData({
                                            "HasValidRequest": true,
                                            "TaxiRequestTime": dtn,
                                            "TaxiRequestId": owner.uid
                                          }).then((docREF) {});
                                        });
                                        ownerDoc = await Firestore.instance.collection("Users").document(owner.uid).get();
                                        setState(() {});
                                      }
                                    }
                                  }
                                },
                                child: Text("Edit"),
                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color))),
                          ],
                        );
                      if (snapshot.data.documents.length != 0) {
                        if (snapshot.data.documents.first['Uid'] == ownerDoc['Uid'])
                          return FlatButton(
                              onPressed: () async {
                                await Firestore.instance
                                    .collection("TaxiRequests")
                                    .document(request.documentID)
                                    .collection("Participants")
                                    .document(ownerDoc.documentID)
                                    .delete()
                                    .then((_) async {
                                  await Firestore.instance
                                      .collection("TaxiRequests")
                                      .document(request.documentID)
                                      .updateData({"Participants": request['Participants'] - 1});
                                  Firestore.instance
                                      .collection("Users")
                                      .document(ownerDoc.documentID)
                                      .updateData({"HasValidRequest": false});
                                });
                                setState(() {});
                              },
                              child: Text("Drop Out"),
                              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color)));
                        else
                          return FlatButton(
                            onPressed: () async {
                              await Firestore.instance
                                  .collection("TaxiRequests")
                                  .document(request.documentID)
                                  .updateData({"Participants": request['Participants'] + 1}).then((_) async {
                                await Firestore.instance
                                    .collection("TaxiRequests")
                                    .document(request.documentID)
                                    .collection("Participants")
                                    .document(ownerDoc.documentID)
                                    .setData({"Uid": ownerDoc.documentID, "Name": ownerDoc['DisplayName']});
                                await Firestore.instance.collection("Users").document(ownerDoc.documentID).updateData({
                                  "HasValidRequest": true,
                                  "TaxiRequestId": request.documentID,
                                  "TaxiRequestTime": request['Timestamp']
                                });
                              });

                              setState(() {});
                            },
                            child: Text("Join"),
                            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color)),
                          );
                      } else
                        return FlatButton(
                          onPressed: () async {
                            await Firestore.instance
                                .collection("TaxiRequests")
                                .document(request.documentID)
                                .updateData({"Participants": request['Participants'] + 1}).then((_) async {
                              await Firestore.instance
                                  .collection("TaxiRequests")
                                  .document(request.documentID)
                                  .collection("Participants")
                                  .document(ownerDoc.documentID)
                                  .setData({"Uid": ownerDoc.documentID, "Name": ownerDoc['DisplayName']});
                            });
                            setState(() {});
                          },
                          child: Text("Join"),
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color)),
                        );
                    }),
                  ),
                ),
                Divider(color: Theme.of(context).primaryTextTheme.body1.color),
                Container(
                  child: Column(children: [
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Text(request['OwnerName']),
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 16.0),
                            child: Text(
                              "Chat",
                              style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
                            ),
                          ),
                          onTap: () async {
                            DocumentSnapshot chatWith = await Firestore.instance.collection("Users").document(request['OwnerUid']).get();
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return ChatPage(chatWith: chatWith);
                            }));
                          },
                        ),
                      ],
                    )
                  ]),
                ),
                allParticipants.documents.isNotEmpty
                    ? Container(
                        child: Column(
                          children: allParticipants.documents.map((doc) {
                            return Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                  child: Text(doc['Name']),
                                ),
                                Expanded(child: Container()),
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 16.0),
                                    child: Text(
                                      "Chat",
                                      style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
                                    ),
                                  ),
                                  onTap: () async {
                                    DocumentSnapshot chatWith = await Firestore.instance.collection("Users").document(doc['Uid']).get();
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return ChatPage(chatWith: chatWith);
                                    }));
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    : ListTile(title: Text("No participants yet.", style: TextStyle(fontStyle: FontStyle.italic))),
                Divider(color: Theme.of(context).primaryTextTheme.body1.color),
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection("TaxiRequests")
                            .document(request.documentID)
                            .collection("Comments")
                            .orderBy("Timestamp", descending: true)
                            .snapshots(),
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return ListView(
                              reverse: true,
                              children: snapshot.data.documents.map((comment) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(comment['OwnerPhotoUrl']),
                                  ),
                                  title: Text(comment['Content']),
                                  subtitle: Text(comment['OwnerName']),
                                );
                              }).toList());
                        })),
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
                        await Firestore.instance.collection("TaxiRequests").document(request.documentID).collection("Comments").add({
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
                          await Firestore.instance.collection("TaxiRequests").document(request.documentID).collection("Comments").add({
                            "Content": str,
                            "OwnerName": owner.displayName,
                            "OwnerUid": owner.uid,
                            "OwnerPhotoUrl": owner.photoUrl,
                            "Timestamp": DateTime.now()
                          });
                        })),
              ],
            );
          }),
    );
  }
}

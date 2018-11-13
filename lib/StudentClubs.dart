import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentClubs extends StatefulWidget {
  @override
  _StudentClubsState createState() => _StudentClubsState();
}

class _StudentClubsState extends State<StudentClubs> with TickerProviderStateMixin {
  TabController tabController;
  bool tech = true;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this);
  }

  Future<DocumentSnapshot> getOwner() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot user = await Firestore.instance.collection("Users").document(owner.uid).get();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: getOwner(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data['isAdmin'] != null && snapshot.data['isAdmin'])
            return FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                      context: context,
                      child: SimpleDialog(
                        children: <Widget>[
                          Switch(
                              value: true,
                              onChanged: (x) {
                                tech = x;
                                print(tech);
                              }),
                          TextField(
                            onSubmitted: (str) async {
                              await Firestore.instance.collection("StudentClubs").document(str).setData({
                                "Dept": "-",
                                "Faculty": "-",
                                "Objectives": "-",
                                "PhotoUrl": "-",
                                "Pres": "-",
                                "Title": str,
                                "Type": tech ? "Technical" : "Cultural"
                              });
                              print("Hi");
                            },
                          )
                        ],
                      ));
                });
          else
            return Container();
        },
      ),
      body: NestedScrollView(
          headerSliverBuilder: (_, x) {
            return [
              SliverAppBar(
                floating: true,
                forceElevated: true,
                title: Text("Student Clubs"),
                bottom: TabBar(controller: tabController, tabs: [
                  Tab(text: "Technical"),
                  Tab(text: "Cultural")
                ]),
              )
            ];
          },
          body: TabBarView(controller: tabController, children: [
            FutureBuilder<QuerySnapshot>(
                future: Firestore.instance.collection("StudentClubs").where("Type", isEqualTo: "Technical").getDocuments(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  List clubList = snapshot.data.documents;
                  clubList.shuffle();
                  return ListView(
                      children: clubList.map((doc) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return ListView(children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Club Name",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Title'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Department and Domain",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Dept'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Objectives",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Objectives'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Faculty Advisor",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Faculty'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Student Chairman",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Pres'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      height: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ]);
                            });
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CachedNetworkImage(
                                imageUrl: doc['PhotoUrl'],
                                placeholder: Icon(
                                  FontAwesomeIcons.university,
                                  size: 100.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                doc['Title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList());
                }),
            FutureBuilder<QuerySnapshot>(
                future: Firestore.instance.collection("StudentClubs").where("Type", isEqualTo: "Cultural").getDocuments(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  List clubList = snapshot.data.documents;
                  clubList.shuffle();
                  return ListView(
                      children: clubList.map((doc) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return ListView(children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Club Name",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Title'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Department and Domain",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Dept'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Objectives",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Objectives'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Faculty Advisor",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Faculty'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                      child: Text(
                                        "Student Chairman",
                                        textScaleFactor: 2.0,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        doc['Pres'],
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                    Divider(
                                      indent: 16.0,
                                      height: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ]);
                            });
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CachedNetworkImage(
                                imageUrl: doc['PhotoUrl'],
                                placeholder: Icon(
                                  FontAwesomeIcons.university,
                                  size: 100.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                doc['Title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList());
                })
          ])),
    );
  }
}

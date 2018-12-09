import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'aboutPage.dart';
import 'buySellPage.dart';
import 'confessionsPage.dart';
import 'main.dart';
import 'studentClubs.dart';
import 'taxiSharing.dart';

class MainDrawer extends StatefulWidget {
  final bool loggedIn;
  final String set;

  MainDrawer({@required this.loggedIn, @required this.set});

  @override
  _MainDrawerState createState() => _MainDrawerState(loggedIn: loggedIn, set: set);
}

class _MainDrawerState extends State<MainDrawer> {
  bool _loadingProfile = false;
  bool loggedIn;
  String set;

  _MainDrawerState({@required this.loggedIn, @required this.set});

  TextEditingController _multiEditControl;
  String _driveLink = "https://drive.google.com/drive/mobile/folders/1q4w8rBy-V7RZYdbrP0mckTxa9bLNDpum";

  Future<DocumentSnapshot> _getOwner() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection("Users").document(user.uid).get();
  }

  _initSignIn() async {
    setState(() {
      _loadingProfile = true;
    });
    GoogleSignIn _googleSignIn = new GoogleSignIn.standard();
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user =
        await FirebaseAuth.instance.signInWithGoogle(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    DocumentSnapshot check = await Firestore.instance.collection("Users").document(user.uid).get();
    if (!check.exists) {
      await Firestore.instance.collection("Users").document(user.uid).setData({
        "Uid": user.uid,
        "PhotoUrl": user.photoUrl,
        "DisplayName": user.displayName,
        "Email": user.email,
        "NotificationId": set
      }).then((x) async {});
      setState(() {
        _loadingProfile = false;
      });
    }
    setState(() {
      _loadingProfile = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _multiEditControl = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (_, snapshot) {
          return Drawer(
            child: Column(
              children: <Widget>[
                snapshot.data != null
                    ? InkWell(
                        child: UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: Theme.of(context).primaryTextTheme.body1.color))),
                          accountName: FutureBuilder<DocumentSnapshot>(
                              future: _getOwner(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return _loadingProfile
                                      ? Center(child: CircularProgressIndicator())
                                      : Text(
                                          "Tap to Login",
                                        );
                                }
                                return Text(snapshot.data['DisplayName']);
                              }),
                          currentAccountPicture: FutureBuilder<FirebaseUser>(
                              future: FirebaseAuth.instance.currentUser(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return _loadingProfile
                                      ? Center(child: CircularProgressIndicator())
                                      : Icon(
                                          Icons.person,
                                        );
                                }
                                return CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data.photoUrl),
                                );
                              }),
                          accountEmail: FutureBuilder<FirebaseUser>(
                              future: FirebaseAuth.instance.currentUser(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return _loadingProfile ? Container() : Container();
                                }
                                return Text(snapshot.data.email);
                              }),
                          onDetailsPressed: () async {
                            FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                            showDialog(
                                context: context,
                                child: SimpleDialog(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Edit Profile"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return SimpleDialog(
                                                children: <Widget>[
                                                  ListTile(
                                                    title: Text("Display Name"),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return SimpleDialog(
                                                              children: <Widget>[
                                                                ListTile(
                                                                  title: Text("Set new name:"),
                                                                ),
                                                                ListTile(
                                                                  title: TextField(
                                                                    controller: _multiEditControl,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    Expanded(
                                                                      child: Container(),
                                                                    ),
                                                                    FlatButton(
                                                                        onPressed: () async {
                                                                          await Firestore.instance
                                                                              .collection("Users")
                                                                              .document(owner.uid)
                                                                              .updateData({
                                                                            "DisplayName": _multiEditControl.text
                                                                          });
                                                                          Navigator.pop(context);
                                                                          setState(() {});
                                                                        },
                                                                        child: Text("Submit")),
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                          });
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                    ListTile(
                                      title: Text("Logout"),
                                      onTap: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.pop(context);
                                        loggedIn = false;
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ));
                          },
                        ),
                      )
                    : InkWell(
                        child: Column(
                          children: <Widget>[
                            FutureBuilder<DocumentSnapshot>(
                                future: _getOwner(),
                                builder: (_, snapshot) {
                                  if (!snapshot.hasData) {
                                    return UserAccountsDrawerHeader(
                                      accountName: Text("Tap to Login"),
                                      accountEmail: Text("With Google"),
                                      otherAccountsPictures: <Widget>[
                                        Icon(
                                          Icons.person,
                                        )
                                      ],
                                      onDetailsPressed: () {
                                        _initSignIn();
                                      },
                                    );
                                  }
                                  return ListTile(
                                    title: Text(snapshot.data['DisplayName']),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(snapshot.data['PhotoUrl']),
                                    ),
                                    trailing: new PopupMenuButton(onSelected: (str) {
                                      switch (str) {
                                        case "edit":
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return SimpleDialog(
                                                  children: <Widget>[
                                                    ListTile(
                                                      title: Text("Display Name"),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return SimpleDialog(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    title: Text("Set new name:"),
                                                                  ),
                                                                  ListTile(
                                                                    title: TextField(
                                                                      controller: _multiEditControl,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                        child: Container(),
                                                                      ),
                                                                      FlatButton(
                                                                          onPressed: () async {
                                                                            await Firestore.instance
                                                                                .collection("Users")
                                                                                .document(snapshot.data['Uid'])
                                                                                .updateData({
                                                                              "DisplayName": _multiEditControl.text
                                                                            });
                                                                            Navigator.pop(context);
                                                                            setState(() {});
                                                                          },
                                                                          child: Text("Submit")),
                                                                    ],
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                          break;
                                        case "logout":
                                          FirebaseAuth.instance.signOut();
                                          Navigator.pop(context);
                                          loggedIn = false;
                                          setState(() {});
                                      }
                                    }, itemBuilder: (_) {
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem(value: "edit", child: Text("Edit Profile")),
                                        const PopupMenuItem(value: "logout", child: Text("Logout"))
                                      ];
                                    }),
                                  );
                                }),
                          ],
                        ),
                      ),
                Expanded(
                  child: ListView(children: [
                    ListTile(
                      leading: Icon(Icons.event),
                      title: Text("Academic Calendar"),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return AcadCal();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.book),
                      title: Text("Notes"),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection("Notes").snapshots(),
                        builder: (_, snapshot) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              snapshot.hasData
                                  ? DropdownButton<String>(
                                      hint: Text("Select"),
                                      value: _driveLink,
                                      items: snapshot.data.documents.map((doc) {
                                        return DropdownMenuItem<String>(
                                            value: doc['Link'],
                                            child: Container(
                                              width: 100.0,
                                              child: Text(doc['Title']),
                                            ));
                                      }).toList(),
                                      onChanged: (str) {
                                        _driveLink = str;
                                        setState(() {});
                                      })
                                  : Container(),
                              IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    launch(_driveLink);
                                  })
                            ],
                          );
                        }),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.graduationCap),
                      title: Text("Student Clubs"),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                          return StudentClubs();
                        }));
                      },
                    ),
                    ListTile(
                        title: Text("Shelf"),
                        subtitle: Text("In beta"),
                        leading: Icon(FontAwesomeIcons.shoppingBag),
                        onTap: () async {
                          FirebaseUser user = await FirebaseAuth.instance.currentUser();
                          if (user == null) {
                            Navigator.pop(context);
                            await showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text("You must login to post an advert"),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: Text("Okay"))
                                    ],
                                  );
                                });
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                            return BuySellPage();
                          }));
                        }),
                    // Confession page tile.
                    ListTile(
                      leading: Icon(FontAwesomeIcons.userSecret),
                      title: Text("Confessions"),
                      onTap: () async {
                        FirebaseUser user = await FirebaseAuth.instance.currentUser();
                        if (user == null) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text("You must login to use this feature"),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Okay"))
                                  ],
                                );
                              });
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                            return ConfessionsPage();
                          }));
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.umbrellaBeach),
                      title: Text("Places to visit"),
                      onTap: () {
                        launch("https://themitpost.com/manipal-traveller/");
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.taxi),
                      title: Text("Taxi Sharing"),
                      onTap: () async {
                        FirebaseUser user = await FirebaseAuth.instance.currentUser();
                        if (user == null) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text("You must login to use this feature"),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Okay"))
                                  ],
                                );
                              });
                        } else {
                          DocumentSnapshot owner =
                              await Firestore.instance.collection("Users").document(user.uid).get();
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return TaxiSharingPage(
                              owner: owner,
                            );
                          }));
                        }
                      },
                    ),
                    // Share tile.
                    ListTile(
                      leading: Icon(
                        FontAwesomeIcons.share,
                      ),
                      title: Text(
                        "Share this app!",
                        style: TextStyle(),
                      ),
                      onTap: () {
                        Share.share(
                            "We created an app to unify the culture of Manipal!\nIt's called Nexus, and it's on the playstore now, "
                            "check it out!\nhttps://play.google.com/store/apps/details?id=com.thewhirringmechanic.chillbruh");
                      },
                    ),
                    // About page tile.
                    ListTile(
                      leading: Icon(
                        FontAwesomeIcons.smile,
                      ),
                      title: Text(
                        "About us",
                        style: TextStyle(),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return AboutPage();
                        }));
                      },
                    ),
                    // Dark theme tile.
                    SwitchListTile(
                        title: Text("Dark Theme"),
                        secondary: Icon(FontAwesomeIcons.ghost),
                        value: Theme.of(context).brightness == Brightness.dark ? true : false,
                        onChanged: (isDark) {
                          DynamicTheme.of(context).setBrightness(isDark ? Brightness.dark : Brightness.light);
                          setState(() {});
                        }),
                    ListTile(
                      isThreeLine: true,
                      leading: Icon(
                        FontAwesomeIcons.bug,
                      ),
                      title: Text(
                        "Bugs and Feedback",
                        style: TextStyle(),
                      ),
                      subtitle: Text(
                        "Will work only if logged in\n(Or suggest new features! ;D)",
                        style: TextStyle(),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return SimpleDialog(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Center(
                                        child: Text(
                                      "Your say matters a lot to us!",
                                      textScaleFactor: 1.3,
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                    child: TextField(controller: _multiEditControl, maxLines: null, autofocus: true),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: FlatButton(
                                        onPressed: () async {
                                          FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                                          await Firestore.instance.collection("Feedback").add({
                                            "Owner": owner.uid,
                                            "OwnerName": owner.displayName,
                                            "Problem": _multiEditControl.text
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text("Submit")),
                                  )
                                ],
                              );
                            });
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.info,
                      ),
                      title: Text(
                        "Terms of Service",
                        style: TextStyle(),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                child: Container(
                                  height: 400.0,
                                  child: ListView(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Text(
                                              "Terms of Service",
                                              textScaleFactor: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 300.0,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).primaryTextTheme.body1.color)),
                                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: ListView(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                "By accessing and using this service, you accept and agree to be bound"
                                                    " by the terms and provision of this agreement."
                                                    " In addition, when using these particular services, you shall be "
                                                    "subject to any posted guidelines or rules applicable to such "
                                                    "services. Any participation in this service will constitute "
                                                    "acceptance of this agreement. If you do not agree to abide by "
                                                    "the above, please do not use this service.",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                  "This mobile application and its components are offered for informational purposes only; this mobile application "
                                                  "shall not be responsible or liable for the accuracy, usefulness or availability of any information transmitted or made available via the mobile application, and shall not be responsible or liable for any error or omissions in that information."),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                  "This mobile application advertises and uses paid promotion of events for monetary gain. We take good measures to "
                                                  "ensure accuracy of information displayed on the application. We take our reputation and credibility in this regard very seriously and endorse products we truly believe in. Given this, we act only as advertisers and assume no responsibility for the event or product or whatsoever thereof we advertise."),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                  "We may terminate your access to the application, without cause or notice, which may result in the forfeiture and "
                                                  "destruction of all information associated with your account. All provisions of this Agreement that, by their nature, should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity, and limitations of liability."),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                  "The company reserves the right to change these conditions from time to time as it sees fit and your continued use "
                                                  "of the application will signify your acceptance of any adjustment to these terms. If there are any changes to our privacy policy, we will announce that these changes have been made on the homepage in the application. If there are any changes in how we use our application customers' Personally Identifiable Information, notification by email or postal mail will be made to those affected by the change. Any changes to our privacy policy will be posted on our application 30 days prior to these changes taking place. You are therefore advised to re-read this statement on a regular basis."),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ]),
                ),
              ],
            ),
          );
        });
  }
}

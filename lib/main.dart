import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chill_bruh/ConfessionsPage.dart';
import 'package:chill_bruh/StudentClubs.dart';
import 'package:chill_bruh/aboutPage.dart';
import 'package:chill_bruh/chatPage.dart';
import 'package:chill_bruh/contactsTab.dart';
import 'package:chill_bruh/taxiSharing.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal/onesignal.dart';
import 'package:share/share.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = new FirebaseAnalytics();
    return new MaterialApp(
      title: 'Nexus',
      theme: new ThemeData(
        primaryColor: Colors.white,
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.indigo),
          body1: TextStyle(color: Colors.green), //(0xFF, 0x89, 0x00, 0x0E)
        ),
        accentColor: Colors.red,
      ),
      home: new MyHomePage(),
      navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController _topTabController;
  TextEditingController _multiEditControl;

  String _driveLink =
      "https://drive.google.com/drive/mobile/folders/1q4w8rBy-V7RZYdbrP0mckTxa9bLNDpum";
  bool _loadingProfile = false;
  String _debugLabelString;
  String set;
  bool loggedIn = false;
  bool isAdmin = false;
  DocumentSnapshot nextNewsFrom;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _topTabController = new TabController(length: 3, vsync: this);
    _multiEditControl = new TextEditingController(text: "");

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: (str) {});
  }

  bool _firstLoad = true;

  Future<FirebaseUser> _get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_firstLoad) {
      FirebaseUser owner = await FirebaseAuth.instance.currentUser();
      owner == null ? loggedIn = false : loggedIn = true;
      OneSignal.shared.setNotificationReceivedHandler((notification) {
        this.setState(() {
          _debugLabelString =
          "Received notification: \n${notification.jsonRepresentation()
              .replaceAll("\\n", "\n")}";
        });
      });
      OneSignal.shared.setNotificationOpenedHandler(
              (OSNotificationOpenedResult result) async {
            DocumentSnapshot ownerDoc = await Firestore.instance
                .collection("Users")
                .document(
                result.notification.payload.additionalData['chatWith'])
                .get();
            print(ownerDoc.data);
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ChatPage(
                chatWith: ownerDoc,
              );
            }));
            this.setState(() {
              _debugLabelString =
              "Opened notification: \n${result.notification.jsonRepresentation()
                  .replaceAll("\\n", "\n")}";
            });
          });
      await OneSignal.shared.init("e1dcbe9d-7329-41e3-9ff3-2c53720d9671",
          iOSSettings: {
            OSiOSSettings.autoPrompt: false,
            OSiOSSettings.inAppLaunchUrl: true
          });
      OneSignal.shared
          .setInFocusDisplayType(OSNotificationDisplayType.notification);
      String str;
      set = await OneSignal.shared.getPermissionSubscriptionState().then((sub) {
        str = sub.subscriptionStatus.userId;
        return sub.subscriptionStatus.userId;
        /*sub
        .subscriptionStatus
        .userId*/
      });
      if (owner != null)
        Firestore.instance
            .collection("Users")
            .document(owner.uid)
            .updateData({"NotificationId": str});
      print("Registered for notifs");
      _firstLoad = false;
      setState(() {});
    }
    return await FirebaseAuth.instance.currentUser();
  }

  Future<DocumentSnapshot> _getOwner() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    if (owner != null) {
      return await Firestore.instance
          .collection("Users")
          .document(owner.uid)
          .get();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: _get(),
        builder: (_, snapshot) {
          return Scaffold(
              key: key,
              floatingActionButton: AddStuffFAB(),
              drawer: MainDrawer(
                loggedIn: loggedIn,
                set: set,
              ),
              body: NestedScrollView(
                  headerSliverBuilder: (_, x) {
                    return [
                      SliverAppBar(
                        title: Text("Nexus"),
                        centerTitle: true,
                        bottom: TabBar(controller: _topTabController, tabs: [
                          Tab(
                            text: "News",
                          ),
                          Tab(
                            text: "Events",
                          ),
                          Tab(
                            text: "Contacts",
                          )
                        ]),
                        automaticallyImplyLeading: true,
                        forceElevated: true,
                        floating: true,
                        actions: <Widget>[
                          FoodIcon(),
                        ],
                      ),
                    ];
                  },
                  body: TabBarView(controller: _topTabController, children: [
                    NewsView(),
                    EventsTab(),
                    ContactsTab(),
                  ])));
        });
  }
}

class AcadCal extends StatefulWidget {
  @override
  _AcadCalState createState() => _AcadCalState();
}

class _AcadCalState extends State<AcadCal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*floatingActionButton: ,*/
      appBar: AppBar(
        title: Text("Academic Calender"),
      ),
      backgroundColor: Colors.black,
      body: ZoomableImage(
        AssetImage("images/AcadCal.jpg"),
        placeholder: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class AddNewsPage extends StatefulWidget {
  @override
  _AddNewsPageState createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  var formKey = new GlobalKey<FormState>();
  String title;
  String content;
  File image;
  bool loadedImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add news"),
      ),
      body: ListView(children: <Widget>[
        Form(
          autovalidate: true,
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                child: Text(
                  "Title",
                  textScaleFactor: 1.7,
                ),
              ),
              Divider(
                indent: 16.0,
                color: Theme
                    .of(context)
                    .primaryTextTheme
                    .body1
                    .color,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextFormField(validator: (str) {
                  title = str;
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                child: Text(
                  "Content",
                  textScaleFactor: 1.7,
                ),
              ),
              Divider(
                indent: 16.0,
                color: Theme
                    .of(context)
                    .primaryTextTheme
                    .body1
                    .color,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextFormField(validator: (str) {
                  content = str;
                }),
              ),
              Container(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: FlatButton.icon(
                    onPressed: () async {
                      var _image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      image = _image;
                      loadedImage = true;
                      setState(() {});
                    },
                    icon: Icon(Icons.add_a_photo),
                    label: Text("Add Photo")),
              ),
              loadedImage ? Image.file(image) : Container(),
              Divider(
                indent: 16.0,
                color: Theme
                    .of(context)
                    .primaryTextTheme
                    .body1
                    .color,
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () async {
            String rand = "${new Random().nextInt(10000)}";
            var photo = FirebaseStorage.instance
                .ref()
                .child("News/")
                .child(rand + ".png")
                .putFile(image);
            photo.onComplete.then((doc) async {
              await Firestore.instance.collection("News").add({
                "Timestamp": DateTime.now(),
                "PhotoUrl": doc.ref.getDownloadURL().toString(),
                "Title": title,
                "Content": content
              });
            });
          }),
    );
  }
}

class ExpandedNewsPage extends StatefulWidget {
  final DocumentSnapshot news;

  ExpandedNewsPage({this.news});

  @override
  _ExpandedNewsPageState createState() => _ExpandedNewsPageState(news: news);
}

class _ExpandedNewsPageState extends State<ExpandedNewsPage>
    with TickerProviderStateMixin {
  DocumentSnapshot news;

  _ExpandedNewsPageState({this.news});

  TextEditingController _editControl = new TextEditingController();
  DocumentSnapshot ownerDoc;
  TabController controller;

  Future<DocumentSnapshot> defaultFuture() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    ownerDoc =
    await Firestore.instance.collection("Users").document(owner.uid).get();
    return ownerDoc;
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news['Title']),
        bottom: TabBar(
          tabs: [
            Tab(
              text: "News",
            ),
            Tab(
              text: "Discussions",
            )
          ],
          controller: controller,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(news['Title'] +
                    "\nThis news was brought to you by Manipal Blog via the"
                        " Nexus Manipal app! https://play.google.com/store/apps/details?id=com"
                        ".thewhirringmechanic"
                        ".chillbruh");
              })
        ],
      ),
      body: TabBarView(controller: controller, children: [
        ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                news['PhotoUrl'] != null
                    ? Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text(news['Title']),
                                ),
                                body: ZoomableImage(
                                    CachedNetworkImageProvider(
                                        news['PhotoUrl'])),
                              );
                            }));
                      },
                      child: CachedNetworkImage(
                        imageUrl: news['PhotoUrl'],
                        fit: BoxFit.fitWidth,
                      )),
                )
                    : Container(),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Text(
                    news['Title'],
                    textScaleFactor: 1.3,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        news['Timestamp'] is String
                            ? news['Timestamp']
                            : DateFormat.MMMMEEEEd().format(news['Timestamp']),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(news['Content']),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("News")
                      .document(news.documentID)
                      .collection("Comments")
                      .orderBy("Timestamp", descending: true)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
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
            Divider(color: Theme
                .of(context)
                .primaryTextTheme
                .body1
                .color),
            FutureBuilder<DocumentSnapshot>(
                future: defaultFuture(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData)
                    return ListTile(
                      title: Text("Please login to comment."),
                    );
                  return ListTile(
                      title: TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                            icon: CircleAvatar(
                              backgroundImage:
                              NetworkImage(ownerDoc['PhotoUrl']),
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        controller: _editControl,
                        focusNode: FocusNode(),
                        onSubmitted: (str) async {
                          _editControl.clear();
                          FirebaseUser owner =
                          await FirebaseAuth.instance.currentUser();
                          await Firestore.instance
                              .collection("News")
                              .document(news.documentID)
                              .collection("Comments")
                              .add({
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
                            FirebaseUser owner =
                            await FirebaseAuth.instance.currentUser();
                            await Firestore.instance
                                .collection("News")
                                .document(news.documentID)
                                .collection("Comments")
                                .add({
                              "Content": str,
                              "OwnerName": owner.displayName,
                              "OwnerUid": owner.uid,
                              "OwnerPhotoUrl": owner.photoUrl,
                              "Timestamp": DateTime.now()
                            });
                          }));
                }),
          ],
        ),
      ]),
    );
  }
}

class AddStuffFAB extends StatefulWidget {
  @override
  _AddStuffFABState createState() => _AddStuffFABState();
}

class _AddStuffFABState extends State<AddStuffFAB> {
  TextEditingController control;
  File image;
  bool loadedImage = false;

  Future<DocumentSnapshot> _getOwner() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot temporary =
    await Firestore.instance.collection("Users").document(user.uid).get();
    return temporary;
  }

  @override
  void initState() {
    super.initState();
    control = TextEditingController(text: "titleVenueOfferWhatsapplink");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: _getOwner(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();
          if (!snapshot.data.exists) return Container();
          if (snapshot.data['isAdmin'] != null && snapshot.data['isAdmin']) {
            return FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                      context: context,
                      child: SimpleDialog(
                        children: <Widget>[
                          TextField(
                            controller: control,
                            onSubmitted: (str) async {
                              DateTime dateTime = await showDatePicker(
                                context: context,
                                initialDate: DateTime(DateTime
                                    .now()
                                    .year,
                                    DateTime
                                        .now()
                                        .month, DateTime
                                        .now()
                                        .day),
                                firstDate: DateTime(DateTime
                                    .now()
                                    .year,
                                    DateTime
                                        .now()
                                        .month, DateTime
                                        .now()
                                        .day),
                                lastDate:
                                DateTime.now().add(Duration(days: 500)),
                              );
                              TimeOfDay time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              DateTime toInput = DateTime(
                                  dateTime.year,
                                  dateTime.month,
                                  dateTime.day,
                                  time.hour,
                                  time.minute);
                              var titleVenueOfferWhatsapplink = str.split("+");
                              String rand = "${new Random().nextInt(10000)}";
                              var photo = FirebaseStorage.instance
                                  .ref()
                                  .child("News/")
                                  .child(rand + ".png")
                                  .putFile(image);
                              photo.onComplete.then((doc) async {
                                await Firestore.instance
                                    .collection("Events")
                                    .document(titleVenueOfferWhatsapplink[0])
                                    .setData({
                                  "Venue": titleVenueOfferWhatsapplink[1],
                                  "Time": toInput,
                                  "Timestamp": DateTime.now(),
                                  "Title": titleVenueOfferWhatsapplink[0],
                                  "Offer": titleVenueOfferWhatsapplink[2],
                                  "WhatsappLink":
                                  titleVenueOfferWhatsapplink[3],
                                  "PhotoUrl":
                                  doc.ref.getDownloadURL().toString()
                                });
                              });
                            },
                          ),
                          FlatButton.icon(
                              onPressed: () async {
                                var _image = await ImagePicker.pickImage(
                                    source: ImageSource.gallery);
                                image = _image;
                                loadedImage = true;
                                setState(() {});
                              },
                              icon: Icon(Icons.add_a_photo),
                              label: loadedImage
                                  ? Text("Selected Photo")
                                  : Text("Add Photo")),
                        ],
                      ));
                });
          } else
            return Container();
        });
  }
}

class MainDrawer extends StatefulWidget {
  bool loggedIn;
  String set;

  MainDrawer({@required loggedIn, @required set});

  @override
  _MainDrawerState createState() =>
      _MainDrawerState(loggedIn: loggedIn, set: set);
}

class _MainDrawerState extends State<MainDrawer> {
  bool _loadingProfile = false;
  bool loggedIn;
  String set;

  _MainDrawerState({@required loggedIn, @required set});

  TextEditingController _multiEditControl;
  String _driveLink =
      "https://drive.google.com/drive/mobile/folders/1q4w8rBy-V7RZYdbrP0mckTxa9bLNDpum";

  Future<DocumentSnapshot> _getOwner() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance
        .collection("Users")
        .document(user.uid)
        .get();
  }

  _initSignIn() async {
    setState(() {
      _loadingProfile = true;
    });
    GoogleSignIn _googleSignIn = new GoogleSignIn.standard();
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    DocumentSnapshot check =
    await Firestore.instance.collection("Users").document(user.uid).get();
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
                        border: Border(
                            bottom: BorderSide(
                                color: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .body1
                                    .color))),
                    accountName: FutureBuilder<DocumentSnapshot>(
                        future: _getOwner(),
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) {
                            return _loadingProfile
                                ? Center(
                                child: CircularProgressIndicator())
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
                                ? Center(
                                child: CircularProgressIndicator())
                                : Icon(
                              Icons.person,
                              color: Colors.white,
                            );
                          }
                          return CircleAvatar(
                            backgroundImage:
                            NetworkImage(snapshot.data.photoUrl),
                          );
                        }),
                    accountEmail: FutureBuilder<FirebaseUser>(
                        future: FirebaseAuth.instance.currentUser(),
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) {
                            return _loadingProfile
                                ? Container()
                                : Container();
                          }
                          return Text(snapshot.data.email);
                        }),
                    onDetailsPressed: () async {
                      FirebaseUser owner =
                      await FirebaseAuth.instance.currentUser();
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
                                                        children: <
                                                            Widget>[
                                                          ListTile(
                                                            title: Text(
                                                                "Set new name:"),
                                                          ),
                                                          ListTile(
                                                            title:
                                                            TextField(
                                                              controller:
                                                              _multiEditControl,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: <
                                                                Widget>[
                                                              Expanded(
                                                                child:
                                                                Container(),
                                                              ),
                                                              FlatButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await Firestore
                                                                        .instance
                                                                        .collection(
                                                                        "Users")
                                                                        .document(
                                                                        owner
                                                                            .uid)
                                                                        .updateData(
                                                                        {
                                                                          "DisplayName":
                                                                          _multiEditControl
                                                                              .text
                                                                        });
                                                                    Navigator
                                                                        .pop(
                                                                        context);
                                                                    setState(
                                                                            () {});
                                                                  },
                                                                  child: Text(
                                                                      "Submit")),
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
                                    color: Colors.white,
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
                                backgroundImage: NetworkImage(
                                    snapshot.data['PhotoUrl']),
                              ),
                              trailing:
                              new PopupMenuButton(onSelected: (str) {
                                switch (str) {
                                  case "edit":
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return SimpleDialog(
                                            children: <Widget>[
                                              ListTile(
                                                title:
                                                Text("Display Name"),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return SimpleDialog(
                                                          children: <
                                                              Widget>[
                                                            ListTile(
                                                              title: Text(
                                                                  "Set new name:"),
                                                            ),
                                                            ListTile(
                                                              title:
                                                              TextField(
                                                                controller:
                                                                _multiEditControl,
                                                              ),
                                                            ),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  child:
                                                                  Container(),
                                                                ),
                                                                FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await Firestore
                                                                          .instance
                                                                          .collection(
                                                                          "Users")
                                                                          .document(
                                                                          snapshot
                                                                              .data['Uid'])
                                                                          .updateData(
                                                                          {
                                                                            "DisplayName": _multiEditControl
                                                                                .text
                                                                          });
                                                                      Navigator
                                                                          .pop(
                                                                          context);
                                                                      setState(() {});
                                                                    },
                                                                    child:
                                                                    Text(
                                                                        "Submit")),
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
                                  const PopupMenuItem(
                                      value: "edit",
                                      child: Text("Edit Profile")),
                                  const PopupMenuItem(
                                      value: "logout",
                                      child: Text("Logout"))
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
                    Divider(),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.book),
                      title: Text("Notes"),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream:
                        Firestore.instance.collection("Notes").snapshots(),
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
                    Divider(),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.graduationCap),
                      title: Text("Student Clubs"),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return StudentClubs();
                        }));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.userSecret),
                      title: Text("Confessions"),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return ConfessionsPage();
                        }));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.umbrellaBeach),
                      title: Text("Places to visit"),
                      onTap: () {
                        launch("https://themitpost.com/manipal-traveller/");
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.taxi),
                      title: Text("Taxi Sharing"),
                      subtitle: Text("Testing phase"),
                      onTap: () async {
                        FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();
                        if (user == null) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(
                                      "You must login to use this feature"),
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
                          DocumentSnapshot owner = await Firestore.instance
                              .collection("Users")
                              .document(user.uid)
                              .get();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                                return TaxiSharingPage(
                                  owner: owner,
                                );
                              }));
                        }
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text("More features coming soon! :)"),
                      subtitle: Text("Let this one remain a surprise ;D"),
                    ),
                    Container(
                      color: Theme
                          .of(context)
                          .primaryTextTheme
                          .title
                          .color,
                      child: ListTile(
                        leading: Icon(
                          FontAwesomeIcons.share,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Share this app!",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Share.share(
                              "We created an app to unify the culture of Manipal!\nIt's called Nexus, and it's on the playstore now, "
                                  "check it out!\nhttps://play.google.com/store/apps/details?id=com.thewhirringmechanic.chillbruh");
                        },
                      ),
                    ),
                    Container(
                      color: Theme
                          .of(context)
                          .primaryTextTheme
                          .title
                          .color,
                      child: ListTile(
                        isThreeLine: true,
                        leading: Icon(
                          FontAwesomeIcons.bug,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Bugs and Feedback",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Will work only if logged in\n(Or suggest new features! ;D)",
                          style: TextStyle(color: Colors.white),
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
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0),
                                      child: TextField(
                                          controller: _multiEditControl,
                                          maxLines: null),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: FlatButton(
                                          onPressed: () async {
                                            FirebaseUser owner =
                                            await FirebaseAuth.instance
                                                .currentUser();
                                            await Firestore.instance
                                                .collection("Feedback")
                                                .add({
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
                    ),
                    Container(
                      color: Theme
                          .of(context)
                          .primaryTextTheme
                          .title
                          .color,
                      child: ListTile(
                        leading: Icon(
                          FontAwesomeIcons.smile,
                          color: Colors.white,
                        ),
                        title: Text(
                          "About us",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                                return AboutPage();
                              }));
                        },
                      ),
                    ),
                    Container(
                      color: Theme
                          .of(context)
                          .primaryTextTheme
                          .title
                          .color,
                      child: ListTile(
                        leading: Icon(
                          Icons.info,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Terms of Service",
                          style: TextStyle(color: Colors.white),
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
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(24.0),
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
                                              border: Border.all(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryTextTheme
                                                      .body1
                                                      .color)),
                                          margin: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: ListView(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(16.0),
                                                child: Text(
                                                  "By accessing and using this service, you accept and agree to be bound by the terms and provision of this agreement."
                                                      " In addition, when using these particular services, you shall be subject to any posted guidelines or rules applicable to such services. Any participation in this service will constitute acceptance of this agreement. If you do not agree to abide by the above, please do not use this service.",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(16.0),
                                                child: Text(
                                                    "This mobile application and its components are offered for informational purposes only; this mobile application "
                                                        "shall not be responsible or liable for the accuracy, usefulness or availability of any information transmitted or made available via the mobile application, and shall not be responsible or liable for any error or omissions in that information."),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(16.0),
                                                child: Text(
                                                    "This mobile application advertises and uses paid promotion of events for monetary gain. We take good measures to "
                                                        "ensure accuracy of information displayed on the application. We take our reputation and credibility in this regard very seriously and endorse products we truly believe in. Given this, we act only as advertisers and assume no responsibility for the event or product or whatsoever thereof we advertise."),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(16.0),
                                                child: Text(
                                                    "We may terminate your access to the application, without cause or notice, which may result in the forfeiture and "
                                                        "destruction of all information associated with your account. All provisions of this Agreement that, by their nature, should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity, and limitations of liability."),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(16.0),
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
                    ),
                  ]),
                ),
              ],
            ),
          );
        });
  }
}

class NewsView extends StatefulWidget {
  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  List<Widget> ws = [];
  QuerySnapshot next;
  List<Stream<QuerySnapshot>> newsPages = [
    Firestore.instance
        .collection("News")
        .orderBy("Timestamp", descending: true)
        .limit(20)
        .snapshots()
  ];

  @override
  void initState() {
    super.initState();
    addToNewsList();
  }

  void addToNewsList() {
    Stream<QuerySnapshot> currentNews = newsPages.last;
    currentNews.listen((snapshot) async {}).onData((snapshot) {
      for (int i = 0; i < snapshot.documents.length; i++) {
        ws.add(GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ExpandedNewsPage(
                news: snapshot.documents
                    .getRange(i, i + 1)
                    .first,
              );
            }));
          },
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                snapshot.documents
                    .getRange(i, i + 1)
                    .first['PhotoUrl'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    height: MediaQuery
                        .of(context)
                        .size
                        .width / 1.5,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    fit: BoxFit.fitWidth,
                    imageUrl: snapshot.documents
                        .getRange(i, i + 1)
                        .first['PhotoUrl'],
                  ),
                )
                    : Container(),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                  child: Text(
                    snapshot.documents
                        .getRange(i, i + 1)
                        .first['Title'],
                    textScaleFactor: 1.3,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        snapshot.documents
                            .getRange(i, i + 1)
                            .first['Timestamp']
                        is String
                            ? snapshot.documents
                            .getRange(i, i + 1)
                            .first['Timestamp']
                            : DateFormat.MMMMEEEEd().format(snapshot.documents
                            .getRange(i, i + 1)
                            .first['Timestamp']),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(child: Container()),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          "Share",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      onTap: () {
                        Share.share(snapshot.documents
                            .getRange(i, i + 1)
                            .first['Title'] +
                            "\nThis news was brought to you by Manipal Blog via the"
                                " Nexus Manipal app! https://play.google.com/store/apps/details?id=com"
                                ".thewhirringmechanic"
                                ".chillbruh");
                      },
                    ),
                  ],
                ),
                Container(
                  height: 8.0,
                ),
                Container(
                  height: 2.0,
                ),
              ],
            ),
          ),
        ));
        next = snapshot;
      }
      setState(() {});
    });
    currentNews.timeout(Duration(seconds: 10));
  }

  void nextPage() async {
    if (next.documents.length % 20 != 0) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("That's all the news for now! Please check "
              "again later for more! :)")));
    }
    newsPages.add(Firestore.instance
        .collection("News")
        .orderBy("Timestamp", descending: true)
        .startAfter([next.documents.last['Timestamp']])
        .limit(20)
        .snapshots());
    addToNewsList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          child: RefreshIndicator(
            onRefresh: () async {
              await new Future.delayed(new Duration(seconds: 1));
              ws = [];
              newsPages = newsPages.getRange(0, 1).toList();
              addToNewsList();
              return null;
            },
            child: ListView(children: [
              Column(
                children: ws,
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  FlatButton(
                      onPressed: () {
                        nextPage();
                      },
                      child: Text(
                        "Load more...",
                        style: TextStyle(color: Colors.grey),
                      )),
                  Expanded(child: Container())
                ],
              )
            ]),
          ),
        )
      ],
    );
  }
}

class FoodIcon extends StatefulWidget {
  @override
  _FoodIconState createState() => _FoodIconState();
}

class _FoodIconState extends State<FoodIcon> {
  bool loading = false;
  Stream<QuerySnapshot> menus =
  Firestore.instance.collection("Menus").snapshots();
  List<Widget> menuList = [
    ListTile(
      title: Text("Menus"),
    ),
    Divider(
      color: Colors.red,
    )
  ];

  Future<void> populateMenus() async {
    loading = true;
    menus.listen((qs) async {
      for (int i = 0; i < qs.documents.length; i++) {
        menuList.add(ListTile(
          title: Text(qs.documents
              .getRange(i, i + 1)
              .first['Title']),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(qs.documents
                      .getRange(i, i + 1)
                      .first['Title']),
                ),
                body: ZoomableImage(
                  CachedNetworkImageProvider(
                      qs.documents
                          .getRange(i, i + 1)
                          .first['PhotoUrl']),
                  placeholder: Container(
                    child: Center(child: CircularProgressIndicator()),
                    color: Colors.black,
                  ),
                ),
              );
            }));
          },
        ));
      }
    });
    menus.timeout(Duration(milliseconds: 500));
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool firstTimeMenu = sf.get("firstTimeMenu");
    if (firstTimeMenu == null) {
      await Future.delayed(Duration(milliseconds: 1000));
      sf.setBool("firstTimeMenu", false);
    } else
      await Future.delayed(Duration(milliseconds: 100));
    setState(() {});
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.fastfood),
      onPressed: () async {
        showDialog(
          context: context,
          builder: (_) {
            return SimpleDialog(children: [
              ListTile(
                title: Text("Menus"),
              ),
              Divider(
                color: Colors.red,
              ),
              Container(
                  height: 100.0,
                  width: 100.0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
            ]);
          },
        );
        await populateMenus();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (_) {
              return SimpleDialog(
                children: menuList,
              );
            });
      },
    );
  }
}

class EventsTab extends StatefulWidget {
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  String title = "-";
  String venue = "-";
  String time = "-";
  DateTime timeDateTime;
  String Whatsapp = "-";
  String offer = "-";

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            Divider(
              color: Theme
                  .of(context)
                  .primaryTextTheme
                  .body1
                  .color,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("Events")
                  .orderBy("Time")
                  .where("Time", isGreaterThan: DateTime.now())
                  .snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: Center(child: CircularProgressIndicator()),
                    height: 250.0,
                  );
                }
                if (snapshot.data.documents.isEmpty) {
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 200.0,
                        child: Icon(FontAwesomeIcons.frown,
                            size: 50.0, color: Colors.grey),
                      ),
                      Text(
                        "No events up currently, please check again later",
                        style: TextStyle(color: Colors.grey),
                        textScaleFactor: 0.95,
                      )
                    ],
                  );
                }
                QuerySnapshot events = snapshot.data;
                snapshot.data.documents.map((event) {
                  if (event['isSponsored'] != null) {
                    events.documents.remove(event);
                    events.documents.insert(0, event);
                  }
                }).toList();

                return Container(
                  padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                  height: 250.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: events.documents.map((doc) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            title = doc['Title'];
                            time = DateFormat.yMMMEd().format(doc['Time']) +
                                ", at " +
                                DateFormat.jm().format(doc['Time']);
                            timeDateTime = doc['Time'];
                            venue = doc['Venue'];
                            offer = doc['Offer'];
                            Whatsapp = doc['WhatsappLink'];
                          });
/*                          showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return ListView(children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                        child: Text(
                                          "Event",
                                          textScaleFactor: 1.7,
                                        ),
                                      ),
                                      Divider(
                                        indent: 16.0,
                                        color: Theme.of(context).primaryTextTheme.body1.color,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          doc['Title'],
                                          textScaleFactor: 1.5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                        child: Text(
                                          "Time",
                                          textScaleFactor: 1.7,
                                        ),
                                      ),
                                      Divider(
                                        indent: 16.0,
                                        color: Theme.of(context).primaryTextTheme.body1.color,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          DateFormat.yMMMEd().format(doc['Time']) + ", at " + DateFormat.Hm().format(doc['Time']),
                                          textScaleFactor: 1.5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                        child: Text(
                                          "Venue",
                                          textScaleFactor: 1.7,
                                        ),
                                      ),
                                      Divider(
                                        indent: 16.0,
                                        color: Theme.of(context).primaryTextTheme.body1.color,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          doc['Venue'],
                                          textScaleFactor: 1.5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                                        child: Text(
                                          "Offer",
                                          textScaleFactor: 1.7,
                                        ),
                                      ),
                                      Divider(
                                        indent: 16.0,
                                        color: Theme.of(context).primaryTextTheme.body1.color,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          doc['Offer'],
                                          textScaleFactor: 1.5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(child: Container()),
                                            IconButton(
                                              icon: Icon(FontAwesomeIcons.whatsapp),
                                              iconSize: 48.0,
                                              onPressed: () {
                                                launch(doc['WhatsappLink']);
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ]);
                              });*/
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 8.0, left: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: CachedNetworkImage(
                                    fit: BoxFit.fitHeight,
                                    placeholder: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(50.0),
                                          child: CircularProgressIndicator(),
                                        )),
                                    imageUrl: doc['PhotoUrl']),
                              ),
                            ),
                            doc['isSponsored'] != null
                                ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: Text("Sponsored"),
                              ),
                            )
                                : Container(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Divider(
                color: Theme
                    .of(context)
                    .primaryTextTheme
                    .body1
                    .color,
                height: 8.0),
          ]),
        ),
        SliverFillRemaining(
          child: ListView(children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Event Details",
                        style: TextStyle(
                            color:
                            Theme
                                .of(context)
                                .primaryTextTheme
                                .title
                                .color),
                        textScaleFactor: 1.7,
                      ),
                    ),
                    Expanded(child: Container()),
                    time == null ||
                        time == '-' ||
                        timeDateTime
                            .difference(DateTime.now())
                            .compareTo(Duration(hours: 1)) ==
                            -1
                        ? Container()
                        : IconButton(
                        icon: Icon(FontAwesomeIcons.calendarPlus),
                        onPressed: () async {
                          var androidPlatformChannelSpecifics =
                          new AndroidNotificationDetails('id', 'Nexus',
                              'Channel for showing scheduled notifs',
                              importance: Importance.Max,
                              priority: Priority.High);
                          var iOSPlatformChannelSpecifics =
                          new IOSNotificationDetails();
                          var platformChannelSpecifics =
                          new NotificationDetails(
                              androidPlatformChannelSpecifics,
                              iOSPlatformChannelSpecifics);
                          await flutterLocalNotificationsPlugin
                              .schedule(
                              0,
                              'Reminder for Event!',
                              title +
                                  " is scheduled to begin after 30 minutes at " +
                                  venue +
                                  '!',
                              timeDateTime
                                  .subtract(Duration(minutes: 30)),
                              platformChannelSpecifics,
                              payload: ' ')
                              .then((x) async {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Scheduled reminder, you will be reminded of "
                                        "this event twice, once an hour before it's scheduled to occur, once a half hour before.")));
                          });
                          await flutterLocalNotificationsPlugin.schedule(
                              1,
                              'Reminder for Event!',
                              title +
                                  " is scheduled to begin in one hour at " +
                                  venue +
                                  '!',
                              timeDateTime.subtract(Duration(hours: 1)),
                              platformChannelSpecifics,
                              payload: ' ');
                        }),
                    Whatsapp == "Please select an event" ||
                        Whatsapp == null ||
                        Whatsapp == '-'
                        ? Container()
                        : IconButton(
                      icon: Icon(FontAwesomeIcons.whatsapp,
                          color: Colors.green[700]),
                      onPressed: () {
                        launch(Whatsapp);
                      },
                    ),
                  ],
                ),
                Divider(
                  indent: 16.0,
                  color: Theme
                      .of(context)
                      .primaryTextTheme
                      .body1
                      .color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    title,
                    textScaleFactor: 1.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                  child: Text(
                    "Time",
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryTextTheme
                            .title
                            .color),
                    textScaleFactor: 1.5,
                  ),
                ),
                Divider(
                  indent: 16.0,
                  color: Theme
                      .of(context)
                      .primaryTextTheme
                      .body1
                      .color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    time,
                    textScaleFactor: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                  child: Text(
                    "Venue",
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryTextTheme
                            .title
                            .color),
                    textScaleFactor: 1.5,
                  ),
                ),
                Divider(
                  indent: 16.0,
                  color: Theme
                      .of(context)
                      .primaryTextTheme
                      .body1
                      .color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    venue,
                    textScaleFactor: 1.2,
                  ),
                ),
                offer == "Please select an event" ||
                    offer == null ||
                    offer == '-'
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                  child: Text(
                    "Offer",
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryTextTheme
                            .title
                            .color),
                    textScaleFactor: 1.7,
                  ),
                ),
                offer == "Please select an event" ||
                    offer == null ||
                    offer == '-'
                    ? Container()
                    : Divider(
                  indent: 16.0,
                  color: Theme
                      .of(context)
                      .primaryTextTheme
                      .body1
                      .color,
                ),
                offer == "Please select an event" ||
                    offer == null ||
                    offer == '-'
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    offer,
                    textScaleFactor: 1.2,
                  ),
                ),
              ],
            ),
          ]),
        )
      ],
    );
  }
}

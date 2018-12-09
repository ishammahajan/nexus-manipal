import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chill_bruh/helperFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onesignal/onesignal.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomable_image/zoomable_image.dart';

import 'chatPage.dart';
import 'contactsTab.dart';
import 'mainDrawer.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = new FirebaseAnalytics();
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (bright) {
        return bright == Brightness.light
            ? new ThemeData(
                primaryColor: Colors.white,
                primaryTextTheme: TextTheme(
                  title: TextStyle(color: Colors.indigo),
                  body1: TextStyle(color: Colors.green), //(0xFF, 0x89, 0x00, 0x0E)
                  display1: TextStyle(color: Colors.white),
                ),
                accentColor: Colors.red,
              )
            : new ThemeData(
                primaryColor: Colors.grey[900],
                primaryTextTheme: TextTheme(
                  title: TextStyle(color: Colors.teal),
                  body1: TextStyle(color: Colors.green), //(0xFF, 0x89, 0x00, 0x0E)
                  display1: TextStyle(color: Colors.white),
                ),
                accentColor: Colors.red,
                brightness: Brightness.dark);
      },
      themedWidgetBuilder: (_, theme) {
        return new MaterialApp(
          title: 'Nexus',
          theme: theme,
          home: new MyHomePage(),
          navigatorObservers: [
            new FirebaseAnalyticsObserver(analytics: analytics),
          ],
        );
      },
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

  String _driveLink = "https://drive.google.com/drive/mobile/folders/1q4w8rBy-V7RZYdbrP0mckTxa9bLNDpum";
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

    var initializationSettingsAndroid = new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (str) {});
  }

  bool _firstLoad = true;

  Future<FirebaseUser> _get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_firstLoad) {
      FirebaseUser owner = await FirebaseAuth.instance.currentUser();
      owner == null ? loggedIn = false : loggedIn = true;
      OneSignal.shared.setNotificationReceivedHandler((notification) {
        this.setState(() {
          _debugLabelString = "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
        });
      });
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) async {
        DocumentSnapshot ownerDoc =
            await Firestore.instance.collection("Users").document(result.notification.payload.additionalData['chatWith']).get();
        print(ownerDoc.data);
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ChatPage(
            chatWith: ownerDoc,
          );
        }));
        this.setState(() {
          _debugLabelString = "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
        });
      });
      await OneSignal.shared
          .init("e1dcbe9d-7329-41e3-9ff3-2c53720d9671", iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.inAppLaunchUrl: true});
      OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
      String str;
      set = await OneSignal.shared.getPermissionSubscriptionState().then((sub) {
        str = sub.subscriptionStatus.userId;
        return sub.subscriptionStatus.userId;
        /*sub
        .subscriptionStatus
        .userId*/
      });
      if (owner != null) Firestore.instance.collection("Users").document(owner.uid).updateData({"NotificationId": str});
      print("Registered for notifs");
      _firstLoad = false;
      setState(() {});
    }
    return await FirebaseAuth.instance.currentUser();
  }

  Future<DocumentSnapshot> _getOwner() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    if (owner != null) {
      return await Firestore.instance.collection("Users").document(owner.uid).get();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: _get(),
        builder: (_, snapshot) {
          return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
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
                color: Theme.of(context).primaryTextTheme.body1.color,
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
                color: Theme.of(context).primaryTextTheme.body1.color,
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
                      var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
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
                color: Theme.of(context).primaryTextTheme.body1.color,
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () async {
            String rand = "${new Random().nextInt(10000)}";
            var photo = FirebaseStorage.instance.ref().child("News/").child(rand + ".png").putFile(image);
            photo.onComplete.then((doc) async {
              await Firestore.instance
                  .collection("News")
                  .add({"Timestamp": DateTime.now(), "PhotoUrl": doc.ref.getDownloadURL().toString(), "Title": title, "Content": content});
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

class _ExpandedNewsPageState extends State<ExpandedNewsPage> with TickerProviderStateMixin {
  DocumentSnapshot news;

  _ExpandedNewsPageState({this.news});

  TextEditingController _editControl = new TextEditingController();
  DocumentSnapshot ownerDoc;
  TabController controller;

  Future<DocumentSnapshot> defaultFuture() async {
    FirebaseUser owner = await FirebaseAuth.instance.currentUser();
    ownerDoc = await Firestore.instance.collection("Users").document(owner.uid).get();
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
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: Text(news['Title']),
                                  ),
                                  body: ZoomableImage(CachedNetworkImageProvider(news['PhotoUrl'])),
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
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
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
                        news['Timestamp'] is String ? news['Timestamp'] : DateFormat.MMMMEEEEd().format(news['Timestamp']),
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
                              backgroundImage: NetworkImage(ownerDoc['PhotoUrl']),
                            ),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
                        controller: _editControl,
                        focusNode: FocusNode(),
                        onSubmitted: (str) async {
                          _editControl.clear();
                          FirebaseUser owner = await FirebaseAuth.instance.currentUser();
                          await Firestore.instance.collection("News").document(news.documentID).collection("Comments").add({
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
                            await Firestore.instance.collection("News").document(news.documentID).collection("Comments").add({
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
    DocumentSnapshot temporary = await Firestore.instance.collection("Users").document(user.uid).get();
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
                                initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                lastDate: DateTime.now().add(Duration(days: 500)),
                              );
                              TimeOfDay time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              DateTime toInput = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);
                              var titleVenueOfferWhatsapplink = str.split("+");
                              String rand = "${new Random().nextInt(10000)}";
                              var photo = FirebaseStorage.instance.ref().child("News/").child(rand + ".png").putFile(image);
                              photo.onComplete.then((doc) async {
                                await Firestore.instance.collection("Events").document(titleVenueOfferWhatsapplink[0]).setData({
                                  "Venue": titleVenueOfferWhatsapplink[1],
                                  "Time": toInput,
                                  "Timestamp": DateTime.now(),
                                  "Title": titleVenueOfferWhatsapplink[0],
                                  "Offer": titleVenueOfferWhatsapplink[2],
                                  "WhatsappLink": titleVenueOfferWhatsapplink[3],
                                  "mBeans": "-",
                                  "PhotoUrl": doc.ref.getDownloadURL().toString()
                                });
                              });
                            },
                          ),
                          FlatButton.icon(
                              onPressed: () async {
                                var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
                                image = _image;
                                loadedImage = true;
                                setState(() {});
                              },
                              icon: Icon(Icons.add_a_photo),
                              label: loadedImage ? Text("Selected Photo") : Text("Add Photo")),
                        ],
                      ));
                });
          } else
            return Container();
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
    Firestore.instance.collection("News").orderBy("Timestamp", descending: true).limit(20).snapshots()
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
                news: snapshot.documents.getRange(i, i + 1).first,
              );
            }));
          },
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                snapshot.documents.getRange(i, i + 1).first['PhotoUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 1.5,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fitWidth,
                          imageUrl: snapshot.documents.getRange(i, i + 1).first['PhotoUrl'],
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                  child: Text(
                    snapshot.documents.getRange(i, i + 1).first['Title'],
                    textScaleFactor: 1.3,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        snapshot.documents.getRange(i, i + 1).first['Timestamp'] is String
                            ? snapshot.documents.getRange(i, i + 1).first['Timestamp']
                            : DateFormat.MMMMEEEEd().format(snapshot.documents.getRange(i, i + 1).first['Timestamp']),
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
                        Share.share(snapshot.documents.getRange(i, i + 1).first['Title'] +
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
  Stream<QuerySnapshot> menus = Firestore.instance.collection("Menus").snapshots();
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
          title: Text(qs.documents.getRange(i, i + 1).first['Title']),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(qs.documents.getRange(i, i + 1).first['Title']),
                ),
                body: ZoomableImage(
                  CachedNetworkImageProvider(qs.documents.getRange(i, i + 1).first['PhotoUrl']),
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
  String mBeans = "-";
  List<dynamic> registered = [];

  SetNotification() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('id', 'Nexus', 'Channel for showing scheduled notifs',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .schedule(0, 'Reminder for Event!', title + " is scheduled to begin after 30 minutes at " + venue + '!',
            timeDateTime.subtract(Duration(minutes: 30)), platformChannelSpecifics,
            payload: ' ')
        .then((x) async {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Scheduled reminder, you will be reminded of "
              "this event twice, once an hour before it's scheduled to occur, once a half hour before.")));
    });
    await flutterLocalNotificationsPlugin.schedule(1, 'Reminder for Event!', title + " is scheduled to begin in one hour at " + venue + '!',
        timeDateTime.subtract(Duration(hours: 1)), platformChannelSpecifics,
        payload: ' ');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        // List to show all events pictures and enable clicking
        SliverList(
          delegate: SliverChildListDelegate([
            Divider(
              color: Theme.of(context).primaryTextTheme.body1.color,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("Events").orderBy("Time").where("Time", isGreaterThan: DateTime.now()).snapshots(),
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
                        child: Icon(FontAwesomeIcons.frown, size: 50.0, color: Colors.grey),
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
                            time = DateFormat.yMMMEd().format(doc['Time']) + ", at " + DateFormat.jm().format(doc['Time']);
                            timeDateTime = doc['Time'];
                            venue = doc['Venue'];
                            offer = doc['Offer'];
                            Whatsapp = doc['WhatsappLink'];
                            mBeans = doc['mBeans'];
                            registered = doc['Registered'];
                          });
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
            Divider(color: Theme.of(context).primaryTextTheme.body1.color, height: 8.0),
          ]),
        ),

        // ListView for details
        SliverFillRemaining(
          child: ListView(children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Title: "Event"
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Event",
                        style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                        textScaleFactor: 1.7,
                      ),
                    ),
                    Expanded(child: Container()),

                    // For mBeans
                    mBeans != "-"
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FlatButton(
                              onPressed: () {
                                if (timeDateTime.subtract(Duration(days: 4)).compareTo(DateTime.now()) == -1)
                                  showAlertDialog(
                                      context, DialogMode.okay, "The registrations for mBeans close 4 days prior to the event.");
                                else
                                  showAlertDialog(context, DialogMode.yesNo, "Would you like to register for the event?",
                                      subtitle: mBeans + " mBeans will be earned if you attend this event as well.", yesFunction: () async {
                                    // TODO: Confirm this transaction (beta)
                                    Firestore.instance.runTransaction((t) async {
                                      FirebaseUser user = await FirebaseAuth.instance.currentUser();
                                      if (user == null) showAlertDialog(context, DialogMode.okay, "Please login to use this feature");
                                      DocumentSnapshot currentDoc = await t.get(Firestore.instance.collection("Events").document(title));
                                      registered = currentDoc['Registered'];
                                      if (registered == null) registered = [user.uid + ": " + user.displayName];
                                      if (!registered.contains(user.uid + ": " + user.displayName))
                                        registered.add(user.uid + ": " + user.displayName);
                                      t.update(Firestore.instance.collection("Events").document(title), {"Registered": registered});
                                      print("HIHI");
                                    });
                                  });
                              },
                              child: Text(
                                mBeans + " mB",
                                style: TextStyle(color: Colors.white),
                              ),
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                              color: Colors.teal,
                            ),
                          )
                        : Container(),

                    // Function: set remainder
                    time == null || time == '-' || timeDateTime.difference(DateTime.now()).compareTo(Duration(hours: 1)) == -1
                        ? Container()
                        : IconButton(
                            icon: Icon(FontAwesomeIcons.calendarPlus),
                            onPressed: () async {
                              SetNotification();
                            }),

                    // Function: WhatsApp link
                    Whatsapp == "Please select an event" || Whatsapp == null || Whatsapp == '-'
                        ? Container()
                        : IconButton(
                            icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green[700]),
                            onPressed: () {
                              launch(Whatsapp);
                            },
                          ),
                  ],
                ),
                Divider(
                  indent: 16.0,
                  color: Theme.of(context).primaryTextTheme.body1.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    title == "-" ? "Please select an event" : title,
                    textScaleFactor: 1.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                  child: Text(
                    "Time",
                    style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                    textScaleFactor: 1.5,
                  ),
                ),
                Divider(
                  indent: 16.0,
                  color: Theme.of(context).primaryTextTheme.body1.color,
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
                    style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                    textScaleFactor: 1.5,
                  ),
                ),
                Divider(
                  indent: 16.0,
                  color: Theme.of(context).primaryTextTheme.body1.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    venue,
                    textScaleFactor: 1.2,
                  ),
                ),
                offer == "Please select an event" || offer == null || offer == '-'
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(top: 24.0, left: 16.0),
                        child: Text(
                          "Offer",
                          style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                          textScaleFactor: 1.7,
                        ),
                      ),
                offer == "Please select an event" || offer == null || offer == '-'
                    ? Container()
                    : Divider(
                        indent: 16.0,
                        color: Theme.of(context).primaryTextTheme.body1.color,
                      ),
                offer == "Please select an event" || offer == null || offer == '-'
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

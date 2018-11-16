import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BuySellPage extends StatefulWidget {
  @override
  _BuySellPageState createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("Shelf").snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return Scaffold(
              appBar: AppBar(
                title: Text("Ads"),
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          return Scaffold(
            appBar: AppBar(
              title: Text("Ads"),
              actions: <Widget>[
                snapshot.data.documents.isEmpty
                    ? Container()
                    : IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return ShowSearch(qs: snapshot.data);
                            })),
                        icon: Icon(Icons.search),
                      ),
              ],
            ),
            body: ListView(
              children: snapshot.data.documents.map((object) {
                return ad(context, object);
              }).toList(),
            ),
            floatingActionButton: FutureBuilder(
                future: FirebaseAuth.instance.currentUser(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return FloatingActionButton.extended(
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text("Note"),
                              content: Text("We only support books at the moment"),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text("Okay"))
                              ],
                            ));
                        File image;
                        while (true) {
                          image = await ImagePicker.pickImage(source: ImageSource.camera);
                          final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
                          final LabelDetector labelDetector =
                              FirebaseVision.instance.labelDetector(LabelDetectorOptions(confidenceThreshold: 0.6));
                          final List<Label> labels = await labelDetector.detectInImage(visionImage);
                          bool isLegit = true;
                          bool containsPaper = false;
                          // List of checks for checking if image is legit. If it isn't control sent back to image picker.
                          for (Label label in labels) if (label.label == "Room") isLegit = false;
                          for (Label label in labels) if (label.label == "Paper") containsPaper = true;
                          if (labels.length > 5) isLegit = false;
                          if (isLegit && containsPaper) break;
                          await showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text("Spam Detected"),
                                content: Text("Please try again"),
                                actions: <Widget>[
                                  FlatButton(onPressed: () => Navigator.pop(context, true), child: Text("Okay")),
                                ],
                              ));
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return AddAd(imageFile: image);
                        }));
                        /*Navigator.push(context, MaterialPageRoute(builder: (_) {

                }));*/
                      },
                      icon: Icon(Icons.add),
                      label: Text("Add advert"));
                }),
          );
        });
  }
}

class AddAd extends StatefulWidget {
  final File imageFile;

  AddAd({@required this.imageFile});

  @override
  _AddAdState createState() => _AddAdState(imageFile: imageFile);
}

class _AddAdState extends State<AddAd> {
  File imageFile;

  _AddAdState({this.imageFile});

  PageController controller = new PageController(initialPage: 0);
  TextEditingController titleEdit = new TextEditingController();
  TextEditingController priceEdit = new TextEditingController();
  TextEditingController phoneOrEmailEdit = new TextEditingController();

  String title;
  String price;
  String phoneNumber;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Icon(
                  FontAwesomeIcons.clipboardList,
                  size: 100.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Just a few more details",
                  textScaleFactor: 1.8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 32.0, right: 32.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: titleEdit,
                  decoration: InputDecoration(hintText: "What is the book's title?"),
                  onChanged: (str) => title = str,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 32.0, right: 32.0),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: priceEdit,
                  decoration: InputDecoration(hintText: "What price do you want to sell it for?"),
                  onChanged: (str) => price = str,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: RaisedButton(
                  onPressed: () {
                    controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
                  },
                  child: Text("Next Page"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  color: Theme.of(context).accentColor,
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 32.0, top: 32.0, bottom: 32.0),
                    child: Icon(
                      Icons.contact_phone,
                      size: 100.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 32.0, top: 32.0, bottom: 32.0),
                    child: Icon(
                      Icons.contact_mail,
                      size: 100.0,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Phone Number or Email",
                  textScaleFactor: 1.8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 32.0, right: 32.0),
                child: TextField(
                  inputFormatters: [EmailEditFormatter()],
                  textAlign: TextAlign.center,
                  controller: phoneOrEmailEdit,
                  decoration: InputDecoration(hintText: "Enter Phone or Email here..."),
                  onChanged: (str) {
                    int number = int.tryParse(str);
                    if (number == null) {
                      number = int.tryParse(str.substring(1));
                      if (number != null) {
                        phoneNumber = str;
                        email = null;
                      } else {
                        email = str;
                        phoneNumber = null;
                      }
                    } else {
                      phoneNumber = str;
                      email = null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: RaisedButton(
                  onPressed: () async {
                    String rand = "${new Random().nextInt(10000)}";
                    var puttingFile =
                        FirebaseStorage.instance.ref().child("Shelf/").child(rand + ".png").putFile(imageFile);
                    puttingFile.onComplete.then((storedRef) async {
                      String downloadUrl = await storedRef.ref.getDownloadURL();
                      phoneNumber == null
                          ? await Firestore.instance.collection("Shelf").document(title).setData({
                              "Title": title,
                              "ImageUrl": downloadUrl.toString(),
                              "Price": price,
                              "isPhone": phoneNumber == null ? false : true,
                              "Email": email
                            })
                          : await Firestore.instance.collection("Shelf").document(title).setData({
                              "Title": title,
                              "ImageUrl": downloadUrl.toString(),
                              "Price": price,
                              "isPhone": phoneNumber == null ? false : true,
                              "PhoneNumber": phoneNumber
                            });
                      Navigator.pop(context);
                    });
                  },
                  child: Text("Submit"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  color: Theme.of(context).accentColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class EmailEditFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.endsWith(". "))
      return oldValue.copyWith(
        text: oldValue.text.toLowerCase() + ".",
        selection: TextSelection.fromPosition(TextPosition(offset: oldValue.text.length + 1)),
      );
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

Widget ad(BuildContext context, DocumentSnapshot object) {
  return Card(
    child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return Scaffold(
                  appBar: AppBar(title: Text(object['Title'])),
                  body: ZoomableImage(CachedNetworkImageProvider(object['ImageUrl'])),
                );
              })),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.width / 2.5,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
              imageUrl: object['ImageUrl'],
            ),
          ),
        ),
        ListTile(
          title: Text(object['Title']),
          subtitle: Text("Rs." + object['Price']),
          trailing: IconButton(
            icon: Icon(object['isPhone'] ? Icons.phone : Icons.email),
            onPressed: () {
              object['isPhone']
                  ? launch("tel:" + object['PhoneNumber'])
                  : launch("mailto:" + object['Email'] + "?subject=Nexus Buy Request: " + object['Title']);
            },
          ),
        ),
      ],
    ),
  );
}

class ShowSearch extends StatefulWidget {
  final QuerySnapshot qs;

  ShowSearch({@required this.qs});

  @override
  _ShowSearchState createState() => _ShowSearchState(qs: qs);
}

class _ShowSearchState extends State<ShowSearch> {
  QuerySnapshot qs;
  List<DocumentSnapshot> searchHere = [];
  List<Widget> widgetList = [];

  _ShowSearchState({@required this.qs}) {
    for (int i = 0; i < qs.documents.length; i++) searchHere.add(qs.documents[i]);
  }

  TextEditingController edit = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(fontSize: 20.0),
          decoration: InputDecoration(
            hintText: "Search...",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ThemeData.dark().primaryColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ThemeData.dark().primaryColor)),
          ),
          onChanged: (str) {
            widgetList = [];
            for (int i = 0; i < searchHere.length; i++)
              if (searchHere[i]['Title'].toLowerCase().contains(str.toLowerCase()))
                widgetList.add(ad(context, searchHere[i]));
            setState(() {});
          },
        ),
      ),
      body: ListView(
        children: widgetList,
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomable_image/zoomable_image.dart';

class BuySellPage extends StatefulWidget {
  @override
  _BuySellPageState createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  Future<List<String>> getUserAd() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) return null;
    final DocumentSnapshot userDoc = await Firestore.instance.collection("Users").document(user.uid).get();
    List<String> userAds = List.from(userDoc["Ads"], growable: true);
    return userAds;
  }

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
            body: ListView.builder(
                itemCount: snapshot.data.documents.length + 2,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return FutureBuilder<List<String>>(
                        initialData: ["hi"],
                        future: getUserAd(),
                        builder: (_, snapshot) {
                          if (snapshot == null || !snapshot.hasData || snapshot.data.isEmpty) return Container();
                          return ExpansionTile(
                            title: Text("Your Advertisements"),
                            children: snapshot.data.map((s) {
                              return ListTile(
                                  title: Text(s),
                                  trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await Firestore.instance.collection("Shelf").document(s).delete();
                                        FirebaseUser user = await FirebaseAuth.instance.currentUser();
                                        List<String> updatedList = snapshot.data;
                                        updatedList.remove(s);
                                        await Firestore.instance
                                            .collection("Users")
                                            .document(user.uid)
                                            .updateData({"Ads": updatedList});
                                        setState(() {});
                                      }));
                            }).toList(),
                          );
                        });
                  }
                  if (index == 1) return Divider();
                  return ad(context, snapshot.data.documents[index - 2]);
                }),
            floatingActionButton: FutureBuilder(
                future: FirebaseAuth.instance.currentUser(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return FloatingActionButton.extended(
                      onPressed: () async {
                        if (await showDialog(
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
                            ))) {
                          await showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text("Note"),
                                content: Text("Please take a picture of the product"),
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
                                  content: Text(
                                      "Please try again. Try to take a clear picture with only the product in focus. If it still detects as spam open the book to the first title page and take that picture."),
                                  actions: <Widget>[
                                    FlatButton(onPressed: () => Navigator.pop(context, true), child: Text("Okay")),
                                  ],
                                ));
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return AddAd(imageFile: image);
                          }));
                        }
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
  FocusNode titleFocus = new FocusNode();
  FocusNode priceFocus = new FocusNode();
  FocusNode phoneOrEmailFocus = new FocusNode();

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
                child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    controller: titleEdit,
                    focusNode: titleFocus,
                    decoration: InputDecoration(hintText: "What is the book's title?"),
                    autovalidate: true,
                    validator: (str) {
                      title = str;
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 32.0, right: 32.0),
                child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    controller: priceEdit,
                    focusNode: priceFocus,
                    decoration: InputDecoration(hintText: "What price do you want to sell it for?"),
                    autovalidate: true,
                    validator: (str) {
                      if (str == "") {
                        price = null;
                        return null;
                      }
                      if (int.tryParse(str) == null || int.tryParse(str) < 7000) {
                        price = str;
                        return null;
                      } else {
                        price = null;
                        return "Please enter a reasonable number in rupees";
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: RaisedButton(
                  onPressed: () {
                    if (titleEdit.text != "") {
                      if (priceEdit.text != "") {
                        controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
                      } else {
                        //controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                        FocusScope.of(context).requestFocus(priceFocus);
                      }
                    } else {
                      //controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                      FocusScope.of(context).requestFocus(titleFocus);
                    }
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
                child: TextFormField(
                  inputFormatters: [EmailEditFormatter()],
                  textAlign: TextAlign.center,
                  controller: phoneOrEmailEdit,
                  focusNode: phoneOrEmailFocus,
                  decoration: InputDecoration(hintText: "Enter Phone or Email here..."),
                  autovalidate: true,
                  validator: (str) {
                    //phoneOrEmailEdit.text = "s";
                    if (str == "") return null;
                    int number = int.tryParse(str);
                    if (number == null) {
                      number = int.tryParse(str.substring(1));
                      if (number != null) {
                        try {
                          number = int.tryParse(str.substring(3));
                          if (str.substring(0, 3) != "+91" || number > 9999999999 || number < 1000000000) {
                            phoneNumber = null;
                            email = null;
                            return "Please provide a valid phone number";
                          } else {
                            phoneNumber = str;
                            email = null;
                          }
                        } catch (e) {}
                      } else {
                        if (str == "+") return null;
                        int atIndex = str.indexOf("@");
                        String p =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(p);
                        if (!regex.hasMatch(str)) {
                          phoneNumber = null;
                          email = null;
                          return "Please provide a valid email id";
                        } else {
                          email = str;
                          phoneNumber = null;
                        }
                      }
                    } else {
                      if (number > 9999999999 || number < 1000000000) {
                        phoneNumber = null;
                        email = null;
                        return "Please provide a valid phone number";
                      } else {
                        phoneNumber = str;
                        email = null;
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: RaisedButton(
                  onPressed: () async {
                    // Testing if everything is filled properly and then if it is process the image and advert request further
                    if (titleEdit.text != "") {
                      if (price != null) {
                        if (phoneNumber != null || email != null) {
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
                            // Adding ad to the current user's profile so that they can access it later on using your ads function in main ads page.
                            FirebaseUser user = await FirebaseAuth.instance.currentUser();
                            DocumentSnapshot userDoc =
                                await Firestore.instance.collection("Users").document(user.uid).get();
                            List<String> ads = List.from(userDoc["Ads"], growable: true);
                            if (ads == null) ads = [];
                            ads.add(title);
                            Firestore.instance.collection("Users").document(user.uid).updateData({
                              "Ads": ads,
                            });
                            Navigator.pop(context);
                          });
                        } else {
                          FocusScope.of(context).requestFocus(phoneOrEmailFocus);
                        }
                      } else {
                        controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                        FocusScope.of(context).requestFocus(priceFocus);
                      }
                    } else {
                      controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                      FocusScope.of(context).requestFocus(titleFocus);
                    }
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
          autofocus: true,
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

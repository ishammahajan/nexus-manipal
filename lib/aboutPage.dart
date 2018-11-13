import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The Team"),
      ),
      body: ListView(children: <Widget>[
        Column(
          children: <Widget>[
            Card(
              elevation: 16.0,
              margin: EdgeInsets.all(16.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        height: 70.0,
                      ),
                      Divider(
                        color: Theme.of(context).primaryTextTheme.body1.color,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundImage: AssetImage("images/AryanProfilePic.jpeg"),
                          radius: 70.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Aryan Chandwani",
                          textScaleFactor: 2.0,
                          style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
                        ),
                      ),
                      Text(
                        "Founder",
                        textScaleFactor: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(icon: Icon(FontAwesomeIcons.instagram), onPressed: () {
                            launch("http://instagram.com/cyberpaapi");
                          }),
                          IconButton(icon: Icon(FontAwesomeIcons.whatsapp), onPressed: () {
                            launch("https:wa.me/917738300438");
                          })
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Card(
              elevation: 16.0,
              margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 4.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        height: 70.0,
                      ),
                      Divider(
                        color: Theme.of(context).primaryTextTheme.body1.color,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundImage: AssetImage("images/IshamProfilePicture.jpg"),
                          radius: 70.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Isham Mahajan",
                          textScaleFactor: 2.0,
                          style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
                        ),
                      ),
                      Text(
                        "Product Manager",
                        textScaleFactor: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(icon: Icon(FontAwesomeIcons.instagram), onPressed: () {
                            launch("http://instagram.com/the_whirring_mechanic");
                          }),
                          IconButton(icon: Icon(FontAwesomeIcons.whatsapp), onPressed: () {
                            launch("https:wa.me/918618375066");
                          })
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ]),
    );
  }
}

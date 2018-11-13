import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomable_image/zoomable_image.dart';

class ContactsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [SliverList(
          delegate: SliverChildListDelegate([
        ExpansionTile(
          title: Text("Auto Service"),
          children: <Widget>[
            ListTile(
              title: Text("Dasharatha"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574202");
                  }),
            ),
            ListTile(
              title: Text("Eshwar Nagar"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574200");
                  }),
            ),
            ListTile(
              title: Text("Green Park"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202572006");
                  }),
            ),
            ListTile(
              title: Text("Mandavi"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574369");
                  }),
            ),
            ListTile(
              title: Text("Manish"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574369");
                  }),
            ),
            ListTile(
              title: Text("Night auto Santosh"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919986921287");
                  }),
            ),
            ListTile(
              title: Text("RT"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574300");
                  }),
            ),
            ListTile(
              title: Text("Syndicate Circle"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202571454");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Eateries"),
          children: <Widget>[
            ListTile(
              title: Text("Anupam"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202572635");
                  }),
            ),
            ListTile(
              title: Text("Attil"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204293399");
                  }),
            ),
            ListTile(
              title: Text("Blue Waters"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202573765");
                  }),
            ),
            ListTile(
              title: Text("Campus Grill"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919739940608");
                  }),
            ),
            ListTile(
              title: Text("Charcoal"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202570123");
                  }),
            ),
            ListTile(
              title: Text("Desi Firangi"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917829653000");
                  }),
            ),
            ListTile(
              title: Text("Dollops"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918982394234");
                  }),
            ),
            ListTile(
              title: Text("Domino's"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574352");
                  }),
            ),
            ListTile(
              title: Text("Dum Biryani Adda"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919152646557");
                  }),
            ),
            ListTile(
              title: Text("Hotel Shubham (Biryani)"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919731542673");
                  }),
            ),
            ListTile(
              title: Text("Egg Factory"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204291155");
                  }),
            ),
            ListTile(
              title: Text("Eye of the Tiger"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917899039139");
                  }),
            ),
            ListTile(
              title: Text("Guzzler's Inn"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204296016");
                  }),
            ),
            ListTile(
              title: Text("Hangout"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204296016");
                  }),
            ),
            ListTile(
              title: Text("Just Bake"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204296611");
                  }),
            ),
            ListTile(
              title: Text("KFC"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918033994444");
                  }),
            ),
            ListTile(
              title: Text("McDonalds"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917349673521");
                  }),
            ),
            ListTile(
              title: Text("Poornima Kitchen"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919741745715");
                  }),
            ),
            ListTile(
              title: Text("Sai's"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202570177");
                  }),
            ),
            ListTile(
              title: Text("Saiba"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919152540278");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918277534185");
                  }),
            ),
            ListTile(
              title: Text("Snack Shack"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202575129");
                  }),
            ),
            ListTile(
              title: Text("Sizzler Ranch"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574001");
                  }),
            ),
            ListTile(
              title: Text("Subway"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574144");
                  }),
            ),
            ListTile(
              title: Text("The J"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919967278708");
                  }),
            ),
            ListTile(
              title: Text("Zebra Spot"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919740008183");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Emergency Contacts"),
          children: <Widget>[
            ListTile(
              title: Text("Fire Helpline"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202520333");
                  }),
            ),
            ListTile(
              title: Text("KMC Ambulance"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922761");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202923153");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922404");
                  }),
            ),
            ListTile(
              title: Text("MAHE Campus Patrol"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919945670912");
                  }),
            ),
            ListTile(
              title: Text("MIT Campus Patrol"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919632101004");
                  }),
            ),
            ListTile(
              title: Text("Police Station"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+91820257038");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Grocery Stores"),
          children: <Widget>[
            ListTile(
              title: Text("Laxmi's Super Market"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919901307682");
                  }),
            ),
            ListTile(
              title: Text("Manipal Corner"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918197123460");
                  }),
            ),
            ListTile(
              title: Text("Manipal Grocer"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919964691530");
                  }),
            ),
            ListTile(
              title: Text("More Supermarket"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918652906676");
                  }),
            ),
            ListTile(
              title: Text("Queens Supermarket"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919901996124");
                  }),
            ),
            ListTile(
              title: Text("Yas Mart"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202575234");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Hotels"),
          children: <Widget>[
            ListTile(
              title: Text("Country Inn"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202701600");
                  }),
            ),
            ListTile(
              title: Text("Fortune Inn"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202571101");
                  }),
            ),
            ListTile(
              title: Text("Hotel Ashlesh"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202572824");
                  }),
            ),
            ListTile(
              title: Text("Hotel Green Park Suites"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204295701");
                  }),
            ),
            ListTile(
              title: Text("Hotel Hill View"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204292771");
                  }),
            ),
            ListTile(
              title: Text("Hotel Madhuvan Serai"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917829901250");
                  }),
            ),
            ListTile(
              title: Text("Hotel Tranquil"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202571111");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("MAHE Colleges' Depts"),
          children: <Widget>[
            ListTile(
              title: Text("Academic Section, MIT"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202925912");
                  }),
            ),
            ListTile(
              title: Text("Administrative Office, MIT"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202925521");
                  }),
            ),
            ListTile(
              title: Text("Chief Warden, MIT"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202925223");
                  }),
            ),
            ListTile(
              title: Text("Hostel Finance"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202925223");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202925227");
                  }),
            ),
            ListTile(
              title: Text("Student Finance"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922699");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922703");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922530");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Medical Services"),
          children: <Widget>[
            ListTile(
              title: Text("Blood Bank KMC"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922331");
                  }),
            ),
            ListTile(
              title: Text("Dr Suhas Bhat"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919880041652");
                  }),
            ),
            ListTile(
              title: Text("KMC Hospital Enquiry"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202571967");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202922761");
                  }),
            ),
            ListTile(
              title: Text("Sonia Clinic and Nursing Home"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202570334");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Misc Services"),
          children: <Widget>[
            ListTile(
              title: Text("ION Helpline"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919844549821");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919538947460");
                  }),
            ),
            ListTile(
              title: Text("Kamath Book Store"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918206061272");
                  }),
            ),
            ListTile(
              title: Text("Key Maker"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918884173636");
                  }),
            ),
            ListTile(
              title: Text("SBI Manipal"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202572650");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Project Work and Tech Stores"),
          children: <Widget>[
            ListTile(
              title: Text("HP service centre"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919513399161");
                  }),
            ),
            ListTile(
              title: Text("Harsha Electronics"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202521841");
                  }),
            ),
            ListTile(
              title: Text("Samsung Smart Cafe"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919844276578");
                  }),
            ),
            ListTile(
              title: Text("Tesla Electronics"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917353268261");
                  }),
            ),
            ListTile(
              title: Text("iRepair India"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918204294550");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Rent a Bike"),
          children: <Widget>[
            ListTile(
              title: Text("Bhoom Riders"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918150025955");
                  }),
            ),
            ListTile(
              title: Text("India Rides"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919686325168");
                  }),
            ),
            ListTile(
              title: Text("Royal Brothers"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+917306747474");
                  }),
            ),
            ListTile(
              title: Text("Wicked Ride"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918880299299");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Travel Agencies"),
          children: <Widget>[
            ListTile(
              title: Text("Ambika Travels"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+9194822555555");
                  }),
            ),
            ListTile(
              title: Text("Durgamba Motors"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202574477");
                  }),
            ),
            ListTile(
              title: Text("Jet International Travels"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919845187505");
                  }),
            ),
            ListTile(
              title: Text("Konkan Railways"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202531810");
                  }),
            ),
            ListTile(
              title: Text("Mangalore Railway Station"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+918202242402");
                  }),
            ),
            ListTile(
              title: Text("Sahara Tours and Travels"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919880244957");
                  }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("Snake Handlers"),
          children: <Widget>[
            ListTile(
              title: Text("Gururaj"),
              trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    launch("tel:+919845083869");
                  }),
            ),
            ListTile(
              title: Text(""),
              trailing: IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text("Clash"),
                        ),
                        body: ZoomableImage(
                          NetworkImage("https://firebasestorage.googleapis"
                              ".com/v0/b/ttcomplete-c6477.appspot"
                              ".com/o/SponseredEvents%2F1247498130"
                              ".png?alt=media&token=eab86bd2-e750-44b4-ba7a-90c14987bc11"),
                          placeholder: Container(),
                        ),
                      );
                    }));
                  }),
            ),
          ],
        )
      ])),]
    );
  }
}

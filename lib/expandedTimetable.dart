import 'package:flutter/material.dart';
import 'package:zoomable_image/zoomable_image.dart';

class ExpandedTimetable extends StatefulWidget {
  final String tt;
  ExpandedTimetable({@required this.tt});
  @override
  _ExpandedTimetableState createState() => _ExpandedTimetableState(tt: tt);
}

class _ExpandedTimetableState extends State<ExpandedTimetable> {
  String tt;
  _ExpandedTimetableState({@required this.tt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Timetable"),centerTitle: true,),
      body: ZoomableImage(AssetImage(tt),),
    );
  }
}

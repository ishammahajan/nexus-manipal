import 'package:flutter/material.dart';

enum DialogMode {
  okay,
  yesNo,
}

showAlertDialog(BuildContext context, DialogMode dm, String title, {String subtitle, Function yesFunction, Function noFunction}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: subtitle == null ? Container(height: 0.0) : Text(subtitle),
          actions: dm == DialogMode.okay
              ? [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Okay"))
                ]
              : dm == DialogMode.yesNo
                  ? [
                      FlatButton(onPressed: () {
                        if (noFunction != null) noFunction();
                        Navigator.pop(context);
                      }, child: Text("No")),
                      FlatButton(onPressed: () {
                        yesFunction();
                        Navigator.pop(context);
                      }, child: Text("Yes")),
                    ]
                  : [],
        );
      });
}

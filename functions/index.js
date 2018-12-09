const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

var db = admin.firestore();
/*
exports.sendWelcomeEmail = functions.auth.user().onCreate( (user) => {
	console.log(user.displayName + user.photoUrl + user.uid + user.emails);
  var setUser = db.collection('Users').doc(user.uid).set({
  	'DisplayName': user.displayName,
  	'PhotoUrl': user.photoUrl,
  	'Uid': user.uid,
  	'Email': user.email
  });
});
*/
exports.updateNews = functions.https.onRequest((req, res) => {
	var content = req.body.post_content;
	var imgstart = content.indexOf('http');
	var imgend = content.indexOf('"', imgstart);
	var img = content.substring(imgstart, imgend);

	content = content.replace(/<(.|\n)*?>/g, '');

	var remCaption = content.indexOf('[/caption]');
	if(remCaption != -1) {
		var remCaptionStart = content.indexOf('[');
		content = content.replace(content.substring(remCaptionStart, remCaption + 10), '');
	}

	var date = new Date(req.body.post_date.substring(0, 4), req.body.post_date.substring(5, 7) - 1, req.body.post_date.substring(8, 10), req.body.post_date.substring(11, 13), req.body.post_date.substring(14, 16), req.body.post_date.substring(17,19));

  console.log("Webhook called: " + req.body.post_title + "\n" + img + "\n" + content);

  	if(img != "" || img.substring(0,1) != "<" || img.substring(0,5) != content.substring(0,5)) {
	  	var setNews = db.collection('News').doc(req.body.post_title).set({
			Title: req.body.post_title,
			Timestamp: date,
			Content: content,
			PhotoUrl: img
		}).then(ref => {
			console.log('Set document with ID: ', ref.id);
			return res.end();
		});
  	}
  	else {
		var setNews = db.collection('News').doc(req.body.post_title).set({
			Title: req.body.post_title,
			Timestamp: date,
			Content: content
		}).then(ref => {
			console.log('Set document with ID: ', ref.id);
			return res.end();
		});
	}
});

const https = require('https');
const firebase = require('firebase-admin');
const serviceAccount = require('../xxxxxx.json');
if (firebase.apps.length == 0) {
  firebase.initializeApp({
    credential: firebase.credential.cert(serviceAccount),
  });
}
var db = firebase.firestore();

exports.handler = (event, context, callback) => {
  var body = JSON.parse(event.body)
  console.log(body);


  db.collection("users").doc(body.userUid)
    .update({
      voices: body.voices,
    })
    .catch(err => {
      console.log(err)
    })

  var response = {
    statusCode: 200,
    body: JSON.stringify({
      success: true
    }),
    "headers": {
      "Access-Control-Allow-Origin": "*"
    }
  };

  callback(null, response)

}
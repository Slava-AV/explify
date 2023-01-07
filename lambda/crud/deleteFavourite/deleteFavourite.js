const firebase = require('firebase-admin');
const serviceAccount = require('../xxxxxx.json');
if (firebase.apps.length == 0) {
    firebase.initializeApp({
        credential: firebase.credential.cert(serviceAccount),
    });
}
var db = firebase.firestore();

exports.handler = (event, context, callback) => {

    console.log('Lambda initiated with event:', event);
    var body = JSON.parse(event.body)

    console.log("Will delete page", body.uid)

    db.collection("favourits").doc(body.uid)
        .delete()

    var res = {
        statusCode: 200,
        body: {
            text: ""
        },
        "headers": {
            "Access-Control-Allow-Origin": "*"
        }
    };

}
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

    console.log("Will update page", body.postId)

    if (body.isNewBook) 
        db.collection("books").doc(body.bookId)
        .set({
            bookId: body.bookId,
            title: body.bookTitle,
            created_time: firebase.firestore.Timestamp.fromDate(new Date()),
            user: body.user,
            userId: body.userId,
            })

    db.collection("pages").doc(body.postId)
        .update({
            title: body.title,
            page: body.pageNo,
            bookId: body.bookId,
            bookTitle: body.bookTitle,
        }).then((response) => {
            console.log('Data saved successfully.');
            console.log(JSON.stringify(response));
            res.body = "success"
            callback(null, res)
        }).catch(err => {
            console.log(err)
        })

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
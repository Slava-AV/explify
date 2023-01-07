/* eslint-disable */

const AWS = require('aws-sdk');
var lambda = new AWS.Lambda({
  region: 'us-east-1'
});
const {
  v4: uuidv4
} = require('uuid');


exports.handler = (event, context, callback) => {
  console.log('Lambda initiated with event:', event.body);
  var body = JSON.parse(event.body);

  var res = {
    statusCode: 200,
    body: {
      text: ""
    },
    "headers": {
      "Access-Control-Allow-Origin": "*"
    }
  };

  var jobs = body.imageUrls.map(processImage);

  Promise.all(jobs).then((responses) =>{
    callback(null);
    console.log("Completed")
    console.log(responses)
  })

  function processImage(url) {
    var lambda_params = {
      FunctionName: 'teachyourself-dev1-processImage',
      InvocationType: 'RequestResponse',
      LogType: 'Tail',
      Payload: JSON.stringify({
        body: {
          imageUrl: url,
          pageUID: uuidv4(),
          user: body.user,
          userUid: body.userUid,
          accessType: body.accessType,
          title: body.title,
          bookId: body.bookId,
          limit: body.limit
        }
      })
    }

    try {
      lambda.invoke(lambda_params,
        function (error, data) {
          if (error) {
            console.log("Lambda2 error", error)
          } else {
            console.log("Lambda executed")
          }
        })


    } catch (error) {
      console.log(error)
      res.statusCode = 500
      res.body = JSON.stringify({
        error: error,
      })
    }
  }
}
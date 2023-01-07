const https = require('https');
const AWS = require('aws-sdk');

exports.handler = (event, context, callback) => {
  if (typeof event.body == "string")
    body = JSON.parse(event.body);
  else body = event.body;


  var response = {
    statusCode: 200,
    body: "Sent to slack",
    "headers": {
      "Access-Control-Allow-Origin": "*"
    }
  };

  if (body.base64Img) {
    //save image to S3
    var image = body.base64Img;
    var imageName = body.pageUID + ".png";
    var imagePath = "https://s3.amazonaws.com/explify/users/" + body.userUID + "/uploads/" + imageName;
    var s3 = new AWS.S3();
    var params = {
      Bucket: "explify",
      Key: "users/" + body.userUID + "/uploads/" + imageName,
      Body: Buffer.from(image, 'base64'),
      ACL: "public-read"
    };
    s3.putObject(params, function (err, data) {
      if (err) {
        console.log(err, err.stack);
        response.statusCode = 500;
        response.body = "Error saving image to S3";
        callback(null, response);
      } else {
        console.log("Successfully uploaded data to " + imagePath);
        callback(null, response);
      }
    });
  } else {
    console.log("No image");
    callback(null, response);

  }
}
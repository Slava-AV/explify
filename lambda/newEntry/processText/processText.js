/* eslint-disable */
let AWS = require("aws-sdk");
let polly = new AWS.Polly();
let s3 = new AWS.S3();
var lambda = new AWS.Lambda({
  region: 'us-east-1'
});


const firebase = require('firebase-admin');
const serviceAccount = require('../xxxxxx.json');
if (firebase.apps.length == 0) {
  firebase.initializeApp({
    credential: firebase.credential.cert(serviceAccount),
  });
}
var db = firebase.firestore();

const openAi = require('openai-api');
const openai = new openAi(TOKEN);


exports.handler = (event, context, callback) => {

  

  console.log('Lambda initiated with event:', event.body);
  var body = event.body;

  var settings = {
    simplified: {
      engine: 'curie-instruct-beta',
      prompt: `Explain what the author is saying in simple words:
  """
###text_block###
  """
  The author is saying that`,
      temperature: 0.5,
      maxTokens: 120,
      topP: 1,
      frequencyPenalty: 0.7,
      presencePenalty: 0.7,
      stream: false,
      user: body.userUid,
      stop: ['"""'],
    },
    bullets: {

      engine: 'curie-instruct-beta',
      prompt: 'Make a list of facts from the following text:\n' +
        '###text_block###' +
        '\n\nFacts\n1.',
      temperature: 0.1,
      maxTokens: 150,
      topP: 1,
      frequencyPenalty: 1,
      presencePenalty: 0,
      stream: false,
      user: body.userUid,
      stop: ['"""'],
    },
    questions: {
      engine: 'curie-instruct-beta',
      prompt: 'Make a list of questions about the following text:\n' +
        '###text_block###' +
        '\nQuestions\n1.',
      temperature: 0.3,
      maxTokens: 150,
      topP: 1,
      frequencyPenalty: 0.3,
      presencePenalty: 0.7,
      stream: false,
      user: body.userUid,
      stop: ['"""'],
    },
    contentFilter: {
      engine: 'content-filter-alpha',
      prompt: "",
      maxTokens: 1,
      temperature: 0,
      topP: 0,
      presencePenalty: 0,
      frequencyPenalty: 0,
      bestOf: 1,
      n: 1,
      user: body.userUid,
    }
  }

  db.collection("pages").doc(body.pageUID)
    .set({
      pageId: body.pageUID,
      created_time: firebase.firestore.Timestamp.fromDate(new Date()),
      image_url: body.imageUrl,
      // user: body.user,
      userUid: body.userUid,
      title: body.title,
      page: body.pageNo,
      bookTitle: "Untitled",
      bookId: body.bookId,
      text: body.ocr_text_arr,
      simplified: "",
      bullets: [],
      tests: []
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


  let jobs = [];

  var ocr_text_arr = body.ocr_text_arr;

  ocr_text_arr.forEach(block => {
    if (block.text.length > 200) {
      let params_simplified = JSON.parse(JSON.stringify(settings.simplified))
      let params_bullets = JSON.parse(JSON.stringify(settings.bullets))
      let params_questions = JSON.parse(JSON.stringify(settings.questions))
      let params_filter = JSON.parse(JSON.stringify(settings.contentFilter))

      params_simplified.prompt = settings.simplified.prompt.replace("###text_block###", block.text)
      params_bullets.prompt = settings.bullets.prompt.replace("###text_block###", block.text)
      params_questions.prompt = settings.questions.prompt.replace("###text_block###", block.text)
      params_filter.prompt = "<|endoftext|>" + block.text.trim() + "\n--\nLabel:";

      console.log(params_filter);

      jobs.push(
      )
      jobs.push(
        openai.complete(params_bullets).then(res => ({
          res: res,
          job: 'bullets',
          block: block,
        }))
      )
      jobs.push(
        openai.complete(params_filter).then(res => ({
          res: res,
          job: 'filter',
          block: block
        }))
      )
    }
  })
  let flagged = false;
  Promise.all(jobs).then(responses => {
      let openai_output = {
        simplified: [],
        bullets: [],
        questions: []
      }
      responses.forEach((response, i) => {
        if (!response || !response.job) console.log(i, response)
        else {
        let texts = response.res.data.choices[0].text.trim();
        if (response.job == 'filter') {
          console.log("filter response: ", texts);
          if (texts == "2") { //content is flagged sensitive by the filter
            console.log(response.res)
            flagged = true;
          }
        } else {
          if (response.job == 'bullets')
            console.log("Block:", response.block);
            console.log("Points:", texts);
          if (response.job == 'bullets' || response.job == 'questions') {
            texts = texts.split('\n') //make array of bullets\questions
            //remove trailing numbers: (1. xyzxyz)
            texts = texts.map(text => removeNumbers(text));
            //remove duplicate bullets
            texts = texts.filter((text, index, self) => self.indexOf(text) === index);
            texts.forEach((text, t) => {
              let el = {
                text: removeNumbers(text),
                id: response.block.id
              }
              if (t<4)
                openai_output[response.job].push(el);
            }) 
            
          } else { //simplified
            texts = "The author is saying that " + texts;
            let el = {
              text: texts,
              id: response.block.id
            }
            openai_output[response.job].push(el);
            //text2speech for simplified blocks
            if (response.job == "simplified") {
              textToVoice(el, "simplified")
            }
          }
        }
        
      }
      })

      if (flagged) {
        console.log("Input didn't pass content filter. Returning empty response");
        openai_output.simplified = [{
          text: "Input can't be processed",
          id: 0
        }]
        openai_output.bullets = [{
          text: "Input can't be processed",
          id: 0
        }]
        openai_output.questions = [{
          text: "Input can't be processed",
          id: 0
        }]
      }

      openai_output.simplified = [{
        text: "Please update the app",
        id: 0
      }]
      openai_output.questions = [{
        text: "Please update the app",
        id: 0
      }]

      //need to decrement pages credit
      if (body.accessType == "limited") {
      console.log(`Active credit is ${body.limit}. Reducing by 1`)
      db.collection("users").doc(body.userUid)
        .update({
          pageLimit: body.limit - 1,
        })
        .catch(err => {
          console.log(err)
        })
      }

      db.collection("pages").doc(body.pageUID)
        .update({
          simplified: openai_output.simplified,
          bullets: openai_output.bullets,
          tests: openai_output.questions
        }).then((response) => {
          console.log('Data saved successfully.');
          console.log(JSON.stringify(response));

          console.log("Reporting to Slack")
        const params = {
          FunctionName: 'teachyourself-helpers-dev1-sendFeedback',
          InvocationType: 'RequestResponse',
          LogType: 'Tail',
          Payload: JSON.stringify({
            body: `New page: by ${body.user} (${body.userUid}): \n${body.title}\n${body.imageUrl} \n${body.pageUID} \n${body.accessType} : ${body.limit}`
          })
        }

        try {
          lambda.invoke(params, ()=>{})
        }
        catch (err) {
          console.log(err)
        };
          res.body = "success"
          callback(null, res)
        }).catch(err => {
          console.log(err)
        })
    })
    .catch(function (err) {
      console.log(err);
      res.statusCode = 500;
      res.body = JSON.stringify(err)
      callback(err, res)
    });


    function textToVoice(block, type) {
      let pollyParams = {
        Engine: "neural",
        OutputFormat: "mp3",
        Text: block.text,
        VoiceId: type=="source"?"Joanna":"Matthew"
      };
      // 1. Getting the audio stream for the text that user entered
      polly.synthesizeSpeech(pollyParams)
        .on("success", function (response) {
          let data = response.data;
          let audioStream = data.AudioStream;
          let key = body.userUid + "/" + body.pageUID + "-" + block.id + "-" + type 
          let s3BucketName = 'explify';  
          // 2. Saving the audio stream to S3
          let params = {
            Bucket: s3BucketName,
            Key: key + '.mp3',
            Body: audioStream
          };
          return new Promise((resolve, reject) => {
          s3.putObject(params)
            .on("success", function (response) {
              console.log("S3 Put Success!");
            })
            .on("complete", function () {
              console.log("S3 Put Complete!");
              let s3params = {
                Bucket: s3BucketName,
                Key: key + '.mp3',
              };
              // 3. Getting a signed URL for the saved mp3 file 
              let url = s3.getSignedUrl("getObject", s3params);
              resolve(url);
              // Sending the result back to the user
            })
            .on("error", function (err) {
              console.log(err);
              reject(err)
            })
            .send()
        })
        })
        .on("error", function (err) {
          callback(null, {
            statusCode: 500,
            headers: {
              "Access-Control-Allow-Origin" : "*"
            },
            body: JSON.stringify(err)
          });
        })
        .send();
    }
};



String.prototype.replaceAll = function (search, replacement) {
  var target = this;
  return target.replace(new RegExp(search, 'g'), replacement);
};

function removeNumbers(str) {
  if (!isNaN(str[0]))
    str = str.substring(1, str.length)
  if (str[0] == ".")
    str = str.substring(1, str.length)
  return str.trim();
}

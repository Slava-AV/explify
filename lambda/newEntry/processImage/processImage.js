/* eslint-disable */

const AWS = require('aws-sdk');
var lambda = new AWS.Lambda({
  region: 'us-east-1'
});

const vision = require('@google-cloud/vision');

const client = new vision.ImageAnnotatorClient({
  projectId,
  keyFilename
});

exports.handler = (event, context, callback) => {
  console.log('Lambda initiated with event:', event.body);
  var body
  if (typeof event.body == "string")
    body = JSON.parse(event.body);
  else body = event.body;

  if (body.imageUrl == "" && body.pageUID == "Preflight call") {
    console.log("Preflight call");
    callback(null, {
      statusCode: 200,
      body: JSON.stringify({
        message: "Preflight call"
      }),
      headers: {
        "Access-Control-Allow-Origin": "*"
      }
    });
  } else {

    //report to slack
    const params = {
      FunctionName: 'teachyourself-helpers-dev1-newPageReport',
      InvocationType: 'RequestResponse',
      LogType: 'Tail',
      Payload: JSON.stringify({
        body: {
          base64Img: body.base64Img,
          pageUID: body.pageUID,
          userUID: body.userUid,
          userName: body.user,
        }
      })
    }

    try {
      lambda.invoke(params, ()=>{})
    }
    catch (err) {
      console.log(err)
    };

    const min_block_length = 200;
    const max_block_length = 1500;

    var res = {
      statusCode: 200,
      body: {
        text: ""
      },
      "headers": {
        "Access-Control-Allow-Origin": "*"
      }
    };

    var request = {
      image: {
        source: {
          imageUri: body.imageUrl
        }
      }
    };
    if (body.base64Img)
      request = {
        image: {
          content: Buffer.from(body.base64Img, 'base64')
        }
      };
    client
      .documentTextDetection(request)
      .then((response) => {
        let para;
        let ocr_text_arr = [];
        let ocr_text_str = "";
        const blocks = response[0].fullTextAnnotation.pages[0].blocks;
        console.log(JSON.stringify(blocks));
        let skipped_blocks = 0;
        blocks.forEach((block, b) => {
          if ((block.confidence * 100) > 80) {
            ocr_text_arr.push({
              id: b,
              text: "",
              confidence: block.confidence,
            })
            // add breaks between blocks
            if (b > 0)
              ocr_text_str += "\n\n"
            block.paragraphs.forEach((paragraph, p) => {
              if (p > 0) {
                ocr_text_str += "\n"
              }
              para = ""
              paragraph.words.forEach((word, w) => {
                //add spaces after words but not before punctuation
                if (w != 0 && (word.symbols.length > 1 || !isPunctuation(word.symbols[0].text))) {
                  para += " ";
                }
                word.symbols.forEach(symbol => {
                  para += symbol.text;
                }) //symbols
              }) //words
              ocr_text_arr[b - skipped_blocks].text += para.replace(/(\r\n|\n|\r)/gm, " ");
              ocr_text_str += para;
            }) //paragraphs
          } // if confidence >0.8
          else {
            console.log("Skipping block:", block);
            skipped_blocks++;
          }
        }) //blocks

        console.log("blocks:", ocr_text_arr);

        let title = ocr_text_arr[0].text //assume that the first block is the title
        if (title.indexOf('\n') > 0) //check if it has new lines
          title = title.split('\n')[0]
        if (title.length > 40) //check if the titile is not too long for a title
          title = "";

        //remove title from the page
        if (title !== "")
          ocr_text_arr.splice(0, 1);

        var pageNum = 0

        function extractPageNum(title) {
          // simple attempt to find page number in the title
          let title_words = title.split(" ");
          var i = 0
          for (i = 0; i < title_words.length; i++)
            if (!isNaN(title_words[i])) {
              pageNum = title_words[i]
              break
            }
          // remove paeg number form the title
          if (pageNum != 0 & i == title_words.length)
            title = title.split(pageNum)[0];
          else if (pageNum != 0 & i == 0)
            title = title.split(pageNum)[1];
        }

        if (title != "") {
          extractPageNum(title);
        };

        //If page number is at the bottom
        if (pageNum == 0) {
          if (!isNaN(ocr_text_arr.slice(-1)[0].text)) {
            pageNum = ocr_text_arr.slice(-1)[0].text;
            ocr_text_arr.pop();
          }
        };

        //If the first block doesn't begin with a capital letter and it's too short - discard it
        if (ocr_text_arr[0].text.length < min_block_length && !beginsWithCapital(ocr_text_arr[0].text)) {
          ocr_text_arr.shift();
        }

        //If the last block doesn't end with a dot and it's too short - discard it
        if (ocr_text_arr[ocr_text_arr.length - 1].text.length < min_block_length && !endsWithDot(ocr_text_arr[ocr_text_arr.length - 1].text)) {
          ocr_text_arr.pop();
        }

        //if blocks are too short - merge them
        for (let i = 0; i < ocr_text_arr.length; i++)
          if (ocr_text_arr[i].text.length < min_block_length) {
            // remove block and merge it with the next one
            if (i < ocr_text_arr.length - 1) {
              ocr_text_arr[i + 1].text = ocr_text_arr[i].text + "\n\n" + ocr_text_arr[i + 1].text;
              ocr_text_arr.splice(i, 1);
              i = i - 1;
            }
          };

        //if blocks .are too long - split them
        const splitAt = index => x => [x.slice(0, index), x.slice(index)];
        for (let i = 0; i < ocr_text_arr.length; i++) {
          if (i > ocr_text_arr.length) break

          let b_length = ocr_text_arr[i].text.length;

          if (b_length > max_block_length) {
            // dividing the block by two
            console.log(`The block ${i} of ${ocr_text_arr.length} is too long:`, b_length)
            split_by = Math.round(b_length / max_block_length);
            if (split_by == 1) split_by = 2;

            console.log(`Dividing block into ${split_by}`);

            let b_text = ocr_text_arr[i].text;

            ocr_text_arr.splice(i, 1);

            divideBlock(b_text, split_by);

            function divideBlock(text, divider) {
              console.log(`Shoud divide block into ${divider}`)
              let split_at = findDivider(text, divider);
              console.log(`Splitting at ${split_at}`);
              if (split_at == 0) {
                console.log("split_at is 0!");
                return;
              }

              let firstPart = splitAt(split_at)(text)[0].trim();
              let secondPart = splitAt(split_at)(text)[1].trim();

              if (divider <= 2) {
                // ocr_text_arr[i].text = firstPart;
                ocr_text_arr.splice(i, 0, {
                  id: 0,
                  text: secondPart
                })
                ocr_text_arr.splice(i, 0, {
                  id: 0,
                  text: firstPart
                })
                i++;
                return
              } else {
                ocr_text_arr.splice(i, 0, {
                  id: 0,
                  text: firstPart
                })
                i++;
                divideBlock(secondPart, divider - 1); //repeat from beginning
              }
            }

          }

        } //end of the loop checking for too long blocks

        function findDivider(text, split_by) {
          let start_search = Math.round(text.length / split_by) - 20;
          for (let s = start_search; s < text.length; s++) //searching for an end of sentence around the middle of the block.
            if (text[s] == "." && text[s + 1] != ".")
              return s + 1;
        };

        // Cleaning IDs
        for (let a = 0; a < ocr_text_arr.length; a++)
          ocr_text_arr[a].id = a;

        // ocr_text_arr = ocr_text_arr.reverse();

        console.log("blocks after merging:", ocr_text_arr);

        if (ocr_text_str.length > 200) {

          console.log("Calling lambda2")
          const params = {
            FunctionName: 'teachyourself-dev1-processText',
            InvocationType: 'RequestResponse',
            LogType: 'Tail',
            Payload: JSON.stringify({
              body: {
                imageUrl: body.imageUrl,
                user: body.user,
                userUid: body.userUid,
                title: body.title ? body.title : title,
                bookId: body.bookId ? body.bookId : "-",
                pageNo: pageNum,
                pageUID: body.pageUID,
                ocr_text_arr: ocr_text_arr,
                accessType: body.accessType,
                limit: body.limit
              }
            })
          }

          lambda.invoke(params,
            function (error, data) {
              if (error) {
                console.log("Lambda2 error", error)
                callback(error, null)
              } else {
                console.log("Lambda2 executed")
              }
            })

          res.body = JSON.stringify({
            text: ocr_text_str,
            title: title,
            page: pageNum.toString()
          })
          callback(null, res)
        } else
          res.body = JSON.stringify({
            text: "no_text",
            title: "",
            page: ""
          })
        callback(null, res)
      })
  };
}

function isPunctuation(s) {
  const punctuation = ['.', ',', ';', ':', ')', '!', '?', '...', '-'];
  var isPunctuation = false;
  punctuation.forEach(p => {
    if (s == p) isPunctuation = true;
  })
  return isPunctuation;
};

//utility function to chech if the string begins with the capital letter
function beginsWithCapital(str) {
  return str.charAt(0).toUpperCase() === str.charAt(0);
}

//utility function to chech if the string ends with a dot
function endsWithDot(str) {
  return str.charAt(str.length - 1) == ".";
}
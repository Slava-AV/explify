import '../backend/firebase_storage/storage.dart';
import '../flutter_flow/flutter_flow_drop_down_template.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/upload_media.dart';
import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../auth/auth_util.dart';
import '../backend/backend.dart';
import '../post/post_widget.dart';
import '../backend/api_requests/api_calls.dart';
import 'dart:developer';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';
import '../feed_page/feed_books_widget.dart';
import 'package:toast/toast.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'dart:convert';

var uuid = Uuid();

Mixpanel _mixpanel;
Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
}

class NewEntryProgressWidget extends StatefulWidget {
  NewEntryProgressWidget(
      {Key key, this.uploadFrom, this.accessType, this.limit})
      : super(
          key: key,
        );
  final int uploadFrom;
  final String accessType;
  final int limit;

  @override
  _NewEntryProgressWidgetState createState() => _NewEntryProgressWidgetState();
}

class _NewEntryProgressWidgetState extends State<NewEntryProgressWidget> {
  String uploadedFileUrl;
  TextEditingController textController1;
  TextEditingController textController2;
  TextEditingController textController3;
  FocusNode focusNote3 = new FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool message0Finished;
  bool message1Finished;
  bool message2Finished;
  bool imageSubmitted;
  bool showNoTextMessage;
  bool loading;
  var navNext;
  Map<String, dynamic> bookDropdown;

  final pageId = uuid.v4();
  bool isNewBook = false;

  List<Map<String, dynamic>> booksList;
  List<String> booksListTitle; // = ["+ Create new book"];

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController(text: '');
    textController2 = TextEditingController(text: '');
    textController3 = TextEditingController(text: '');
    loading = true;
    imageSubmitted = true;
    message0Finished = false;
    message1Finished = false;
    message2Finished = false; //false
    showNoTextMessage = false;
    getImageinput();
    getBooksData();
    _initMixpanel();
  }

  getBooksData() async {
    log("getting books list");
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('books');
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await _collectionRef.where('userId', isEqualTo: currentUserUid).get();

    // Get data from docs and convert map to List
    // booksListTitle = booksList.map((book) => book["title"].toString()).toList();
    setState(() {
      booksList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      booksList.add({"title": "+ New Book", "bookId": uuid.v4()});
    });
    log("-------");
    print(booksList);
    log("-------");
  }

  getImageinput() async {
    // final selectedMedia = await selectMedia(
    //   maxWidth: 1500,
    //   fromCamera: widget.uploadFrom != 1,
    // );
    final selectedMedia = await selectMedia(
      maxWidth: 1000.0,
      fromCamera: widget.uploadFrom != 1,
    );
    log(selectedMedia.toString());
    if (selectedMedia != null &&
        validateFileFormat(selectedMedia.storagePath, context)) {
      setState(() {
        imageSubmitted = true;
      });

      String base64Img = await base64Encode(selectedMedia.bytes);

      // final downloadUrl =
      //     await uploadData(selectedMedia.storagePath, selectedMedia.bytes);
      // if (downloadUrl != null) {
      //   setState(() {
      //     uploadedFileUrl = downloadUrl;
      //   });

      final user = currentUserReference;
      // final username = currentUserEmail;

      print("Creating post with ID:");
      print(pageId);
      final apiResponse = await processImageCall(
        imageUrl: uploadedFileUrl,
        pageUID: pageId,
        user: currentUserEmail,
        userUid: currentUserUid,
        accessType: widget.accessType,
        limit: widget.limit,
        base64Img: base64Img,
      );
      print(apiResponse);
      // var resp = ApiResponseObject(apiResponse);
      // log(resp.simplified);
      // print(resp);
      if (apiResponse["text"] != null) {
        if (apiResponse["text"] != "no_text") {
          setState(() {
            if (textController1.text.isEmpty)
              textController1.text = apiResponse["title"];
            if (textController2.text.isEmpty)
              textController2.text = apiResponse["page"];

            navNext = () async {
              //replace page title and page number
              //create new book record
              if (bookDropdown == null ||
                  (isNewBook && textController3.text.isEmpty))
                Toast.show("Choose a book", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              else {
                completePostCreation(
                    title: textController1.text,
                    page: textController2.text,
                    bookTitle: isNewBook
                        ? textController3.text
                        : bookDropdown["title"],
                    postId: pageId,
                    bookId: isNewBook ? uuid.v4() : bookDropdown["bookId"],
                    isNewBook: isNewBook);
                _mixpanel.track("New page added", properties: {
                  "title": textController1.text,
                  "pageId": pageId
                });
                if (isNewBook)
                  _mixpanel.track("New book created",
                      properties: {"bookTitle": textController3.text});
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostWidget(post: null, pageId: pageId),
                  ),
                );
              }
              ;
            };

            loading = false;
          });
        } else {
          log("No text warning");
          setState(() {
            showNoTextMessage = true;
          });
        }
      } else {
        showUploadMessage(context, 'Hmm... something is wrong with the image.');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FeedBooksWidget(),
            ));
      }
    } else {
      log("Image select cancelled");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedBooksWidget(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: FlutterFlowTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(children: [
                Container(
                  margin: EdgeInsets.only(top: 40, bottom: 0),
                  child: Text("New Page",
                      style: FlutterFlowTheme.bodyText1.override(
                          fontFamily: 'Lato',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800])),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            width: 330,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xFFc6c5b3),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: TextFormField(
                                onChanged: (_) => setState(() {}),
                                controller: textController1,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  labelStyle:
                                      FlutterFlowTheme.bodyText2.override(
                                    fontFamily: 'Montserrat',
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      topRight: Radius.circular(4.0),
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      topRight: Radius.circular(4.0),
                                    ),
                                  ),
                                  suffixIcon: textController1.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () => setState(
                                            () => textController1.clear(),
                                          ),
                                          child: Icon(
                                            Icons.clear,
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                ),
                                style: FlutterFlowTheme.bodyText2.override(
                                  fontFamily: 'Roboto Mono',
                                  color: Color(0xFF6F7173),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          width: 330,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            // border: Border.all(
                            //   color: Color(0xFFE6E6E6),
                            // ),
                            color: Color(0xFFc6c5b3),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: TextFormField(
                              onChanged: (_) => setState(() {}),
                              controller: textController2,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Page',
                                labelStyle: FlutterFlowTheme.bodyText2.override(
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0x00000000),
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0x00000000),
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                                suffixIcon: textController2.text.isNotEmpty
                                    ? InkWell(
                                        onTap: () => setState(
                                          () => textController2.clear(),
                                        ),
                                        child: Icon(
                                          Icons.clear,
                                          size: 20,
                                        ),
                                      )
                                    : null,
                              ),
                              style: FlutterFlowTheme.bodyText2.override(
                                fontFamily: 'Roboto Mono',
                                color: Color(0xFF6F7173),
                                fontWeight: FontWeight.w500,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFc6c5b3),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color(0xFFE6E6E6),
                      width: 0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: booksList != null
                        ? FlutterFlowDropDown(
                            // options: ['📔 The Tao of Physics', '+ Add new book'],
                            options: booksList,
                            placeholder: "Select a book",
                            onChanged: (value) {
                              setState(() {
                                bookDropdown = value;
                                print(bookDropdown);
                                setState(() {
                                  isNewBook = value["title"] == "+ New Book";
                                  if (isNewBook)
                                    FocusScope.of(context)
                                        .requestFocus(focusNote3);
                                  // FocusScope.of(context).nextFocus();
                                });
                              }); //dropDownValue = value);
                            },
                            width: 130,
                            height: 40,
                            textStyle: FlutterFlowTheme.bodyText1.override(
                                fontFamily: 'Roboto Mono',
                                color: Color(0xFF6F7173),
                                fontWeight: FontWeight.w500),
                            // fillColor: Colors.white,
                            elevation: 2,
                            borderColor: Colors.grey,
                            borderWidth: 0,
                            borderRadius: 5,
                            margin: EdgeInsets.fromLTRB(16, 4, 8, 4),
                            // hidesUnderline: true,
                          )
                        : Container(),
                  ),
                ),
                isNewBook
                    ? Container(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  width: 330,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xFFc6c5b3),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    child: TextFormField(
                                      focusNode: focusNote3,
                                      onChanged: (_) => setState(() {}),
                                      controller: textController3,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Create a book',
                                        labelStyle:
                                            FlutterFlowTheme.bodyText2.override(
                                          fontFamily: 'Montserrat',
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        suffixIcon: textController3
                                                .text.isNotEmpty
                                            ? InkWell(
                                                onTap: () => setState(
                                                  () => textController3.clear(),
                                                ),
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 20,
                                                ),
                                              )
                                            : null,
                                      ),
                                      style:
                                          FlutterFlowTheme.bodyText2.override(
                                        fontFamily: 'Roboto Mono',
                                        color: Color(0xFF6F7173),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FFButtonWidget(
                    onPressed: navNext,
                    text: !loading ? 'Continue' : "Processing page",
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 60,
                      color: FlutterFlowTheme.actionColor,
                      textStyle: FlutterFlowTheme.subtitle2.override(
                          fontFamily: 'Roboto',
                          color: Colors.grey[100],
                          fontSize: 16),

                      borderRadius: 5,
                    ),
                    icon: loading
                        ? SizedBox(
                            width: 20,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballScale,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                )

              ])
            ],
          ),
        ));
  }
}

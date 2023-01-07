import '../backend/firebase_storage/storage.dart';
import '../flutter_flow/flutter_flow_drop_down_template.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/upload_media.dart';
import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../auth/auth_util.dart';
import '../backend/backend.dart';
import '../backend/api_requests/api_calls.dart';
import 'dart:developer';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';
import '../feed_page/feed_page_widget.dart';
import '../feed_page/feed_books_widget.dart';
import 'package:toast/toast.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

var uuid = Uuid();

Mixpanel _mixpanel;
Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
}

class NewEntryBulkWidget extends StatefulWidget {
  NewEntryBulkWidget({Key key, this.uploadFrom, this.accessType, this.limit})
      : super(
          key: key,
        );
  final int uploadFrom;
  final String accessType;
  final int limit;

  @override
  _NewEntryBulkWidgetState createState() => _NewEntryBulkWidgetState();
}

class _NewEntryBulkWidgetState extends State<NewEntryBulkWidget> {
  List<String> uploadedFileUrl;
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
  bool isLoading = false;

  List<Map<String, dynamic>> booksList;
  List<String> booksListTitle; 
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
    getImagesinput();
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
    setState(() {
      booksList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    log("-------");
    print(booksList);
    log("-------");
  }

  getImagesinput() async {
    final selectedMedia = await selectMediaBatch(
      maxWidth: 1500,
      fromCamera: widget.uploadFrom != 1,
    );
    log(selectedMedia.toString());
    if (selectedMedia != null
        ) {
      setState(() {
        imageSubmitted = true;
      });

      var downloadUrls = await Future.wait(selectedMedia
          .map((_image) => uploadData(_image.storagePath, _image.bytes)));
      print(downloadUrls);
      if (downloadUrls != null) {
        setState(() {
          uploadedFileUrl = downloadUrls;
        });

        setState(() {
          navNext = () async {
            if (bookDropdown == null || (textController1.text.isEmpty)) {
              Toast.show("Fill in all the fields", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
              return;
            }
            setState(() {
              isLoading = true;
            });
            final apiResponse = await processImagesBulkCall(
              imageUrls: downloadUrls,
              title: textController1.text,
              bookId: bookDropdown["bookId"],
              user: currentUserEmail,
              userUid: currentUserUid,
              accessType: widget.accessType,
              limit: widget.limit,
            );
            setState(() {
              isLoading = false;
            });

            if (apiResponse != null) {
              Toast.show("Pages added", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedPageWidget(
                      bookId: bookDropdown["bookId"],
                      bookTitle: bookDropdown["title"]),
                ),
              );
            } else
              showUploadMessage(context, 'Bulk job error');
          };

          loading = false;
        });
      } else {
        showUploadMessage(context, 'Hmm... something is wrong with the image.');
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
          Container(
            margin: EdgeInsets.only(top: 40, bottom: 0),
            width: double.infinity,
            // height: 60,
            child: Visibility(
              visible: imageSubmitted,
              child: Align(
                alignment: Alignment(-1, 0),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Uploading images',
                                  textStyle:
                                      FlutterFlowTheme.bodyText1.override(
                                    fontFamily: 'Roboto Mono',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  speed: const Duration(milliseconds: 50),
                                ),
                              ],
                              // pause: const Duration(milliseconds: 1500),
                              isRepeatingAnimation: false,
                              onFinished: () {
                                setState(() {
                                  message0Finished = true;
                                });
                              }),
                        ),
                        Visibility(
                          visible: message0Finished && uploadedFileUrl == null,
                          child: Container(
                            // alignment: Alignment(-0.5, 1.08),
                            transform:
                                Matrix4.translationValues(-8.0, 2.0, 0.0),
                            child: SizedBox(
                              height: 14,
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballBeat,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
          AnimatedOpacity(
              opacity: uploadedFileUrl != null ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Column(children: [
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
                                // setState(() {
                                //   isNewBook = value["title"] == "+ New Book";
                                //   if (isNewBook)
                                //     FocusScope.of(context)
                                //         .requestFocus(focusNote3);
                                // });
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
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FFButtonWidget(
                    onPressed: navNext,
                    text: isLoading ? '' : 'Continue',
                    icon: isLoading
                        ? SizedBox(
                            width: 36,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballScale,
                              color: Colors.white,
                            ),
                          )
                        : null,
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
                  ),
                )

              ]))
        ],
      ),
    ));
  }
}

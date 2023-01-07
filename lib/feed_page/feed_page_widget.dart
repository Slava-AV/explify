import '../backend/backend.dart';
import '../auth/auth_util.dart';
import 'package:explify/feed_page/feed_favourits_widget.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../post/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:explify/login_page/login_page_widget.dart';
import '../backend/api_requests/api_calls.dart';
import 'package:toast/toast.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../components/fab_widget.dart';
import 'package:explify/components/drawer.dart';

Mixpanel _mixpanel;
Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
}

class FeedPageWidget extends StatefulWidget {
  FeedPageWidget({Key key, this.bookId, this.bookTitle}) : super(key: key);

  final String bookId;
  final String bookTitle;

  @override
  _FeedPageWidgetState createState() => _FeedPageWidgetState();
}

class _FeedPageWidgetState extends State<FeedPageWidget> {
  String uploadedFileUrl;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String workingStatus = "";
  var message1Finished = false;
  int uploadFrom = 0;
  String contextItemId = "";
  int limit = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: fabWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: drawer(),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.appBar,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        // leading: BackButton(color: Colors.grey[700]),
        automaticallyImplyLeading: true,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Padding(
              //   padding: EdgeInsets.only(right: 5.0),
              //   child: Icon(Icons.my_library_books_rounded,
              //       size: 20, color: Colors.black),
              // ),
              Text(
                widget.bookTitle,
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedFavouritsWidget(),
                ),
              );
            },
            icon:
                //   Icon(
                //     Icons.star,
                //     size: 24,
                //     color: Colors.deepOrange[400],
                //   ),
                Text(
              "🧠",
              style: FlutterFlowTheme.bodyText1.override(
                fontFamily: 'Lato',
                fontSize: 20,
              ),
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFf9f6ed),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0, color: Colors.grey.shade300),
            ),
          ),
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  color: FlutterFlowTheme.secondaryColor,
                  backgroundColor: Colors.transparent,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: queryPostsRecord(
                          queryBuilder: (postsRecord) => postsRecord
                              .where('userUid', isEqualTo: currentUserUid)
                              .where('bookId', isEqualTo: widget.bookId)
                              .orderBy('page', descending: false),
                        ),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            _refreshIndicatorKey.currentState.show();
                            return Container(
                                // child: Padding(
                                //   padding: const EdgeInsets.only(top: 235.0),
                                //   child: Center(
                                //     child: AnimatedTextKit(
                                //       animatedTexts: [
                                //         TypewriterAnimatedText(
                                //           '...',
                                //           textStyle:
                                //               FlutterFlowTheme.bodyText1.override(
                                //             fontFamily: 'Roboto Mono',
                                //             fontSize: 16,
                                //             fontWeight: FontWeight.w600,
                                //           ),
                                //           speed:
                                //               const Duration(milliseconds: 100),
                                //         ),
                                //       ],
                                //       isRepeatingAnimation: false,
                                //     ),
                                //   ),
                                // ),
                                );
                          }

                          // Customize what your widget looks like with no query results.
                          else if (snapshot.data.docs.length < 1) {
                            // indicator.currentState.dispose;
                            return Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 100.0),
                                    child: IconButton(
                                      iconSize: 128,
                                      onPressed: () {},
                                      icon:
                                          Icon(Icons.add_circle_outline_sharp),
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'Start by adding a page',
                                        textStyle:
                                            FlutterFlowTheme.bodyText1.override(
                                          fontFamily: 'Roboto Mono',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        speed: const Duration(milliseconds: 50),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // indicator.currentState.dispose;
                            return ListView(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                // itemCount: snapshot.data.length,
                                // itemBuilder: (context, listViewIndex) {
                                //   final listViewPostsRecord =
                                //       listViewPostsRecordList[listViewIndex];
                                children: snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> listViewPostsRecord =
                                      document.data() as Map<String, dynamic>;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          // print('Going to:');
                                          // print(listViewPostsRecord);
                                          _mixpanel.track("Page opened",
                                              properties: {
                                                "pageId": listViewPostsRecord[
                                                    "pageId"],
                                              });
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PostWidget(
                                                  post: null,
                                                  pageId: listViewPostsRecord[
                                                      "pageId"]),
                                            ),
                                          );
                                        },
                                        onLongPress: () =>
                                            showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: 300,
                                              // color: Colors.amber,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0,
                                                            bottom: 5),
                                                    child: Text(
                                                      'Actions',
                                                      style: FlutterFlowTheme
                                                          .bodyText1
                                                          .override(
                                                        fontFamily: 'Lato',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.grey[700],
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(),
                                                  InkWell(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          20, 10, 20, 10),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8.0),
                                                            child: Icon(
                                                              Icons
                                                                  .delete_outline_rounded,
                                                              color: Colors.red,
                                                              size: 24,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Delete page",
                                                            style:
                                                                FlutterFlowTheme
                                                                    .bodyText1
                                                                    .override(
                                                              fontFamily:
                                                                  'Lato',
                                                              // fontWeight: FontWeight.w600,
                                                              color: Colors.red,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      print("Deleting post:");
                                                      print(listViewPostsRecord[
                                                          "pageId"]);
                                                      Toast.show(
                                                          "Deleting page...",
                                                          context,
                                                          duration:
                                                              Toast.LENGTH_LONG,
                                                          gravity:
                                                              Toast.BOTTOM);

                                                      Navigator.pop(context);
                                                      await deletePage(
                                                          postId:
                                                              listViewPostsRecord[
                                                                  "pageId"]);
                                                    },
                                                  ),
                                                  Divider(),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 12, 0, 12),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.grey.shade300),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 0, 0, 0),
                                                child: Container(
                                                  width: 300,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Icon(
                                                          Icons
                                                              .insert_drive_file_outlined,
                                                          size: 20,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 250,
                                                        child: Text(
                                                          listViewPostsRecord[
                                                                      "page"]
                                                                  .toString() +
                                                              " - " +
                                                              listViewPostsRecord[
                                                                  "title"],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          softWrap: true,
                                                          style: GoogleFonts
                                                              .zillaSlab(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment(0.50, 0),
                                                  child: Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey[500],
                                                    size: 20,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList());
                          }
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

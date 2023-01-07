import 'package:explify/components/drawer.dart';
import 'package:explify/components/onboarding.dart';
import 'package:explify/feed_page/feed_favourits_widget.dart';
import 'package:explify/feed_page/feed_page_widget.dart';
import 'package:explify/settings/voices.dart';

import '../backend/backend.dart';
import '../auth/auth_util.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:explify/login_page/login_page_widget.dart';
import '../analytics.dart';
import '../components/fab_widget.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:explify/payment/payment_api.dart';

class FeedBooksWidget extends StatefulWidget {
  FeedBooksWidget({Key key}) : super(key: key);

  @override
  _FeedBooksWidgetState createState() => _FeedBooksWidgetState();
}

class _FeedBooksWidgetState extends State<FeedBooksWidget> {
  var isDialOpen = ValueNotifier<bool>(false);
  String uploadedFileUrl;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String workingStatus = "";
  var message1Finished = false;
  int uploadFrom = 0;
  String contextItemId = "";
  List<Map<String, dynamic>> booksList;
  int limit = 0;
  Mixpanel _mixpanel;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(currentUserUid);
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(milliseconds: 500));
  }

  Color getBookColorBasedOnLength(int length) {
    if (length % 9 == 0) {
      return Colors.deepOrange[300];
    } else if (length % 8 == 0) {
      return Colors.orange[400];
    } else if (length % 7 == 0) {
      return Colors.deepOrange[500];
    } else if (length % 6 == 0) {
      return Colors.orange[600];
    } else if (length % 5 == 0) {
      return Colors.green[600];
    } else if (length % 4 == 0) {
      return Colors.green[500];
    } else if (length % 3 == 0) {
      return Colors.green[400];
    } else if (length % 2 == 0) {
      return Colors.green[300];
    } else {
      return Colors.lightGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: fabWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: drawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey[800]),
        backgroundColor: FlutterFlowTheme.appBar,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Padding(
              //   padding: EdgeInsets.only(right: 5.0),
              //   child: Icon(Icons.auto_stories_outlined,
              //       size: 20, color: Colors.black),
              // ),
              Text(
                'My books',
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
                // Icon(
                //   Icons.star,
                //   size: 24,
                //   color: Colors.deepOrange[400],
                // ),
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
                        stream: queryBooksRecord(
                          queryBuilder: (postsRecord) => postsRecord
                              .where('userId', isEqualTo: currentUserUid)
                              .orderBy('created_time', descending: true),
                        ),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            return Container(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 235.0),
                                child: Center(
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        '...',
                                        textStyle:
                                            FlutterFlowTheme.bodyText1.override(
                                          fontFamily: 'Roboto Mono',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        speed:
                                            const Duration(milliseconds: 100),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                ),
                              ),
                            );
                          }

                          // Customize what your widget looks like with no query results.
                          else if (snapshot.data.docs.length < 1) {
                            return Container(
                              child: Column(
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(top: 100.0),
                                      // child: IconButton(
                                      //   iconSize: 128,
                                      //   onPressed: () {},
                                      //   icon: Icon(Icons.add_circle_outline_sharp),
                                      //   color: Colors.grey[700],
                                      // ),
                                      child: Image.asset(
                                        'assets/images/empty_state.png',
                                        height: 300,
                                        fit: BoxFit.contain,
                                      )),
                                  SizedBox(
                                    height: 20,
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
                                      document.data();
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          // print('Going to:');
                                          // print(listViewPostsRecord);
                                          _mixpanel.track("Book opened",
                                              properties: {
                                                "bookId": listViewPostsRecord[
                                                    "bookId"],
                                                "title": listViewPostsRecord[
                                                    "title"],
                                              });
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FeedPageWidget(
                                                      bookId:
                                                          listViewPostsRecord[
                                                              "bookId"],
                                                      bookTitle:
                                                          listViewPostsRecord[
                                                              "title"]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 12, 0, 12),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 2.0,
                                                  color: Colors.grey.shade300),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 0, 0, 0),
                                                child: Container(
                                                  width: 300,
                                                  height: 70,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 25),
                                                        child: Icon(
                                                            Icons
                                                                .chrome_reader_mode_outlined,
                                                            size: 50,
                                                            color: getBookColorBasedOnLength(
                                                                listViewPostsRecord[
                                                                        "title"]
                                                                    .length)),
                                                      ),
                                                      Text(
                                                        listViewPostsRecord[
                                                            "title"],
                                                        style: GoogleFonts
                                                            .zillaSlab(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                    color: Colors.grey[800],
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

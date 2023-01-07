import 'package:cached_network_image/cached_network_image.dart';
import 'package:explify/components/drawer.dart';
import 'package:explify/components/memo_widget.dart';

import '../backend/backend.dart';
import '../auth/auth_util.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../backend/api_requests/api_calls.dart';
import 'package:explify/components/memo_modal_widget.dart';

import '../settings/voices.dart';

class FeedFavouritsWidget extends StatefulWidget {
  FeedFavouritsWidget({Key key}) : super(key: key);

  @override
  _FeedFavouritsWidgetState createState() => _FeedFavouritsWidgetState();
}

class _FeedFavouritsWidgetState extends State<FeedFavouritsWidget> {
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

  List<bool> grid = [true, false];
  var itemKey = GlobalKey();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.track("Starred list opened");
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> scrollToItem() async {
    final context = itemKey.currentContext;
    await Scrollable.ensureVisible(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: drawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey[800]),

        backgroundColor: FlutterFlowTheme.appBar,
        // leading: BackButton(color: Colors.grey[700]),
        automaticallyImplyLeading: true,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'Brain feed',
              //   style: FlutterFlowTheme.bodyText1.override(
              //     fontFamily: 'Lato',
              //     fontSize: 18,
              //   ),
              // ),
            ],
          ),
        ),
        actions: [
          ToggleButtons(
            selectedColor: Colors.blue,
            color: Colors.grey[600],
            // selectedBorderColor: Colors.blue[700],
            children: [
              Icon(
                Icons.list,
                // color: Colors.grey[500],
              ),
              Icon(
                Icons.grid_on,
                // color: Colors.grey[500],
              ),
            ],
            isSelected: grid,
            onPressed: (int index) {
              setState(() {
                grid[0] = !grid[0];
                grid[1] = !grid[1];
              });
            },
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
                    // shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: queryFavouritsRecord(
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
                                      child:
                                          // Icon(
                                          //   Icons.star,
                                          //   size: 50,
                                          //   color: Colors.deepOrange[400],
                                          // )),
                                          Text(
                                        "🧠",
                                        style:
                                            FlutterFlowTheme.bodyText1.override(
                                          fontFamily: 'Lato',
                                          fontSize: 30,
                                        ),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        "No memos here.\nStart by adding a page.",
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
                            var childrenMap = snapshot.data.docs.asMap();
                            return Stack(children: [
                              Visibility(
                                maintainState: false,
                                visible: grid[1],
                                child: GridView(
                                  padding: EdgeInsets.only(top: 10),
                                  primary: false,
                                  shrinkWrap: true,
                                  children: childrenMap
                                      .map((int i, DocumentSnapshot document) {
                                        Map<String, dynamic>
                                            listViewPostsRecord =
                                            document.data();
                                        return MapEntry(
                                          i,
                                          Container(
                                            color: Colors.grey[200],
                                            width: 100,
                                            height: 100,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              child: InkWell(
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    Container(
                                                      // height: 100,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            listViewPostsRecord[
                                                                "imgUrl"],
                                                        fit: BoxFit.cover,
                                                        fadeInDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    10),
                                                      ),
                                                    ),
                                                    //colored circle
                                                    Container(
                                                      margin: EdgeInsets.all(8),
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: listViewPostsRecord[
                                                                'color'] is int
                                                            ? Color(
                                                                listViewPostsRecord[
                                                                    'color'])
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder:
                                                          (BuildContext context,
                                                                  _, __) =>
                                                              MemoModalWidget(
                                                        record:
                                                            listViewPostsRecord,
                                                        records: snapshot
                                                            .data.docs
                                                            .map(
                                                                (DocumentSnapshot
                                                                    document) {
                                                          Map<String, dynamic>
                                                              item =
                                                              document.data();
                                                          return item;
                                                        }).toList(),
                                                        index: i,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                ),
                              ),
                              Visibility(
                                maintainState: true,
                                visible: grid[0],
                                child: Column(
                                  children: childrenMap
                                      .map((int i, DocumentSnapshot document) {
                                        return MapEntry(
                                            i,
                                            Center(
                                              key: Key(document["imgUrl"]),
                                              child: Container(
                                                  color: Colors.transparent,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  child: InkWell(
                                                    child: MemoWidget(
                                                        record:
                                                            document.data()),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (BuildContext
                                                                      context,
                                                                  _,
                                                                  __) =>
                                                              MemoModalWidget(
                                                            record:
                                                                document.data(),
                                                            records: snapshot
                                                                .data.docs
                                                                .map((DocumentSnapshot
                                                                    document) {
                                                              Map<String,
                                                                      dynamic>
                                                                  item =
                                                                  document
                                                                      .data();
                                                              return item;
                                                            }).toList(),
                                                            index: i,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )),
                                            ));
                                      })
                                      .values
                                      .toList(),
                                ),
                              ),
                            ]);
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

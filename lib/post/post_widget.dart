import 'package:explify/components/player_widget.dart';
import 'package:explify/feed_page/feed_favourits_widget.dart';
import '../auth/auth_util.dart';
import '../backend/api_requests/api_calls.dart';
import '../backend/backend.dart';
import '../flutter_flow/flutter_flow_theme.dart';
// import '../flutter_flow/flutter_flow_util.dart';
// import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../flutter_flow/upload_media.dart';
import 'package:loading_indicator/loading_indicator.dart';
// import 'package:expandable/expandable.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:flutter/services.dart';
import '../components/context_menu_simplified.dart';
// import '../components/custom_selection_toolbar.dart';
import 'package:explify/components/star_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:explify/components/drawer.dart';

TabController _tabController;
Mixpanel _mixpanel;

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

Future<void> showInformationDialog(BuildContext context, String generation,
    String sourceBlock, String type, String postId, String user) async {
  _mixpanel.track("Flag dialog open");
  return await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _textEditingController =
            TextEditingController();

        // _textEditingController.text = text;
        bool hasError = false;
        bool hasOffensive = false;
        return StatefulBuilder(builder: (context, setState) {
          _textEditingController.addListener(() {
            setState(() {});
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.flag_rounded, size: 24),
                      ),
                      Text("Report generation:",
                          style: FlutterFlowTheme.subtitle1),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.fromLTRB(5, 7, 12, 0),
                    //   alignment: Alignment.topLeft,
                    //   child: Icon(Icons.circle_rounded, size: 8),
                    // ),
                    Flexible(
                      // width: MediaQuery.of(context).size.width * 0.6,
                      // padding: const EdgeInsets.all(8.0),
                      child: Text(
                        generation,
                        style: FlutterFlowTheme.bodyText1,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CheckboxListTile(
                            title: Text("There's an error"),
                            contentPadding: EdgeInsets.all(0),
                            isThreeLine: false,
                            value: hasError,
                            onChanged: (bool val) {
                              setState(() {
                                hasError = val;
                              });
                            }),
                        // CheckboxListTile(
                        //     title: Text("It's trivial"),
                        //     contentPadding: EdgeInsets.all(0),
                        //     isThreeLine: false,
                        //     value: hasTrivial,
                        //     onChanged: (bool val) {
                        //       setState(() {
                        //         hasTrivial = val;
                        //       });
                        //     }),
                        CheckboxListTile(
                            title: Text("It's offensive"),
                            contentPadding: EdgeInsets.all(0),
                            isThreeLine: false,
                            value: hasOffensive,
                            onChanged: (bool val) {
                              setState(() {
                                hasOffensive = val;
                              });
                            }),
                        TextFormField(
                          controller: _textEditingController,
                          // validator: (value) {
                          //   return value.isNotEmpty ? null : "Invalid Field";
                          // },
                          minLines: 2,
                          maxLines: 5,
                          decoration: InputDecoration(
                              hintText: "Comment (optional)",
                              border: OutlineInputBorder()),
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text("Choice Box"),
                        //     Checkbox(
                        //         value: isChecked,
                        //         onChanged: (checked) {
                        //           setState(() {
                        //             isChecked = checked;
                        //           });
                        //         })
                        //   ],
                        // )
                      ],
                    )),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Send'),
                onPressed: (hasError ||
                        hasOffensive ||
                        _textEditingController.text != "")
                    ? () async {
                        await sendFeedbackCall(
                          comment: _textEditingController.text,
                          generation: generation,
                          sourceBlock: sourceBlock,
                          postId: postId,
                          user: user,
                          type: type,
                          hasError: hasError,
                          hasOffensive: hasOffensive,
                        );
                        Toast.show("Feedback sent", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          );
        });
      });
}

class BulletItemWidget extends StatelessWidget {
  final String text;
  final Map<String, dynamic> post;
  final bool isActive;

  BulletItemWidget({this.text, this.post, this.isActive});

  @override
  Widget build(BuildContext context) {
    return text.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
            child: Card(
              color: isActive ? FlutterFlowTheme.secondaryColor : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              // width: MediaQuery.of(context).size.width * 0.75,
                              // padding: const EdgeInsets.all(8.0),
                              child:
                                  Text(text, style: FlutterFlowTheme.bodyText0),
                            ),
                          ]),
                    ),
                    // InkWell(
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(left: 10, right: 10),
                    //       child:
                    //           Icon(Icons.star, color: Colors.grey[500], size: 30),
                    //     ),
                    //     onTap: () async {
                    //
                    InkWell(
                      onTap: () async {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return ContextMenuSimplified(
                                  text: text, type: "simplified", post: post);
                            });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.more_vert_outlined,
                              size: 24, color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class SimplifiedItemWidget extends StatelessWidget {
  final String text;
  final Map<String, dynamic> post;

  SimplifiedItemWidget({this.text, this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          // padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: Text(text, style: FlutterFlowTheme.bodyText1),
          ),
        ),
        InkWell(
          onTap: () async {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return ContextMenuSimplified(
                      text: text, type: "simplified", post: post);
                });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.more_vert_outlined,
                size: 24, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class TextItemWidget extends StatelessWidget {
  final String text;
  final int index;
  final Map<String, dynamic> post;

  TextItemWidget({this.text, this.post, this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 0, 12, 0),
          width: MediaQuery.of(context).size.width * 1,
          // padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: FlutterFlowTheme.secondaryColor,
                selectionHandleColor: FlutterFlowTheme.actionColor,
              ),
            ),
            child: SelectableText(
              text,
              style: FlutterFlowTheme.bodyText1,
              toolbarOptions: ToolbarOptions(
                copy: true,
                selectAll: false,
              ),

            ),
          ),
        ),

      ],
    );
  }
}

class TesttItemWidget extends StatelessWidget {
  final String text;
  final Map<String, dynamic> post;

  TesttItemWidget({this.text, this.post});

  @override
  Widget build(BuildContext context) {
    return text.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
            child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                              alignment: Alignment.topLeft,
                              child: Icon(
                                Icons.help_outline,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                            Flexible(
                              // width: MediaQuery.of(context).size.width * 0.74,
                              child: Text(
                                text,
                                style: FlutterFlowTheme.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return ContextMenuSimplified(
                                    text: text, type: "question", post: post);
                              });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.more_vert_outlined,
                              size: 24, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),

                ]),
          );
  }
}

class ApiResponseObject {
  List text;
  String title;
  String page;
  List simplified;
  List bullets;
  List tests;
  ApiResponseObject(Map<String, dynamic> data) {
    text = data['text'];
    title = data['title'];
    page = data['page'];
  }
}

class AiApiResponseObject {
  List bullets;
  AiApiResponseObject(Map<dynamic, dynamic> data) {
    bullets = data['bullets'].cast<String>();
  }
}

class PostWidget extends StatefulWidget {
  PostWidget({
    Key key,
    this.pageId,
    this.post,
  }) : super(key: key);

  final PostsRecord post;
  final String pageId;

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController titleController;
  // Map<String, dynamic> post;
  bool playerExpanded = false;
  // TabController _tabController;

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  List bulletStates = [];

  bool isAnyItemSelected() {
    for (var item in bulletStates) {
      if (item) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _initMixpanel();

    _tabController = new TabController(vsync: this, length: 2);
    _tabController.index = 0;
    _tabController.addListener(() {
      const List tabs = ["Source", "Simplified", "Bullets", "Questions"];
      String tab = "";
      try {
        tab = tabs[_tabController.index];
      } catch (e) {
        print(e);
      }

      _mixpanel.track("Tab opened: $tab");
    });
    titleController = TextEditingController(text: "");
    // var ocr_text = postPostsRecord.text;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.post != null
            ? queryPostsRecord(
                queryBuilder: (postsRecord) => postsRecord.where('created_time',
                    isEqualTo: widget.post.createdTime),
                // .orderBy('created_time', descending: true),
                singleRecord: true)
            : queryPostsRecord(
                queryBuilder: (postsRecord) => postsRecord
                    .where(FieldPath.documentId, isEqualTo: widget.pageId),
                // postsRecord.orderBy('created_time', descending: true),
                singleRecord: true),
        // : PostsRecord.getDocument(widget.post.reference),
        builder: (context, snapshot) {
          print(snapshot);
          // Customize what your widget looks like when it's loading.
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final postPostsRecord = snapshot.data.docs[0].data() as Map;
          // PostsRecord postPostsRecord =  new PostsRecord(
          //   title: snapshot.data.docs[0];
          // setState(() {
          titleController.text = postPostsRecord["title"];
          // });
          // print(postPostsRecord);
          print(snapshot.data.docs.length);
          return Scaffold(
            key: scaffoldKey,
            drawer: drawer(),
            floatingActionButton: Align(
              alignment: Alignment(0.0, 0.96),
              child: new FloatingActionButton.extended(
                backgroundColor:
                    isAnyItemSelected() ? Colors.blue : Colors.grey,
                onPressed: () async {
                  if (!isAnyItemSelected()) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                        "Select one or more points to save as memo",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ));
                    return;
                  } else {
                    // merge all selected items
                    String text = "";
                    for (var i = 0;
                        i < postPostsRecord["bullets"].length;
                        i++) {
                      if (bulletStates[i]) {
                        text += postPostsRecord["bullets"][i]["text"] + "\n";
                      }
                    }
                    text = text.trim();

                    _mixpanel.track("Item starred", properties: {
                      "text": text,
                      "item_type": "bullet",
                    });

                    final ProgressDialog pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: true);
                    pr.style(
                        message: 'Preparing your memo...',
                        borderRadius: 10.0,
                        backgroundColor: Colors.white,
                        progressWidget: CircularProgressIndicator(),
                        elevation: 10.0,
                        insetAnimCurve: Curves.easeInOut,
                        progress: 0.0,
                        maxProgress: 100.0,
                        progressTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                        messageTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600));
                    print("loading...");
                    // Navigator.pop(context);
                    await pr.show();
                    var memoData = await getDataForMemo(text: text);
                    // print(memoData);
                    //reset all selected items
                    setState(() {
                      
                    for (var i = 0;
                        i < postPostsRecord["bullets"].length;
                        i++) {
                      bulletStates[i] = false;
                    }
                    });
                    await pr.hide();

                    Navigator.of(context).push(
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder:
                                                    (BuildContext context, _,
                                                            __) =>
                         StarDialogWidget(
                            record: postPostsRecord,
                            text: text,
                            memoData: memoData)
                                              ),
                                            );
                    
                  }
                },
                label: new Text('Create memo',
                    style: TextStyle(
                        color: isAnyItemSelected()
                            ? Colors.white
                            : Colors.grey[200])),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.appBar,
              iconTheme: IconThemeData(
                color: FlutterFlowTheme
                    .primaryStrongColor, //change your color here
              ),
              automaticallyImplyLeading: true,

              title: Text(
                postPostsRecord["title"],
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  fontSize: 18,
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
                  icon: Icon(
                    Icons.star,
                    size: 24,
                    color: Colors.deepOrange[400],
                  ),
                )
              ],
              centerTitle: true,
              elevation: 0,
            ),
            backgroundColor: FlutterFlowTheme.backgroundColor,
            body: SafeArea(
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //
                    TabBar(
                      controller: _tabController,
                      labelColor: FlutterFlowTheme.tabsLabelsColor,
                      // indicatorColor: FlutterFlowTheme.secondaryColor,
                      indicatorColor: Colors.blue[200],
                      indicatorWeight: 2,
                      tabs: [
                        Tab(

                          text: 'Key points',
                        ),
                        Tab(
                          text: 'Source',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Divider(
                                height: 1,
                                color: Colors.grey[600],
                              ),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final bullet =
                                        postPostsRecord["bullets"]?.toList() ??
                                            [];
                                    for (int i = 0; i < bullet.length; i++) {
                                      bulletStates.add(false);
                                    }
                                    return ListView.builder(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 30),
                                      scrollDirection: Axis.vertical,
                                      itemCount: bullet.length,
                                      itemBuilder: (context, bulletIndex) {
                                        final bulletItem = bullet[bulletIndex];
                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: InkWell(
                                            child: BulletItemWidget(
                                                isActive:
                                                    bulletStates[bulletIndex],
                                                text: bulletItem["text"],
                                                post: postPostsRecord),
                                            onTap: () {
                                              setState(() {
                                                bulletStates[bulletIndex] =
                                                    !bulletStates[bulletIndex];
                                                print(bulletStates);
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final sourceText =
                                        postPostsRecord["text"]?.toList() ?? [];
                                    return ListView.builder(
                                      shrinkWrap: false,
                                      padding: EdgeInsets.fromLTRB(0, 7, 0, 30),
                                      scrollDirection: Axis.vertical,
                                      itemCount: sourceText.length,
                                      itemBuilder: (context, sourceTextIndex) {
                                        final sourceTextItem =
                                            sourceText[sourceTextIndex];
                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: TextItemWidget(
                                              text: sourceTextItem["text"],
                                              index: sourceTextItem["id"],
                                              post: postPostsRecord),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

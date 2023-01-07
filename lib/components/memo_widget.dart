// import '../flutter_flow/flutter_flow_audio_player.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../post/post_widget.dart';
import 'package:explify/components/memo_voice_player.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../backend/api_requests/api_calls.dart';
import 'package:toast/toast.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class MemoWidget extends StatefulWidget {
  final Map<String, dynamic> record;
  final Map<String, dynamic> memoData;
  MemoWidget({Key key, this.record, this.memoData}) : super(key: key);

  @override
  _MemoWidgetState createState() => _MemoWidgetState();
}

class _MemoWidgetState extends State<MemoWidget> {
  Mixpanel _mixpanel;

  @override
  Widget build(BuildContext context) {
    String title = widget.record['text'];
    //get fist two words from title
    title = title.substring(
        0,
        title.indexOf(' ') +
            title.substring(title.indexOf(' ') + 1, title.length).indexOf(' ') +
            1);
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Column(
        children: [
          ListTile(
            minVerticalPadding: 0,
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.all(0),
            // horizontalTitleGap: 10,
            leading: SizedBox(width: 40),
            title: RichText(
              text: TextSpan(
                  style: GoogleFonts.zillaSlab(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500]),
                  children: [
                    TextSpan(
                        text: widget.record["pageTitle"],
                        style: GoogleFonts.zillaSlab(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700])),
                    TextSpan(text: " | "),
                    TextSpan(text: widget.record["bookTitle"]),
                  ]),
            ),
            onTap: () async {
              // print('Going to:');
              // print(listViewPostsRecord);
              // _mixpanel.track(
              //     "Page opened",
              //     properties: {
              //       "pageId":
              //           listViewPostsRecord[
              //               "pageId"],
              //     });
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PostWidget(post: null, pageId: widget.record["pageId"]),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      // color: Colors.amber,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, bottom: 5),
                            child: Text(
                              'Actions',
                              style: FlutterFlowTheme.bodyText1.override(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Divider(),
                          InkWell(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  Text(
                                    "Delete memo",
                                    style: FlutterFlowTheme.bodyText1.override(
                                      fontFamily: 'Lato',
                                      // fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              //call deleteFavourite api
                              Toast.show("Deleting memo...", context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.TOP);
                              Navigator.pop(context);
                              deleteFavourite(uid: widget.record["uid"]);
                              _mixpanel.track("Starred item deleted");
                            },
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                width: 50,
                color: Colors.transparent,
                child: widget.record['icon'] != null
                    ? Text(
                        widget.record['icon'],
                        style: FlutterFlowTheme.bodyText1
                            .override(fontFamily: 'Lato', fontSize: 28),
                      )
                    : Container(),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: Colors.white,
                  // color: FlutterFlowTheme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    // side: BorderSide(
                    //   color: Colors.grey.withOpacity(0.3),
                    //   width: 2,
                    // ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        widget.record["imgUrl"] != null
                            ? Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                    Container(
                                      width: double.infinity,
                                      height: 300,
                                      child: CachedNetworkImage(
                                        imageUrl: widget.record["imgUrl"],
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topLeft,
                                        placeholder: (context, url) =>
                                            Container(
                                          alignment: Alignment.center,
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      padding: EdgeInsets.all(10),
                                      color: Colors.black.withOpacity(0.5),
                                      height: 60,
                                      child: Center(
                                        child: MemoPlayerWidget(
                                          url: widget.record['audio'],
                                        ),
                                      ),
                                    ),
                                  ])
                            : Container(),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  15, 10, 10, 15),
                              child: RoundedBackgroundText(
                                widget.record['text'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.record['text'].length > 80
                                        ? 20
                                        : 30),
                                backgroundColor: widget.record['color'] is int
                                    ? Color(widget.record['color'])
                                    : Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class MemoModalWidget extends StatefulWidget {
  final Map<String, dynamic> record;
  int index;
  final List<Map<String, dynamic>> records;
  MemoModalWidget({Key key, this.record, this.records, this.index})
      : super(key: key);

  @override
  _MemoModalWidgetState createState() => _MemoModalWidgetState();
}

class _MemoModalWidgetState extends State<MemoModalWidget> {
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    print("index: ${widget.index}");
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: BackButton(
              color: Colors.black,
            ),
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
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]),
        body: PageView(
          controller: controller,
          children: widget.records.map((document) {
            return Container(
              alignment: Alignment.topCenter,
              // color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SizedBox(
                    //   height: 30,
                    // ),
                    document["imgUrl"] != null
                        ? Container(
                            width: double.infinity,
                            // height: 300,
                            child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  CachedNetworkImage(
                                      imageUrl: document["imgUrl"],
                                      // width: 300, //double.infinity,
                                      // height: 300,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topLeft),
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.black.withOpacity(0.5),
                                    height: 60,
                                    child: Center(
                                      child: MemoPlayerWidget(
                                        url: document['audio'],
                                      ),
                                    ),
                                  ),
                                ]),
                          )
                        : Container(),
                    Container(
                      // padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(25, 10, 5, 30),
                        child: RoundedBackgroundText(
                          document['icon'] + " " + document['text'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  widget.record['text'].length > 250 ? 25 : 30),
                          backgroundColor: Color(document['color']),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

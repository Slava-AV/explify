import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../backend/api_requests/api_calls.dart';
import 'package:explify/auth/auth_util.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../analytics.dart';
import 'package:explify/components/star_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class ContextMenuSimplified extends StatefulWidget {
  final String text;
  final String type;
  final Map<String, dynamic> post;

  ContextMenuSimplified({
    this.text,
    this.type,
    this.post,
  });

  @override
  _ContextMenuSimplifiedState createState() => _ContextMenuSimplifiedState();
}

Future<void> showInformationDialog(BuildContext context, String generation,
    String sourceBlock, String type, String postId, String user) async {
  // _mixpanel.track("Flag dialog open");
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

class _ContextMenuSimplifiedState extends State<ContextMenuSimplified> {
  Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  Widget build(BuildContext context) {
    return Container(
      // height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 5),
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
          // InkWell(
          //     child: Padding(
          //       padding: const EdgeInsets.only(left: 16),
          //       child: Row(
          //         // mainAxisSize: MainAxisSize.max,
          //         children: [
          //           Icon(
          //             Icons.star,
          //             size: 16,
          //             color: Colors.deepOrange[400],
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
          //             child: Text(
          //               "Add to Learning Feed",
          //               style: FlutterFlowTheme.bodyText1.override(
          //                 fontFamily: 'Lato',
          //                 // fontWeight: FontWeight.w600,
          //                 color: Colors.black,
          //                 fontSize: 16,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     onTap: () async {
          //       _mixpanel.track("Item starred", properties: {
          //         "text": widget.text,
          //         "item_type": widget.type,
          //       });

          //       final ProgressDialog pr = ProgressDialog(context,
          //           type: ProgressDialogType.Normal,
          //           isDismissible: false,
          //           showLogs: true);
          //       pr.style(
          //           message: 'Preparing your memo...',
          //           borderRadius: 10.0,
          //           backgroundColor: Colors.white,
          //           progressWidget: CircularProgressIndicator(),
          //           elevation: 10.0,
          //           insetAnimCurve: Curves.easeInOut,
          //           progress: 0.0,
          //           maxProgress: 100.0,
          //           progressTextStyle: TextStyle(
          //               color: Colors.black,
          //               fontSize: 13.0,
          //               fontWeight: FontWeight.w400),
          //           messageTextStyle: TextStyle(
          //               color: Colors.black,
          //               fontSize: 19.0,
          //               fontWeight: FontWeight.w600));
          //       print("loading...");
          //       Navigator.pop(context);
          //       await pr.show();
          //       var memoData = await getDataForMemo(text: widget.text);
          //       print(memoData);
          //       await pr.hide();

          //       await showDialog(
          //         context: context,
          //         builder: (BuildContext dialogContex) {
          //           return StarDialogWidget(
          //               record: widget.post,
          //               text: widget.text,
          //               memoData: memoData);
          //         },
          //       );
          //     }),
          // Divider(),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                // mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.copy,
                    size: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                    child: Text(
                      "Copy text",
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        // fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              _mixpanel.track("Item copied", properties: {
                "text": widget.text,
                "item_type": widget.type,
              });
              Clipboard.setData(new ClipboardData(text: widget.text)).then((_) {
                Toast.show("Copied to clipboard", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
                Navigator.pop(context);
              });
            },
          ),
          Divider(),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                // mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                    child: Text(
                      "Report",
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        // fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              // _mixpanel.track("Copy item text");
              await showInformationDialog(
                  context,
                  widget.text,
                  widget.post["image_url"],
                  widget.type,
                  widget.post["pageId"],
                  currentUserReference.toString());
              Navigator.pop(context);
            },
          ),
          Divider(),
          SizedBox(height: 100)
        ],
      ),
    );
  }
}

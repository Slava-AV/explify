import '../flutter_flow/flutter_flow_animations.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toast/toast.dart';
import '../backend/api_requests/api_calls.dart';
import '../auth/auth_util.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';

const positions = ["BL", "BR", "TL", "TR"];

const List<IconData> positionIcons = [
  Icons.align_horizontal_left_outlined,
  Icons.align_horizontal_right_outlined,
  Icons.align_vertical_top_outlined,
  Icons.align_vertical_bottom_outlined
];

Color pickerColor = Colors.deepOrange;
Color currentColor = Colors.deepOrange;
List<dynamic> excludedVoices = [];

RandomColor _randomColor = RandomColor();

class StarDialogWidget extends StatefulWidget {
  final Map<String, dynamic> record;
  final Map<String, dynamic> memoData;
  String text;

  StarDialogWidget({Key key, this.record, this.text, this.memoData})
      : super(key: key);

  @override
  _StarDialogWidgetState createState() => _StarDialogWidgetState();
}

class _StarDialogWidgetState extends State<StarDialogWidget>
    with TickerProviderStateMixin {
  int captionPosition = 0;
  TextEditingController textController;
  TextEditingController contentController;
  FocusNode focusNode;
  bool _loadingButton = false;
  final animationsMap = {
    'gridViewOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 600,
      fadeIn: true,
    ),
  };
  Mixpanel _mixpanel;
  FirebaseAnalytics analytics;

  String selectedImageUrl = "";
  String selectedImageThumbnail = "";

  Future getVoices() async {
    var resp = await userVoicesList;
    // if a voice is in excludedVoices, make it inactive

    setState(() {
      excludedVoices = resp;
    });
  }

  @override
  void initState() {
    super.initState();
    startPageLoadAnimations(
      animationsMap.values
          .where((anim) => anim.trigger == AnimationTrigger.onPageLoad),
      this,
    );

    Future<void> _initMixpanel() async {
      _mixpanel = await MixpanelManager.init();
      analytics = Provider.of<FirebaseAnalytics>(context, listen: false);
      analytics.logEvent(name: "memo_dialog_opened");
    }

    textController =
        TextEditingController(text: widget.memoData["keywords"].split(",")[0]);
    contentController = TextEditingController(text: widget.text);
    focusNode = FocusNode();

    print(widget.memoData);
    getVoices();
    _initMixpanel();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> urls = widget.memoData["thumbnails"];
    List<dynamic> imagesRaw = widget.memoData["images"];
    //parse objects in the list
    List<Map<String, dynamic>> images =
        imagesRaw.map((el) => Map<String, dynamic>.from(el)).toList();
    return SafeArea(
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.backgroundColor,
        appBar: AppBar(
            backgroundColor: FlutterFlowTheme.backgroundColor,
            centerTitle: true,
            iconTheme: IconThemeData(
              color:
                  FlutterFlowTheme.primaryStrongColor, //change your color here
            ),
            automaticallyImplyLeading: true,
            title: Text(
              "New memo",
              style: FlutterFlowTheme.bodyText1.override(
                fontFamily: 'Lato',
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedImageUrl == "") {
                    Toast.show("Need to pick an image", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                    return;
                  }
                  createFavourite(
                    bookTitle: widget.record["bookTitle"],
                    pageTitle: widget.record["title"],
                    bookId: widget.record["bookId"],
                    pageId: widget.record["pageId"],
                    text: contentController.text,
                    sourceType: "bullet",
                    imgUrl: selectedImageUrl,
                    capPos: captionPosition,
                    capText: textController.text,
                    color: _randomColor.randomColor().value,
                    excludedVoices: excludedVoices,
                  );
                  Toast.show("Saving your memo...", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                  _mixpanel.track("memo_created");
                  analytics.logEvent(name: "memo_created");

                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
                  style: FlutterFlowTheme.bodyText1.override(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ]),
        body: Container(
          padding: EdgeInsets.only(top: 0, left: 15, right: 15),
          // height: MediaQuery.of(context).size.height * 3,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Editable text of the memo
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: EditableText(
                  controller: contentController,
                  focusNode: focusNode,
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.red,
                  style: FlutterFlowTheme.bodyText1.override(
                    fontFamily: 'Lato',
                    fontSize: 18,
                  ),
                  maxLines: 5,
                  cursorHeight: 0.3,
                  showSelectionHandles: true,
                  selectionColor: FlutterFlowTheme.secondaryColor,
                  scrollBehavior: ScrollBehavior(),
                ),
              ),
              //Caption
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pick an image:',
                      style: FlutterFlowTheme.subtitle2.override(
                        fontFamily: 'Quicksand',
                        color: Color(0xFF282828),
                      ),
                    ),
                    selectedImageUrl != ""
                        ? InkWell(
                            child: Text(
                              'Change',
                              style: FlutterFlowTheme.subtitle2.override(
                                fontFamily: 'Quicksand',
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedImageUrl = "";
                              });
                            },
                          )
                        : Container()
                  ],
                ),
              ),
              //picker or image
              selectedImageUrl == ""
                  ?
                  //picker
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 288,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                      ),
                      child: GridView(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          primary: false,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          children: images.map((img) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: InkWell(
                                child: Image.network(
                                  img["thumbnail"],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedImageUrl = img["image"];
                                    selectedImageThumbnail = img["thumbnail"];
                                  });
                                },
                              ),
                            );
                          }).toList()))
                  :
                  //image
                  Container(
                      width: double.infinity,
                      // height: 300,
                      child: Image.network(
                        selectedImageUrl,
                        width: double.infinity,
                        // height: 300,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          return Container(
                              child: Image.network(
                            selectedImageThumbnail,
                            width: double.infinity,
                            // height: 300,
                            fit: BoxFit.cover,
                          ));
                        },
                      ).animated(
                          [animationsMap['gridViewOnPageLoadAnimation']]),
                    ).animated([animationsMap['gridViewOnPageLoadAnimation']]),
              // SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

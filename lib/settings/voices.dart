import 'package:toast/toast.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:explify/backend/api_requests/api_calls.dart';
import '../auth/auth_util.dart';

class VoicesWidget extends StatefulWidget {
  VoicesWidget({Key key}) : super(key: key);

  @override
  _VoicesWidgetState createState() => _VoicesWidgetState();
}

class _VoicesWidgetState extends State<VoicesWidget> {
  bool _loadingButton = false;
  bool switchListTileValue1;
  bool switchListTileValue2;
  bool switchListTileValue3;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> my_voices = [
    {'icon': '🤴', 'name': 'Artur', 'id': 'qwe', 'active': true},
    {'icon': '🐲', 'name': 'Smaug', 'id': 'qwe', 'active': true},
    {'icon': '🐹', 'name': 'Jeronimo', 'id': 'qwe', 'active': true},
    {'icon': '💩', 'name': 'Mr poop', 'id': 'qwe', 'active': true},
    {'icon': '🕷', 'name': 'Nosk', 'id': 'qwe', 'active': true},
    {'icon': '🦝', 'name': 'Bosco', 'id': 'qwe', 'active': true},
    {'icon': '👹', 'name': 'Ahriman', 'id': 'qwe', 'active': true},
    {'icon': '🐨', 'name': 'Homer', 'id': 'qwe', 'active': true},
    {'icon': '👵', 'name': 'Sotofa', 'id': 'qwe', 'active': true},
    {'icon': '🧛‍♀️', 'name': 'Adreana', 'id': 'qwe', 'active': true},
    {'icon': '🧙‍♂️', 'name': 'Baltazar', 'id': 'qwe', 'active': true},
    {'icon': '🧟‍♂️', 'name': 'Zombie', 'id': 'qwe', 'active': true},
    {'icon': '👮‍♂️', 'name': 'Cheriff', 'id': 'qwe', 'active': true},
    {'icon': '🐸', 'name': 'Rango', 'id': 'qwe', 'active': true},
  ];

  @override
  void initState() {
    super.initState();
    getVoices();
  }

  Future getVoices() async {
    var excludedVoices = await userVoicesList;
    if (excludedVoices == null) {
      excludedVoices = [];
    }
    // if a voice is in excludedVoices, make it inactive

    setState(() {
      print(excludedVoices);
      for (var voice in my_voices) {
        if (excludedVoices.contains(voice['icon'])) {
          voice['active'] = false;
        }
      }
    });
  }

  int getActiveVoices() {
    int activeVoices = 0;
    for (var voice in my_voices) {
      if (voice['active']) {
        activeVoices++;
      }
    }
    return activeVoices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.appBar,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.grey[800],
            size: 24,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Voices',
          style: FlutterFlowTheme.bodyText1.override(
            fontFamily: 'Lexend Deca',
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      // backgroundColor: FlutterFlowTheme.primaryColor,
      backgroundColor: Color(0xFFf9f6ed),
      body: new SingleChildScrollView(
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 40),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        'Choose which characters wil be engaged in your memos.',
                        style: FlutterFlowTheme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: my_voices.map((voice) {
                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: SwitchListTile.adaptive(
                        value: voice["active"],
                        onChanged: (newValue) => setState(() {
                          if (getActiveVoices() < 4 && newValue == false) {
                            //show toast
                            Toast.show('Minimum 3 voices', context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.TOP);
                          } else
                            voice["active"] = newValue;

                          //save changes to DB
                          saveOptions(
                            userUid: currentUserUid,
                            email: currentUserEmail,
                            voices: //IDs of voices with active = false
                                my_voices
                                    .where((voice) => voice["active"] == false)
                                    .map((voice) => voice["icon"])
                                    .toList(),
                          );
                        }),
                        title: Text(
                          voice['icon'] + "  " + voice['name'],
                          style: FlutterFlowTheme.title3.override(
                            fontFamily: 'Lexend Deca',
                            color: Colors.grey[800],
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        // subtitle: Image.asset(
                        //   "assets/images/waves/wave_3.png",
                        //   height: 40,
                        // ),
                        activeColor: Colors.white,
                        activeTrackColor: FlutterFlowTheme.actionColor,
                        dense: false,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding:
                            EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

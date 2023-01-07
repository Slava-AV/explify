import '../backend/backend.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class EditProfilePageWidget extends StatefulWidget {
  EditProfilePageWidget({
    Key key,
    this.user,
  }) : super(key: key);

  final UsersRecord user;

  @override
  _EditProfilePageWidgetState createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  TextEditingController textController1;
  TextEditingController textController2;
  TextEditingController textController3;
  TextEditingController textController4;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController(text: widget.user.displayName);
    textController2 = TextEditingController(text: widget.user.username);
    textController3 = TextEditingController(text: widget.user.website);
    textController4 = TextEditingController(text: widget.user.bio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'Edit Profile',
                    style: FlutterFlowTheme.bodyText1.override(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final displayName = textController1.text;
                      final username = textController2.text;
                      final website = textController3.text;
                      final bio = textController4.text;

                      final usersRecordData = createUsersRecordData(
                        displayName: displayName,
                        username: username,
                        website: website,
                        bio: bio,
                      );

                      await widget.user.reference.update(usersRecordData);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Done',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        color: FlutterFlowTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: Color(0x55EEEEEE),
                ),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.network(
                widget.user.profilePicUrl,
              ),
            ),
            Align(
              alignment: Alignment(0, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'Change Profile Photo\n(coming soon)',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.bodyText1.override(
                    fontFamily: 'Lato',
                    color: FlutterFlowTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: Color(0x55EEEEEE),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Text(
                      'Name',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: textController1,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                          ),
                          style: FlutterFlowTheme.bodyText1.override(
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0x55EEEEEE),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Text(
                      'Username',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: textController2,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                          ),
                          style: FlutterFlowTheme.bodyText1.override(
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Color(0x55EEEEEE),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Text(
                      'Website',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: textController3,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                          ),
                          style: FlutterFlowTheme.bodyText1.override(
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Color(0x55EEEEEE),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Text(
                      'Bio',
                      style: FlutterFlowTheme.bodyText1.override(
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: textController4,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                          ),
                          style: FlutterFlowTheme.bodyText1.override(
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: Color(0x55EEEEEE),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 0, 0),
              child: Text(
                'Switch to Professional Account',
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: FlutterFlowTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: Color(0x55EEEEEE),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 0, 0),
              child: InkWell(
                onTap: () async {
                  await launchURL('https://twitter.com/flutter_flow');
                },
                child: Text(
                  'Tweet about how much you love FlutterFlow',
                  style: FlutterFlowTheme.bodyText1.override(
                    fontFamily: 'Lato',
                    color: FlutterFlowTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

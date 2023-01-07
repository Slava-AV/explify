import 'package:explify/feed_page/feed_books_widget.dart';
import 'package:flutter/material.dart';
import 'package:explify/flutter_flow/flutter_flow_theme.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:explify/feed_page/feed_favourits_widget.dart';
import 'package:explify/components/onboarding.dart';
import '../auth/auth_util.dart';
import 'package:explify/settings/voices.dart';
import 'package:explify/login_page/login_page_widget.dart';
import '../analytics.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Mixpanel _mixpanel;
int limit = 0;
Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
  limit = await pageLimit;
}

class drawer extends StatefulWidget {
  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  @override
  void initState() {
    super.initState();

    _initMixpanel();
  }

  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor:
            Color(0xFFf9f6ed), //This will change the drawer background to blue.
        //other styles
      ),
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.

        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.primaryColor,
              ),
              child: Column(children: [
                Image.asset(
                  'assets/images/tys_logo_nopadding.png',
                  height: 100,
                  width: 100,
                ),
                Text(
                  "Explify",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ]),
            ),
            ListTile(
              title: Text(
                "Credits: " + limit.toString(),
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () async {},
            ),
            ListTile(
              // leading: Icon(
              //   Icons.book,
              //   color: FlutterFlowTheme.actionColor,
              // ),
              leading: Text(
                "📖",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  fontSize: 20,
                ),
              ),
              title: Text(
                "My books",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedBooksWidget()),
                );
              },
            ),
            ListTile(
              // leading: Icon(
              //   Icons.star,
              //   color: Colors.deepOrange,
              // ),
              leading: Text(
                "🧠",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  fontSize: 20,
                ),
              ),
              title: Text(
                "Brain feed",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FeedFavouritsWidget()),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              // leading: Icon(Icons.settings_outlined),
              leading: Text(
                "🐲",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  fontSize: 20,
                ),
              ),
              title: Text(
                "Voices",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VoicesWidget()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                "Log out",
                style: FlutterFlowTheme.bodyText1.override(
                  fontFamily: 'Lato',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                _mixpanel.track("Logout");
                await DefaultCacheManager().emptyCache();
                logOut();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPageWidget(),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

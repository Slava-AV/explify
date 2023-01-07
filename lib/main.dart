import 'package:explify/components/paywall_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/firebase_user_provider.dart';
import 'package:explify/login_page/login_page_widget.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'feed_page/feed_books_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'payment/payment_api.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:explify/components/onboarding.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SentryFlutter.init(
    (options) => options.dsn =
        'xxxxxxxxxxxxxxxxxxxxxxx',
    appRunner: () => runApp(MyApp()),
  );
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<TeachYourSelfFirebaseUser> userStream;
  TeachYourSelfFirebaseUser initialUser;
  bool postCreated = false;
  var lastPost;
  Mixpanel _mixpanel;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();
    userStream = teachYourSelfFirebaseUserStream()
      ..listen((user) => initialUser ?? setState(() => initialUser = user));
    PaymentApi.init();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<FirebaseAnalytics>.value(value: analytics),
          Provider<FirebaseAnalyticsObserver>.value(value: observer),
        ],
        child: MaterialApp(
          title: 'Explify',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFdddbc7)),
          home: initialUser == null
              // home: null == null
              ? Material(
                  child: Container(
                      color: Color(0xFFdddbc7),
                      child: Center(
                        child:
                            Image.asset(
                          'assets/images/logo_animation.gif',
                          height: 250,
                          width: 250,
                        ),
                      )),
                )
              : currentUser.loggedIn
                  ? NavBarPage()
                  // : LoginPageWidget(),
                  : OnBoardingPage(),
        ));
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({Key key, this.initialPage}) : super(key: key);

  final String initialPage;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPage = 'FeedPage';

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? _currentPage;
  }

  Future fetchOffers() async {
    final offerings = await PaymentApi.fetchOffers();

    if (offerings.isEmpty) {
      print("No offers found");
    } else {
      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return PaywallWidget(
                packages: packages,
                title: "Upgrade Your Plan",
                description: "Upgrade to the paid plan to add more pages",
                onClickedPackage: (package) async {
                  await PaymentApi.purchasePackage(package);
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'FeedPage': FeedBooksWidget(),
      'OnBoardingPage': OnBoardingPage(),
    };
    return Scaffold(
      body: tabs[_currentPage],

    );
  }
}

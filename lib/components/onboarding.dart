import 'package:explify/feed_page/feed_books_widget.dart';
import 'package:explify/login_page/login_page_widget.dart';
import 'package:explify/flutter_flow/flutter_flow_theme.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  Mixpanel _mixpanel;
  FirebaseAnalytics analytics;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    analytics = Provider.of<FirebaseAnalytics>(context, listen: false);
    analytics.logTutorialBegin();
  }

  void _onIntroEnd(context) async {
    _mixpanel.track("Complete onboarding");
    analytics.logTutorialComplete();
    Navigator.of(context).push(
      // MaterialPageRoute(builder: (_) => FeedBooksWidget()),
      MaterialPageRoute(builder: (_) => LoginPageWidget()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: FlutterFlowTheme.primaryColor,
      imagePadding: EdgeInsets.only(top: 50),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: FlutterFlowTheme.primaryColor,
      isTopSafeArea: true,
      pages: [
        PageViewModel(
          title: "Under the hood",
          body:
              "Explify is powered by GPT-3, advanced neural network trained on hundreds of billions of words.",
          image: _buildImage('images/onboard0.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "1. Add a page you study",
          body:
              "Scan a page with camera or add from gallery. Explify works best with theory books in English.",
          image: _buildImage('images/onboard3.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "2. Create memos",
          body:
              "Explify generates short points for your page. Press star on any of them to create a memo.\n\nSelect one of the suggested pictures to create a strong association.",
          image: _buildImage('images/onboard2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "3. Listen and review memos",
          body:
              "Explify will voice your memos with distinct voices, like Dragon, Wizard or Mr. Poop. \n\nListning to it will light up your brain neurons and will help you remember it even better.",
          image: _buildImage('images/onboard4.png'),
          decoration: pageDecoration,
        ),

      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          )),
      // doneColor: FlutterFlowTheme.actionColor,
      doneColor: Colors.grey.shade700,
      nextColor: Colors.grey.shade700,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey.shade700,
        activeColor: FlutterFlowTheme.secondaryColor,
        activeSize: Size(10.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xFFCFCCAD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

import 'package:explify/flutter_flow/flutter_flow_theme.dart';
import 'package:explify/payment/payment_api.dart';

import '../auth/auth_util.dart';
import '../add_new_entry/new_entry_progress.dart';
import '../add_new_entry/new_entry_bulk.dart';
import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:toast/toast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:developer';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import './paywall_widget.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../backend/api_requests/api_calls.dart';


class fabWidget extends StatefulWidget {
  @override
  State<fabWidget> createState() => _fabWidgetState();
}

class _fabWidgetState extends State<fabWidget> {
  var isDialOpen = ValueNotifier<bool>(false);

  int limit = 0;

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
  }

  Future<void> _sendAnalyticsEvent() async {
    FirebaseAnalytics analytics =
        Provider.of<FirebaseAnalytics>(context, listen: false);
    await analytics
        .logEvent(name: 'Add_new_page', parameters: {'limit': limit});
    // await analytics.logSignUp(
    //   signUpMethod: 'email',
    // );
  }

  Future fetchOffers() async {
    final offerings = await PaymentApi.fetchOffers();

    if (offerings.isEmpty) {
      print("No offers found");
    } else {
      // final offer = offerings.first;
      // print('Offer: $offer');
      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return PaywallWidget(
                packages: packages,
                title: "Subscription",
                description: "Activate subscription to add new pages",
                onClickedPackage: (package) async {
                  // log("Purchasing package");
                  PurchaserInfo purchaserInfo =
                      await PaymentApi.purchasePackage(package);
                  if (purchaserInfo != null &&
                      purchaserInfo.entitlements != null &&
                      purchaserInfo.entitlements.all["unlimited"] != null &&
                      purchaserInfo.entitlements.all["unlimited"].isActive) {
                    _mixpanel.track("Payment completed");
                    Navigator.pop(context);
                    Toast.show("⭐ Now you can add pages!", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                  } else {
                    _mixpanel.track("Payment cancelled");
                    Navigator.pop(context);
                  }
                });
          });
    }
  }

  void fabClick(source) async {
    _mixpanel.track("FAB pressed - " + source);
    processImageCall(
          imageUrl: "",
          pageUID: "Preflight call",
          user: currentUserEmail,
          userUid: "",
          accessType: "",
          limit: 0,
          base64Img: "",
        );

    var next;

    PurchaserInfo purchaserInfo = await PaymentApi.getPurchaserInfo();
    if (purchaserInfo != null &&
        purchaserInfo.entitlements.all["unlimited"] != null &&
        purchaserInfo.entitlements.all["unlimited"].isActive == true) {
      if (source == "camera")
        next = NewEntryProgressWidget(
            uploadFrom: 0, accessType: "unlimited", limit: limit);
      else if (source == "gallery")
        next = NewEntryProgressWidget(
            uploadFrom: 1, accessType: "unlimited", limit: limit);
      else if (source == "bulk")
        next = NewEntryBulkWidget(
            uploadFrom: 0, accessType: "unlimited", limit: limit);

      await _sendAnalyticsEvent();

      await analytics.logEvent(
          name: 'Add_new_page', parameters: {'source': source, 'limit': limit});

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => next),
      );
    } else {
      //show paywall
      limit = await pageLimit;
      log("Limit: $limit");
      if (limit != null && limit > 0) {
        Toast.show("Remaining $limit pages", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        if (source == "camera")
          next = NewEntryProgressWidget(
              uploadFrom: 0, accessType: "limited", limit: limit);
        else if (source == "gallery")
          next = NewEntryProgressWidget(
              uploadFrom: 1, accessType: "limited", limit: limit);
        else if (source == "bulk")
          next = NewEntryBulkWidget(
              uploadFrom: 0, accessType: "limited", limit: limit);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => next,
          ),
        );
      } else {
        _mixpanel.track("You need a subscription - seen");

        fetchOffers();

      }
    }
  }

  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      openCloseDial: isDialOpen,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      dialRoot: (ctx, open, toggleChildren) {
        return SizedBox(
          width: 64,
          height: 64,
          child: OutlineGradientButton(
            child: Container(
              transform: Matrix4.translationValues(-3, -3, 0.0),
              child:
                  Icon(Icons.add_rounded, size: 40, color: Color(0xFF00ae95)),
            ),
            gradient: LinearGradient(colors: [
              FlutterFlowTheme.actionColor,
              FlutterFlowTheme.secondaryColor,
              Colors.orange[200],
              Colors.orange,
              Colors.deepOrange[400],
            ]),
            strokeWidth: 5,
            // backgroundColor: Color(0xFFdddbc7),
            backgroundColor: Color(0xFFf9f6ed),

            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            radius: Radius.circular(108),
            onTap: toggleChildren,
          ),
        );
      },
      buttonSize: 56, // it's the SpeedDial size which defaults to 56 itself
      // iconTheme: IconThemeData(size: 22),
      label: null, // The label of the main button.
      /// The active label of the main button, Defaults to label if not specified.
      activeLabel: null,

      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the SpeedDial childrens size
      childrenButtonSize: 64.0,
      visible: true,
      direction: SpeedDialDirection.up,
      switchLabelPosition: false,

      /// If true user is forced to close dial manually
      closeManually: false,

      /// If false, backgroundOverlay will not be rendered.
      renderOverlay: false,
      // overlayColor: Colors.black,
      // overlayOpacity: 0.5,
      onOpen: () => debugPrint('OPENING DIAL'),
      onClose: () => debugPrint('DIAL CLOSED'),
      useRotationAnimation: false,
      tooltip: 'Open Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      // foregroundColor: Colors.black,
      // backgroundColor: Colors.white,
      // activeForegroundColor: Colors.red,
      // activeBackgroundColor: Colors.blue,
      elevation: 8.0,
      isOpenOnStart: false,
      animationSpeed: 200,
      shape: const RoundedRectangleBorder(),
      childMargin: EdgeInsets.fromLTRB(15, 0, 0, 0),
      children: [
        // SpeedDialChild(
        //   child: const Icon(Icons.collections),
        //   backgroundColor: Colors.deepOrange,
        //   foregroundColor: Colors.white,
        //   // label: 'First',
        //   onTap: () => fabClick("bulk"),
        // ),
        SpeedDialChild(
          child: const Icon(Icons.image),
          backgroundColor: Color(0xFFfdbd4b),
          foregroundColor: Colors.white,
          label: 'Import from Gallery',
          onTap: () => fabClick("gallery"),
        ),
        SpeedDialChild(
          child: const Icon(Icons.photo_camera),
          backgroundColor: Color(0xFF00ae95),
          foregroundColor: Colors.white,
          label: 'Scan a page with Camera',
          visible: true,
          onTap: () => fabClick("camera"),
        ),
      ],
    );
  }
}

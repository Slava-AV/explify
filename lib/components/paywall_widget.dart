// import 'package:explify/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:explify/flutter_flow/flutter_flow_widgets.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<Package> packages;
  final ValueChanged<Package> onClickedPackage;

  PaywallWidget({
    this.title,
    this.description,
    this.packages,
    this.onClickedPackage,
  });

  @override
  _PaywallWidgetState createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    const String iosComment =
        "A purchase will be applied to your iTunes account on confirmation. Subscription will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. You will keep access to all the content you create after cancelling the subscription. Please refer to our ";
    const String androidComment =
        "A purchase will be applied to your Google Play account on confirmation. Subscription will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your Google Play account settings. You will keep access to all the content you create after cancelling the subscription.  Please refer to our ";

    return Container(
      // constraints:
      // BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),

      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 30, 16, 30),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              buildPackages(),
              const SizedBox(
                height: 20,
              ),
              FFButtonWidget(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  widget.onClickedPackage(widget.packages[0]);
                },
                text: isLoading ? '' : 'Activate',
                icon: isLoading
                    ? SizedBox(
                        width: 36,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballScale,
                          color: Colors.white,
                        ),
                      )
                    : null,
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60,
                  color: FlutterFlowTheme.actionColor,
                  textStyle: FlutterFlowTheme.subtitle2.override(
                      fontFamily: 'Roboto', color: Colors.white, fontSize: 22),
                  // borderSide: BorderSide(
                  //   // color: Color(0xFF9E9E9F),
                  //   width: 0,
                  // ),
                  borderRadius: 5,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    // Text(
                    //   isIOS ? iosComment : androidComment,
                    //   textAlign: TextAlign.justify,
                    //   style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    // ),
                    RichText(
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                            text: isIOS ? iosComment : androidComment,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[400]),
                          ),
                          new TextSpan(
                            text: 'Privacy Policy',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                launch('https://explify.app/privacy');
                              },
                          ),
                          isIOS
                              ? new TextSpan(
                                  text: " and ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[400]),
                                )
                              : new TextSpan(),
                          isIOS
                              ? new TextSpan(
                                  text: 'Terms & Conditions.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                                    },
                                )
                              : new TextSpan(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPackages() => ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: widget.packages.length,
      itemBuilder: (context, index) {
        final package = widget.packages[index];
        return buildPackage(context, package);
      });

  Widget buildPackage(BuildContext context, Package package) {
    final product = package.product;

    return Card(
      // color: Colors.amber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData.light(),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          title: Text(product.title),
          subtitle: Text(product.description),
          trailing: Text(
            product.priceString,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          enabled: true,
          // onTap: () => widget.onClickedPackage(package),
        ),
      ),
    );
  }
}

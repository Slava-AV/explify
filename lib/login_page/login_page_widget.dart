import 'package:explify/backend/api_requests/api_calls.dart';
import 'package:explify/feed_page/feed_books_widget.dart';

import 'package:toast/toast.dart';

import '../auth/auth_util.dart';
import '../flutter_flow/flutter_flow_theme.dart';
// import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../main.dart';
import 'package:flutter/material.dart';
// import 'package:outline_gradient_button/outline_gradient_button.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../payment/payment_api.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// import 'package:flutter_svg/flutter_svg.dart';

class LoginPageWidget extends StatefulWidget {
  LoginPageWidget({Key key}) : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  TextEditingController emailAddressController1;
  TextEditingController passwordController1;
  bool passwordVisibility1;
  TextEditingController emailAddressController2;
  TextEditingController passwordController2;
  TextEditingController promoCodeController;
  bool passwordVisibility2;
  TextEditingController passwordConfirmController;
  bool passwordConfirmVisibility;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading;
  bool promoFieldVisible;
  Mixpanel _mixpanel;

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  @override
  void initState() {
    super.initState();
    emailAddressController1 = TextEditingController();
    passwordController1 = TextEditingController();
    passwordVisibility1 = false;
    emailAddressController2 = TextEditingController();
    passwordController2 = TextEditingController();
    passwordVisibility2 = false;
    passwordConfirmController = TextEditingController();
    promoCodeController = TextEditingController();
    passwordConfirmVisibility = false;
    isLoading = false;
    promoFieldVisible = false;

    _initMixpanel();
  }

  Future<void> showAfterSinupInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ You got some credits!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '5 demo credits will be added to your account.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'After demo credits are over you can activate a subscription.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1 credit = 1 page.'),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 16,
                // ),
                // Container(
                //   padding: EdgeInsets.all(10),
                //   // color: Colors.blue[50],
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           InkWell(
                //               child: Text(
                //                 'I have a promo code',
                //                 style: TextStyle(
                //                   color: Colors.blue,
                //                 ),
                //               ),
                //               onTap: () async {
                //                 setState(() {
                //                   promoFieldVisible = true;
                //                 });
                //                 await showAfterSinupInfo();
                //                 Navigator.of(context).pop();
                //               }),
                //           Visibility(
                //               visible: promoFieldVisible,
                //               child: Column(children: [
                //                 SizedBox(
                //                   height: 1,
                //                 ),
                //                 TextField(
                //                   autofocus: true,
                //                   controller: promoCodeController,
                //                 ),
                //               ]))
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.primaryColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1,
                decoration: BoxDecoration(
                  color: Color(0xFFDDDBC7),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      MediaQuery.of(context).viewInsets.bottom == 0
                          ? Container(
                              // duration: Duration(milliseconds: 500),
                              height:
                                  MediaQuery.of(context).viewInsets.bottom == 0
                                      ? 250
                                      : 0,
                              child: Column(
                                children: [
                                  Text(
                                    'Explify',
                                    style: FlutterFlowTheme.bodyText1.override(
                                      fontFamily: 'Open Sans',
                                      color: Color(0xFF6F7173),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/tys_logo_nopadding.png',
                                          height: 120,
                                          fit: BoxFit.contain,
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Just learn it!',
                                    style: FlutterFlowTheme.bodyText1.override(
                                      fontFamily: 'Open Sans',
                                      color: Color(0xFF6F7173),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              child: Image.asset(
                              'assets/images/tys_logo_nopadding.png',
                              height: 80,
                              fit: BoxFit.contain,
                            )),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: DefaultTabController(
                            length: 2,
                            initialIndex: 1,
                            child: Column(
                              children: [
                                TabBar(
                                  labelColor: Color(0xFF6F7173),
                                  indicatorColor: Color(0xFF6F7173),
                                  tabs: [
                                    Tab(
                                      text: 'Sign In',
                                    ),
                                    Tab(
                                      text: 'Sign up',
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 20, 0, 0),
                                              child: TextFormField(
                                                controller:
                                                    emailAddressController1,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Email Address',
                                                  labelStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  // hintText:
                                                  //     'Enter your email...',
                                                  hintStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xFFC6C5B3),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 24, 20, 24),
                                                ),
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: FlutterFlowTheme
                                                      .tertiaryColor,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 12, 0, 0),
                                              child: TextFormField(
                                                controller: passwordController1,
                                                obscureText:
                                                    !passwordVisibility1,
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  // hintText:
                                                  //     'Enter your password...',
                                                  hintStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xFFC6C5B3),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 24, 20, 24),
                                                  suffixIcon: InkWell(
                                                    onTap: () => setState(
                                                      () => passwordVisibility1 =
                                                          !passwordVisibility1,
                                                    ),
                                                    child: Icon(
                                                      passwordVisibility1
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      color: Color(0xFF6F7173),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  24,
                                                  0,
                                                  MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom +
                                                      24),
                                              child:
                                                  //  OutlineGradientButton(
                                                  //   child: Text('Login',
                                                  //       style: TextStyle(
                                                  //           color:
                                                  //               Color(0xFF6F7173),
                                                  //           fontSize: 18,
                                                  //           fontWeight:
                                                  //               FontWeight.w600)),
                                                  //   gradient:
                                                  //       LinearGradient(colors: [
                                                  //     Color(0xFFea4097),
                                                  //     Color(0xFF00ae95),
                                                  //     Color(0xFFfdbd4b),
                                                  //   ]),
                                                  //   strokeWidth: 3,
                                                  //   backgroundColor:
                                                  //       Color(0xFFD6D4BC),
                                                  //   padding: EdgeInsets.symmetric(
                                                  //       horizontal: 100,
                                                  //       vertical: 22),
                                                  //   radius: Radius.circular(8),
                                                  // ),

                                                  isLoading
                                                      ? Container(
                                                          width: 230,
                                                          height: 60,
                                                          child: Center(
                                                              child: SizedBox(
                                                            height: 32,
                                                            child:
                                                                LoadingIndicator(
                                                              indicatorType:
                                                                  Indicator
                                                                      .ballBeat,
                                                              color: Color(
                                                                  0xFFB0AF9F),
                                                            ),
                                                          )),
                                                        )
                                                      : FFButtonWidget(
                                                          onPressed: () async {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();

                                                            setState(() {
                                                              isLoading = true;
                                                            });

                                                            final user =
                                                                await signInWithEmail(
                                                              context,
                                                              emailAddressController1
                                                                  .text,
                                                              passwordController1
                                                                  .text,
                                                            );

                                                            if (user == null) {
                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                              return;
                                                            }

                                                            //Set identity in Mixpanel
                                                            _mixpanel.identify(
                                                                user.uid);
                                                            _mixpanel
                                                                .getPeople()
                                                                .set("\$email",
                                                                    user.email);
                                                            _mixpanel
                                                                .getPeople()
                                                                .set("uid",
                                                                    user.uid);
                                                            _mixpanel
                                                                .getPeople()
                                                                .set(
                                                                    "\$first_name",
                                                                    user.uid);

                                                            await PaymentApi
                                                                .login(
                                                                    user.uid);
                                                            await Navigator
                                                                .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    NavBarPage(
                                                                        initialPage:
                                                                            'FeedPage'),
                                                              ),
                                                              (r) => false,
                                                            );
                                                          },
                                                          text: 'Login',
                                                          options:
                                                              FFButtonOptions(
                                                            width: 230,
                                                            height: 60,
                                                            color:
                                                                FlutterFlowTheme
                                                                    .actionColor,
                                                            textStyle: FlutterFlowTheme
                                                                .subtitle2
                                                                .override(
                                                                    fontFamily:
                                                                        'Quicksand',
                                                                    color: Colors
                                                                        .white),
                                                            elevation: 3,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1,
                                                            ),
                                                            borderRadius: 8,
                                                          ),
                                                        ),
                                            ),
                                            // Padding(
                                            //   padding: EdgeInsets.fromLTRB(
                                            //       0, 30, 0, 0),
                                            //   child: FFButtonWidget(
                                            //     onPressed: () {
                                            //       print(
                                            //           'Button-ForgotPassword pressed ...');
                                            //     },
                                            //     text: 'Forgot Password?',
                                            //     options: FFButtonOptions(
                                            //       width: 170,
                                            //       height: 40,
                                            //       color: Color(0x003474E0),
                                            //       textStyle: FlutterFlowTheme
                                            //           .subtitle2
                                            //           .override(
                                            //         fontFamily: 'Quicksand',
                                            //         color: Color(0xFF6F7173),
                                            //       ),
                                            //       elevation: 0,
                                            //       borderSide: BorderSide(
                                            //         color: Colors.transparent,
                                            //         width: 1,
                                            //       ),
                                            //       borderRadius: 8,
                                            //     ),
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: EdgeInsets.fromLTRB(
                                            //       20, 0, 20, 0),
                                            //   child: Row(
                                            //     mainAxisSize: MainAxisSize.max,
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.center,
                                            //     children: [
                                            //       Padding(
                                            //         padding:
                                            //             EdgeInsets.fromLTRB(
                                            //                 0, 12, 0, 0),
                                            //         child: Text(
                                            //           'Or log in with Google',
                                            //           style: FlutterFlowTheme
                                            //               .bodyText1
                                            //               .override(
                                            //             fontFamily: 'Lato',
                                            //             color:
                                            //                 Color(0xFF6F7173),
                                            //           ),
                                            //         ),
                                            //       )
                                            //     ],
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: EdgeInsets.fromLTRB(
                                            //       20, 16, 20, 0),
                                            //   child: Row(
                                            //     mainAxisSize: MainAxisSize.max,
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.center,
                                            //     children: [
                                            //       InkWell(
                                            //         onTap: () async {
                                            //           final user =
                                            //               await signInWithGoogle(
                                            //                   context);
                                            //           if (user == null) {
                                            //             return;
                                            //           }
                                            //           await Navigator
                                            //               .pushAndRemoveUntil(
                                            //             context,
                                            //             MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   NavBarPage(
                                            //                       initialPage:
                                            //                           'FeedPage'),
                                            //             ),
                                            //             (r) => false,
                                            //           );
                                            //         },
                                            //         child: Card(
                                            //           clipBehavior: Clip
                                            //               .antiAliasWithSaveLayer,
                                            //           color: Color(0xFFB0AF9F),
                                            //           shape:
                                            //               RoundedRectangleBorder(
                                            //             borderRadius:
                                            //                 BorderRadius
                                            //                     .circular(50),
                                            //           ),
                                            //           child: Padding(
                                            //             padding:
                                            //                 EdgeInsets.fromLTRB(
                                            //                     2, 2, 2, 2),
                                            //             child: InkWell(
                                            //               onTap: () async {
                                            //                 final user =
                                            //                     await signInWithGoogle(
                                            //                         context);
                                            //                 if (user == null) {
                                            //                   return;
                                            //                 }
                                            //                 await Navigator
                                            //                     .pushAndRemoveUntil(
                                            //                   context,
                                            //                   MaterialPageRoute(
                                            //                     builder: (context) =>
                                            //                         NavBarPage(
                                            //                             initialPage:
                                            //                                 'FeedPage'),
                                            //                   ),
                                            //                   (r) => false,
                                            //                 );
                                            //               },
                                            //               child: Container(
                                            //                 width: 50,
                                            //                 height: 50,
                                            //                 clipBehavior:
                                            //                     Clip.antiAlias,
                                            //                 decoration:
                                            //                     BoxDecoration(
                                            //                   shape: BoxShape
                                            //                       .circle,
                                            //                 ),
                                            //                 child: Image.asset(
                                            //                   'assets/images/social_GoogleWhite.svg',
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       )
                                            //     ],
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 20, 0, 0),
                                              child: TextFormField(
                                                controller:
                                                    emailAddressController2,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Email Address',
                                                  labelStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  // hintText:
                                                  //     'Enter your email...',
                                                  hintStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xFFC6C5B3),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 24, 20, 24),
                                                ),
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 12, 0, 0),
                                              child: TextFormField(
                                                controller: passwordController2,
                                                obscureText:
                                                    !passwordVisibility2,
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  // hintText:
                                                  //     'Enter your password...',
                                                  hintStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xFFC6C5B3),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 24, 20, 24),
                                                  suffixIcon: InkWell(
                                                    onTap: () => setState(
                                                      () => passwordVisibility2 =
                                                          !passwordVisibility2,
                                                    ),
                                                    child: Icon(
                                                      passwordVisibility2
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      color: Color(0xFF6F7173),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 12, 0, 0),
                                              child: TextFormField(
                                                controller:
                                                    passwordConfirmController,
                                                obscureText:
                                                    !passwordConfirmVisibility,
                                                decoration: InputDecoration(
                                                  labelText: 'Confirm Password',
                                                  labelStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  // hintText:
                                                  //     'Enter your password...',
                                                  hintStyle: FlutterFlowTheme
                                                      .bodyText1
                                                      .override(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xFF6F7173),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xFFC6C5B3),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 24, 20, 24),
                                                  suffixIcon: InkWell(
                                                    onTap: () => setState(
                                                      () => passwordConfirmVisibility =
                                                          !passwordConfirmVisibility,
                                                    ),
                                                    child: Icon(
                                                      passwordConfirmVisibility
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      color: Color(0xFF6F7173),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  24,
                                                  0,
                                                  MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom +
                                                      24),
                                              child: isLoading
                                                  ? Container(
                                                      width: 230,
                                                      height: 60,
                                                      child: Center(
                                                          child: SizedBox(
                                                        height: 32,
                                                        child: LoadingIndicator(
                                                          indicatorType:
                                                              Indicator
                                                                  .ballBeat,
                                                          color:
                                                              Color(0xFFB0AF9F),
                                                        ),
                                                      )),
                                                    )
                                                  : FFButtonWidget(
                                                      onPressed: () async {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        setState(() {
                                                          isLoading = true;
                                                        });

                                                        final user =
                                                            await createAccountWithEmail(
                                                          context,
                                                          emailAddressController2
                                                              .text,
                                                          passwordController2
                                                              .text,
                                                        );
                                                        if (user == null) {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                          return;
                                                        }
                                                        await showAfterSinupInfo();
                                                        //call new user api
                                                        final res =
                                                            await addCredits(
                                                          userUid: user.uid,
                                                          email: user.email,
                                                          promoCode:
                                                              promoCodeController
                                                                  .text,
                                                        ) as Map<String,
                                                                dynamic>;
                                                        print("response: $res");

                                                        // await PaymentApi.init();
                                                        await PaymentApi.login(
                                                            user.uid);
                                                        setState(() {
                                                          isLoading = false;
                                                        });

                                                        //Set identity in Mixpanel
                                                        _mixpanel
                                                            .identify(user.uid);
                                                        _mixpanel
                                                            .getPeople()
                                                            .set("\$email",
                                                                user.email);
                                                        _mixpanel
                                                            .getPeople()
                                                            .set("uid",
                                                                user.uid);
                                                        _mixpanel
                                                            .getPeople()
                                                            .set("\$first_name",
                                                                user.uid);
                                                        if (res != null) {
                                                          Toast.show(
                                                              "⭐ " +
                                                                  res["credits"]
                                                                      .toString() +
                                                                  " credits added",
                                                              context,
                                                              duration: Toast
                                                                  .LENGTH_LONG,
                                                              gravity:
                                                                  Toast.TOP);
                                                          if (res["credits"] >
                                                              10)
                                                            _mixpanel.track(
                                                                "Promo-code activeted",
                                                                properties: {
                                                                  "promocode":
                                                                      promoCodeController
                                                                          .text
                                                                });
                                                        }

                                                        await Navigator
                                                            .pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  FeedBooksWidget()),
                                                          (r) => false,
                                                        );
                                                      },
                                                      text: 'Create Account',
                                                      options: FFButtonOptions(
                                                        width: 230,
                                                        height: 60,
                                                        color: FlutterFlowTheme
                                                            .actionColor,
                                                        textStyle:
                                                            FlutterFlowTheme
                                                                .subtitle2
                                                                .override(
                                                          fontFamily:
                                                              'Quicksand',
                                                          color: Colors.white,
                                                        ),
                                                        elevation: 3,
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 1,
                                                        ),
                                                        borderRadius: 8,
                                                      ),
                                                    ),
                                            ),
                                            Text(
                                                "You will get 5 free credits after registration",
                                                style: FlutterFlowTheme
                                                    .bodyText1
                                                    .override(
                                                  fontFamily: 'Lato',
                                                  color: Color(0xFF6F7173),
                                                ))
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
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

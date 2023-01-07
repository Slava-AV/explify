// import 'package:explify/auth/firebase_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:explify/auth/auth_util.dart';

class PaymentApi {
  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    print("currentUserUid");
    print(currentUserUid);
    if (currentUserUid != '')
      await Purchases.setup(_apiKey, appUserId: currentUserUid);
    else
      await Purchases.setup(_apiKey);
    // await Purchases.setup(_apiKey);
    // final limit = currentUser.user.pageLimit;
    // print("Current user: $limit");
  }
  static Future login(uid) async {
    await Purchases.setDebugLogsEnabled(true);
     LogInResult result = await Purchases.logIn(uid);
     print(result);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      print(e);
      return [];
    }
  }

  static Future<PurchaserInfo> getPurchaserInfo() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo);
      return purchaserInfo;
    } on PlatformException catch (e) {
      // Error fetching purchaser info
      print(e);
      return null;
    }
  }

  static Future<PurchaserInfo> purchasePackage(Package package) async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      return purchaserInfo;
    } catch (err) {
      print(err);
      return null;
    }
  }
}

import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelManager {

  static Mixpanel _instance;

  static Future<Mixpanel> init() async {
    if (_instance == null) {
      _instance = await Mixpanel.init("xxxxxxxxxxxxxxxxxx",
          optOutTrackingDefault: false);
    }
    return _instance;
  }

}
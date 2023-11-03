import 'package:adit_lin_plugin_example/linphone_initial_setup/call_module.dart';

class LinePhoneCallManager {
  LinePhoneCallManager._privateConstructor();

  static final LinePhoneCallManager _instance =
      LinePhoneCallManager._privateConstructor();

  factory LinePhoneCallManager() {
    return _instance;
  }

  static CallModule callModule = CallModule.instance;
}

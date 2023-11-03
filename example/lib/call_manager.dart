import 'package:adit_lin_plugin_example/linphone_initial_setup/call_module.dart';

class CallManager {
  CallManager._privateConstructor();

  static final CallManager _instance = CallManager._privateConstructor();

  factory CallManager() {
    return _instance;
  }

  static CallModule callModule = CallModule.instance;

//TLS- 65081
//TCP- 65082
//UDP- 65080

// "wss://wrtcbeta1.adit.com:65089/ws";       "@wrtcbeta1.adit.com"
// "wss://wrtc1.adit.com:65089/ws";           "@wrtc1.adit.com"

}

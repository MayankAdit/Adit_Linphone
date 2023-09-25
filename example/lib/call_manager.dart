import 'package:adit_lin_plugin/adit_demo_callbck.dart';
import 'package:adit_lin_plugin/adit_lin_plugin.dart';
import 'package:adit_lin_plugin_example/call_data_model.dart';

class CallManager {
  CallManager._privateConstructor();

  static final CallManager _instance = CallManager._privateConstructor();

  factory CallManager() {
    return _instance;
  }

  Map<String, dynamic>? callData;
  AditLinPlugin? aditLinPlugin;
  AditDemoCallBack demoCallBack = AditDemoCallBack();
  bool isBackToBackground = false;
  CallDataModel? call;

  //TLS- 65081
  //TCP- 65082
  //UDP- 65080

  // "wss://wrtcbeta1.adit.com:65089/ws";       "@wrtcbeta1.adit.com"
  // "wss://wrtc1.adit.com:65089/ws";           "@wrtc1.adit.com"

  //PBX sip userID>>> 101-TelynxPlivoDurby
  //PBX sip password>>> 4nWqKPAYprFCv74X
  //3463471545

  //001-OwnerVMobile
  //EQ6qUCRGLrb7dNZS   8324765379

  connectCall(String connectType, String phone) async {
    // callData = {
    //   'username': '003-003MayasnkMangukiya9622',
    //   'passwd': '6L7m7LVBtV5GLNGD',
    //   'domain': 'pjsipbeta2.adit.com:65080',
    //   'sipExtention': '@pjsipbeta2.adit.com',
    //   'transportType': 'UDP',
    //   'methodType': connectType,
    //   'phone': phone,
    // };
    callData = {
      'transportType': 'TCP',
      'methodType': connectType,
      'phone': "3463471545",
      'username': '101-TelynxPlivoDurby',
      'passwd': '4nWqKPAYprFCv74X',
      'domain': 'pjsip1.adit.com:65082',
      'sipExtention':'@pjsip1.adit.com' 
    };
    aditLinPlugin = AditLinPlugin(connectType, callData);
  }
}

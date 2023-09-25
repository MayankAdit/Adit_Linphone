import 'package:flutter/services.dart';

class AditDemoCallBack {
  MethodChannel? callBackChannel;
  Function? onTap;

  AditDemoCallBack() {
    callBackChannel = const MethodChannel('aditcallback');
    //_channel.setMethodCallHandler(_handleMethod);
  }

  // Future<dynamic> _handleMethod(MethodCall call) async {
  //    switch (call.method) {
  //     case AppTexts.loginChannel:
  //       debugPrint("Incoming call 1");
  //       break;
  //     case AppTexts.incomingChannel:
  //       debugPrint("Incoming call 3");
  //       onTap;
  //       break;
  //     case AppTexts.acceptCallChannel:
  //       debugPrint("Incoming call 4");
  //       break;
  //     case AppTexts.callConnectedChannel:
  //       debugPrint("Incoming call 6");
  //       break;
  //     case AppTexts.isCallTerminateChannel:
  //       debugPrint("Incoming call 8");
  //       break;
  //     case AppTexts.isMuteCallChannel:
  //       debugPrint("Incoming call 9");
  //       break;
  //     case AppTexts.isUnMuteCallChannel:
  //       debugPrint("Incoming call 10");
  //       break;
  //     case AppTexts.isStartCallChannel:
  //       debugPrint("Incoming call 11");
  //       break;
  //     case AppTexts.isPauseChannel:
  //       debugPrint("Incoming call 12");
  //       break;
  //     case AppTexts.isLoginChannel:
  //       debugPrint("Incoming call 13");
  //       break;
  //     default:
  //   }
  // } 

}
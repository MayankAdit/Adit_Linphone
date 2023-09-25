// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:adit_lin_plugin/constant.dart';
import 'package:flutter/services.dart';

class AditLinPlugin {
  final methodChannel = const MethodChannel(AppTexts.aditLinPlugin);
   Function? onTap;

  AditLinPlugin(String channelName, Map<String, dynamic>? callData) {
    methodChannel.invokeMethod<String>(channelName, callData);
   // methodChannel.setMethodCallHandler(_handleMethod);
  }

  // Future<dynamic> _handleMethod(MethodCall call) async {
  //   debugPrint("linphone call channel 178787878${call.arguments}");
  //   switch (call.method) {
  //     case AppTexts.loginChannel:
  //       debugPrint("linphone call channel 1");
  //       break;
  //     case AppTexts.outgoingChannel:
  //       debugPrint("linphone call channel 2");
  //       onTap;
  //        debugPrint("linphone call channel 2");
  //       break;
  //     case AppTexts.acceptCallChannel:
  //       debugPrint("linphone call channel 4");
  //       break;
  //     case AppTexts.callConnectedChannel:
  //       debugPrint("linphone call channel 6");
  //       break;
  //     case AppTexts.isCallTerminateChannel:
  //       debugPrint("linphone call channel 8");
  //       break;
  //     case AppTexts.isMuteCallChannel:
  //       debugPrint("linphone call channel 9");
  //       break;
  //     case AppTexts.isUnMuteCallChannel:
  //       debugPrint("linphone call channel 10");
  //       break;
  //     case AppTexts.isStartCallChannel:
  //       debugPrint("linphone call channel 11");
  //       break;
  //     case AppTexts.isPauseChannel:
  //       debugPrint("linphone call channel 12");
  //       break;
  //     case AppTexts.isLoginChannel:
  //       debugPrint("linphone call channel 13");
  //       break;
  //     default:
  //   }
  // }
}

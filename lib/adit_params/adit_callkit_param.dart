

import 'package:adit_lin_plugin/adit_params/adit_callkit_g_param.dart';
import 'package:adit_lin_plugin/adit_params/adit_callkit_ios_param.dart';

class AditCallKitParams {
  const AditCallKitParams({
    this.id,
    this.nameCaller,
    this.appName,
    this.avatar,
    this.handle,
    this.type,
    this.duration,
    this.textAccept,
    this.textDecline,
    this.textMissedCall,
    this.textCallback,
    this.extra,
    this.headers,
    this.ios,
  });

  final String? id;
  final String? nameCaller;
  final String? appName;
  final String? avatar;
  final String? handle;
  final double? type;
  final double? duration;
  final String? textAccept;
  final String? textDecline;
  final String? textMissedCall;
  final String? textCallback;
  final Map<String, dynamic>? extra;
  final Map<String, dynamic>? headers;
  final AditIOSParams? ios;

  factory AditCallKitParams.fromJson(Map<String, dynamic> json) =>
      $AditCallKitParamsFromJson(json);

  Map<String, dynamic> toJson() => $AditCallKitParamsToJson(this); 
}

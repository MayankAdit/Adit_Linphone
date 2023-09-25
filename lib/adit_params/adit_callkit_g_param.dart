

import 'package:adit_lin_plugin/adit_params/adit_callkit_ios_param.dart';
import 'package:adit_lin_plugin/adit_params/adit_callkit_param.dart';

AditCallKitParams $AditCallKitParamsFromJson(Map<String, dynamic> json) =>
    AditCallKitParams(
      id: json['id'] as String?,
      nameCaller: json['nameCaller'] as String?,
      appName: json['appName'] as String?,
      avatar: json['avatar'] as String?,
      handle: json['handle'] as String?,
      type: (json['type'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      textAccept: json['textAccept'] as String?,
      textDecline: json['textDecline'] as String?,
      textMissedCall: json['textMissedCall'] as String?,
      textCallback: json['textCallback'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
      headers: json['headers'] as Map<String, dynamic>?,
      ios: json['ios'] == null
          ? null
          : AditIOSParams.fromJson(json['ios'] as Map<String, dynamic>),
    );

Map<String, dynamic> $AditCallKitParamsToJson(AditCallKitParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameCaller': instance.nameCaller,
      'appName': instance.appName,
      'avatar': instance.avatar,
      'handle': instance.handle,
      'type': instance.type,
      'duration': instance.duration,
      'textAccept': instance.textAccept,
      'textDecline': instance.textDecline,
      'textMissedCall': instance.textMissedCall,
      'textCallback': instance.textCallback,
      'extra': instance.extra,
      'headers': instance.headers,
      'ios': instance.ios?.toJson(),
    };

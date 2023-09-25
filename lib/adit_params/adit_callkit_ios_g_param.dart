import 'package:adit_lin_plugin/adit_params/adit_callkit_ios_param.dart';

AditIOSParams $AditIOSParamsFromJson(Map<String, dynamic> json) => AditIOSParams(
      iconName: json['iconName'] as String?,
      handleType: json['handleType'] as String?,
      supportsVideo: json['supportsVideo'] as bool?,
      maximumCallGroups: json['maximumCallGroups'] as int?,
      maximumCallsPerCallGroup: json['maximumCallsPerCallGroup'] as int?,
      audioSessionMode: json['audioSessionMode'] as String?,
      audioSessionActive: json['audioSessionActive'] as bool?,
      audioSessionPreferredSampleRate:
          (json['audioSessionPreferredSampleRate'] as num?)?.toDouble(),
      audioSessionPreferredIOBufferDuration:
          (json['audioSessionPreferredIOBufferDuration'] as num?)?.toDouble(),
      supportsDTMF: json['supportsDTMF'] as bool?,
      supportsHolding: json['supportsHolding'] as bool?,
      supportsGrouping: json['supportsGrouping'] as bool?,
      supportsUngrouping: json['supportsUngrouping'] as bool?,
      ringtonePath: json['ringtonePath'] as String?,
    );

Map<String, dynamic> $AditIOSParamsToJson(AditIOSParams instance) => <String, dynamic>{
      'iconName': instance.iconName,
      'handleType': instance.handleType,
      'supportsVideo': instance.supportsVideo,
      'maximumCallGroups': instance.maximumCallGroups,
      'maximumCallsPerCallGroup': instance.maximumCallsPerCallGroup,
      'audioSessionMode': instance.audioSessionMode,
      'audioSessionActive': instance.audioSessionActive,
      'audioSessionPreferredSampleRate':
          instance.audioSessionPreferredSampleRate,
      'audioSessionPreferredIOBufferDuration':
          instance.audioSessionPreferredIOBufferDuration,
      'supportsDTMF': instance.supportsDTMF,
      'supportsHolding': instance.supportsHolding,
      'supportsGrouping': instance.supportsGrouping,
      'supportsUngrouping': instance.supportsUngrouping,
      'ringtonePath': instance.ringtonePath,
    };

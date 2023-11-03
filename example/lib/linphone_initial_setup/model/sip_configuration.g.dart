part of 'sip_configuration.dart';

SipConfiguration _$SipConfigurationFromJson(Map<String, dynamic> json) =>
    SipConfiguration(
      json['extension'] as String,
      json['domain'] as String,
      json['password'] as String,
      json['port'] as int,
      json['transportType'],
      json['isKeepAlive'] as bool,
    );

Map<String, dynamic> _$SipConfigurationToJson(SipConfiguration instance) =>
    <String, dynamic>{
      'extension': instance.extension,
      'domain': instance.domain,
      'password': instance.password,
      'port': instance.port,
      'transportType': instance.transportType,
      'isKeepAlive': instance.isKeepAlive,
    };

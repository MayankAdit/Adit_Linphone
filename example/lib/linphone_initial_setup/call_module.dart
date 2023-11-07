import 'dart:async';
import 'dart:io';

import 'package:adit_lin_plugin_example/linphone_initial_setup/model/sip_configuration.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/utils/sip_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class CallModule {
  CallModule._privateConstructor();

  static final CallModule _instance = CallModule._privateConstructor();

  static CallModule get instance => _instance;

  static const MethodChannel _methodChannel =
      MethodChannel('method_channel_adit_lin');

  static const EventChannel _eventChannel =
      EventChannel('event_channel_adit_lin');

  static Stream broadcastStream = _eventChannel.receiveBroadcastStream();

  final StreamController<dynamic> _eventStreamController =
      StreamController.broadcast();

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  BuildContext? context;

  int count = 0;

  Future<void> initSipModule(
      SipConfiguration sipConfiguration, BuildContext context) async {
    this.context = context;
    broadcastStream.listen(_listener);
    await _methodChannel.invokeMethod(
        'initSipModule', {"sipConfiguration": sipConfiguration.toJson()});
  }

  String lastName = "";

  void _listener(dynamic event) {
    final eventName = event['event'] as String;

    print("event name ${eventName}");
    print("event body ${event['body']}");
    switch (eventName) {
      case 'AccountRegistrationStateChanged':
        _eventStreamController.add({
          'event': SipEvent.AccountRegistrationStateChanged,
          'body': event['body']
        });
        break;
      case 'Ring':
        var body = event['body'];

        bool isInComing = false;
        if (Platform.isAndroid) {
          isInComing = body["isIncoming"];
        } else {
          isInComing = body["callType"] == "inbound";
        }

        if (count == 0) {
          count++;

          if (isInComing) {
            if (context != null) {
              // Navigator.pushNamed(context!, '/callaccept').then((value) {});
              makeFakeCallInComing("6377897824");
            }
          }
        }
        _eventStreamController
            .add({'event': SipEvent.Ring, 'body': event['body']});
        break;
      case 'Up':
        _eventStreamController
            .add({'event': SipEvent.Up, 'body': event['body']});
        break;
      case 'Paused':
        _eventStreamController.add({'event': SipEvent.Paused});
        break;
      case 'Resuming':
        _eventStreamController.add({'event': SipEvent.Resuming});
        break;
      case 'Missed':
        _eventStreamController
            .add({'event': SipEvent.Missed, 'body': event['body']});
        break;
      case 'Hangup':
        count = 0;

        _eventStreamController
            .add({'event': SipEvent.Hangup, 'body': event['body']});
        break;
      case 'Error':
        _eventStreamController
            .add({'event': SipEvent.Error, 'body': event['body']});
        break;
    }
  }

  Future<bool> call(String phoneNumber) async {
    return await _methodChannel
        .invokeMethod('call', {"recipient": phoneNumber});
  }

  Future<bool> hangup() async {
    return await _methodChannel.invokeMethod('hangup');
  }

  Future<bool> answer() async {
    return await _methodChannel.invokeMethod('answer');
  }

  Future<bool> reject() async {
    return await _methodChannel.invokeMethod('reject');
  }

  Future<bool> transfer(String extension) async {
    return await _methodChannel
        .invokeMethod('transfer', {"extension": extension});
  }

  Future<bool> pause() async {
    return await _methodChannel.invokeMethod('pause');
  }

  Future<bool> resume() async {
    return await _methodChannel.invokeMethod('resume');
  }

  Future<bool> sendDTMF(String dtmf) async {
    return await _methodChannel.invokeMethod('sendDTMF', {"recipient": dtmf});
  }

  Future<bool> toggleSpeaker() async {
    return await _methodChannel.invokeMethod('toggleSpeaker');
  }

  Future<bool> toggleMic() async {
    return await _methodChannel.invokeMethod('toggleMic');
  }

  Future<bool> refreshSipAccount() async {
    return await _methodChannel.invokeMethod('refreshSipAccount');
  }

  Future<bool> unregisterSipAccount() async {
    return await _methodChannel.invokeMethod('unregisterSipAccount');
  }

  Future<String> getCallId() async {
    return await _methodChannel.invokeMethod('getCallId');
  }

  Future<int> getMissedCalls() async {
    return await _methodChannel.invokeMethod('getMissedCalls');
  }

  Future<String> getSipRegistrationState() async {
    return await _methodChannel.invokeMethod('getSipRegistrationState');
  }

  Future<bool> isMicEnabled() async {
    return await _methodChannel.invokeMethod('isMicEnabled');
  }

  Future<bool> isSpeakerEnabled() async {
    return await _methodChannel.invokeMethod('isSpeakerEnabled');
  }

  Future<void> makeFakeCallInComing(String number) async {
    final params = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: 'Hien Nguyen',
      appName: 'Callkit',
      avatar: '',
      handle: '0123456789',
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FF092A3D',
        backgroundUrl: '',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: '',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}

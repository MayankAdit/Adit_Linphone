// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:adit_lin_plugin/constant.dart';
import 'package:adit_lin_plugin/sip_event.dart';
import 'package:flutter/services.dart';

class AditLinPlugin {
  final methodChannel = const MethodChannel(AppTexts.aditLinPlugin);
   Function? onTap;

   static const EventChannel eventChannel = EventChannel('aditcallbackEvent');
   static Stream broadcastStream = eventChannel.receiveBroadcastStream();

   final StreamController<dynamic> _eventStreamController = StreamController.broadcast();

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  AditLinPlugin(String channelName, Map<String, dynamic>? callData) {
    broadcastStream.listen(_listener);
    methodChannel.invokeMethod<String>(channelName, callData);
  }
  
  void _listener(dynamic event) {
    final eventName = event['event'] as String;
    switch (eventName) {
      case 'AccountRegistrationStateChanged':
        _eventStreamController.add({'event': SipEvent.AccountRegistrationStateChanged, 'body': event['body']});
        break;
      case 'Ring':
        _eventStreamController.add({'event': SipEvent.Ring, 'body': event['body']});
        break;
      case 'Up':
        _eventStreamController.add({'event': SipEvent.Up, 'body': event['body']});
        break;
      case 'Paused':
        _eventStreamController.add({'event': SipEvent.Paused});
        break;
      case 'Resuming':
        _eventStreamController.add({'event': SipEvent.Resuming});       
        break;
      case 'Missed':
        _eventStreamController.add({'event': SipEvent.Missed, 'body': event['body']});
        break;
      case 'Hangup':
        _eventStreamController.add({'event': SipEvent.Hangup, 'body': event['body']});
        break;
      case 'Error':
        _eventStreamController.add({'event': SipEvent.Error, 'body': event['body']});
        break;
    }
  }

  Future<bool> call(Map<String, dynamic>? callData) async {
    return await methodChannel.invokeMethod('isOutgoingChannel', callData);
  }

  Future<bool> hangup() async {
    return await methodChannel.invokeMethod('isHungUpChannel');
  }

  Future<bool> answer() async {
    return await methodChannel.invokeMethod('isAcceptCallChannel');
  }

  Future<bool> reject() async {
    return await methodChannel.invokeMethod('isRejectCall');
  }

  Future<bool> transfer(String extension) async {
    return await methodChannel.invokeMethod('transfer', {"extension": extension});
  }

  Future<bool> pause() async {
    return await methodChannel.invokeMethod('isPausedChannel');
  }

  Future<bool> resume() async {
    return await methodChannel.invokeMethod('isResumChannel');
  }

  Future<bool> sendDTMF(String dtmf) async {
    return await methodChannel.invokeMethod('sendDTMF', {"recipient": dtmf});
  }

  Future<bool> toggleSpeaker() async {
    return await methodChannel.invokeMethod('toggleSpeaker');
  }

  Future<bool> toggleMic() async {
    return await methodChannel.invokeMethod('toggleMic');
  }

  Future<bool> refreshSipAccount() async {
    return await methodChannel.invokeMethod('refreshSipAccount');
  }

  Future<bool> unregisterSipAccount() async {
    return await methodChannel.invokeMethod('isUnregistration');
  }

  Future<String> getCallId() async {
    return await methodChannel.invokeMethod('getCallId');
  }

  Future<int> getMissedCalls() async {
    return await methodChannel.invokeMethod('getMissedCalls');
  }

  Future<String> getSipRegistrationState() async {
    return await methodChannel.invokeMethod('getSipRegistrationState');
  }

  Future<bool> isMicEnabled() async {
    return await methodChannel.invokeMethod('isMicEnabled');
  }

  Future<bool> isSpeakerEnabled() async {
    return await methodChannel.invokeMethod('isSpeakerEnabled');
  }
}

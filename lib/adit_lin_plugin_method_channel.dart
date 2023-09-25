import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


/// An implementation of [AditLinPluginPlatform] that uses method channels.
class MethodChannelAditLinPlugin {
  /// The method channel used to interact with the native platform.
  
  static final MethodChannelAditLinPlugin instance = MethodChannelAditLinPlugin();

  /// 
  @visibleForTesting
  final methodChannel = const MethodChannel('adit_lin_plugin');

  Future<String?> callingLinPhone(Map<String, dynamic>? callData) async {
    final version = await methodChannel.invokeMethod<String>('calling_LinPhone', callData);
    return version;
  }
}

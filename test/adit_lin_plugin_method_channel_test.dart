import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adit_lin_plugin/adit_lin_plugin_method_channel.dart';

void main() {
  MethodChannelAditLinPlugin platform = MethodChannelAditLinPlugin();
  const MethodChannel channel = MethodChannel('adit_lin_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('calling_LinPhone', () async {
    expect(await platform.callingLinPhone(), '42');
  });
}

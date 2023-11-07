import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/call_manager.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/model/sip_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DialPadWidget extends StatefulWidget {
  const DialPadWidget({Key? key}) : super(key: key);

  @override
  MyDialPadWidget createState() => MyDialPadWidget();
}

Map<String, dynamic>? callData;

class MyDialPadWidget extends State<DialPadWidget> {
  String? _dest;

  TextEditingController? _textController;
  late SharedPreferences _preferences;

  @override
  initState() {
    super.initState();

    initData();
  }

  void initData() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? '024';
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;
    setState(() {});

    String userName = "021-021OwnerVMobile1668"; //"001-001OwnervLive1285" live
    String password = "TFXzMSapF6hFUxZU"; //"HEScrrM2U75WnL8m"; live
    String domain = "pjsipbeta1.adit.com:65080";

    ///"pjsip1.adit.com:65080" live

    var sipConfiguration = SipConfigurationBuilder(
            extension: userName, domain: domain, password: password)
        .setKeepAlive(true)
        .setPort(65080)
        .setTransport("Udp")
        .build();
    LinePhoneCallManager.callModule.initSipModule(sipConfiguration, context);
    getCallingEvent();
  }

  permission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (statuses[Permission.microphone] != null) {}

    if (await Permission.location.isRestricted) {}
  }

  void _handleBackSpace([bool deleteAll = false]) {
    var text = _textController!.text;
    if (text.isNotEmpty) {
      setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        _textController!.text = text;
      });
    }
  }

  void _handleNum(String number) {
    setState(() {
      _textController!.text += number;
    });
  }

  List<Widget> _buildNumPad() {
    var labels = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'0': '+'},
      ],
    ];

    return labels
        .map((row) => Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed: () => _handleNum(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  List<Widget> _buildDialPad() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
            width: 300,
            child: TextField(
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Colors.black54),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
              ),
              controller: _textController,
            )),
      ),
      SizedBox(
          width: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNumPad())),
      SizedBox(
          width: 300,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ActionButton(
                    icon: Icons.call_sharp,
                    fillColor: Colors.green,
                    onPressed: () {
                      permission();
                      _preferences.setString(
                          'dest', _textController?.text ?? "");

                      LinePhoneCallManager.callModule
                          .call(_textController?.text ?? "");
                      Navigator.pushNamed(context, '/callscreen')
                          .then((value) {});
                    },
                  ),
                  ActionButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => _handleBackSpace(),
                    onLongPress: () => _handleBackSpace(true),
                  ),
                ],
              )))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("SIP UI"),
        ),
        body: Align(
            alignment: const Alignment(0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildDialPad(),
                  ),
                ])));
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

  getCallingEvent() {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      print("FlutterCallkitIncoming Event ${event!.event}");
      print("FlutterCallkitIncoming Body ${event.body}");

      switch (event.event) {
        case Event.actionCallIncoming:
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          LinePhoneCallManager.callModule.answer();
          break;
        case Event.actionCallDecline:
          LinePhoneCallManager.callModule.reject();

          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call

          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          //

          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS

          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        // case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        //   // TODO: only iOS
        //   break;
        // case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        //   // TODO: only iOS
        //   break;
        case Event.actionCallCustom:
          // TODO: Handle this case.

          break;
      }
    });
  }
}

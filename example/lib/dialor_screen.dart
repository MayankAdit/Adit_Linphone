import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/call_manager.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/model/sip_configuration.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    _dest = _preferences.getString('dest') ?? '8322399994';
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;
    setState(() {});

    String userName =
        "021-021OwnerVMobile2713"; //"601-V2Live2613" live ///021-021OwnerVMobile2713 :Beta
    String password =
        "PMmHUJajDZ7YT9Wy"; //"6ZybYWXZGLqunqHB"; live  // PMmHUJajDZ7YT9Wy Beta
    String domain =
        "pjsipbeta1.adit.com:65080"; //pjsip1.adit.com:65080 live  /// pjsipbeta2.adit.com:65080" beta

    //65082 tcp
    //65080 udp
    //65081 tls

    ///pjsipbeta2.adit.com:65080

    ///"pjsip1.adit.com:65080" live

    String state = "";

    try {
      state = await LinePhoneCallManager.callModule.getSipRegistrationState();
      print("state ${state}");
    } catch (e) {
      print("Register Exception : ${e}");
    }
    if (state == "") {
      var sipConfiguration = SipConfigurationBuilder(
              extension: userName, domain: domain, password: password)
          .setKeepAlive(true)
          .setPort(65080)
          .setTransport("Udp")
          .build();
      LinePhoneCallManager.callModule.initSipModule(sipConfiguration, context);
      postPBXToken();
    }
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
          await LinePhoneCallManager.callModule.answer();
          break;
        case Event.actionCallDecline:
          await LinePhoneCallManager.callModule.reject();

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

  var dio = Dio();

  void postPBXToken() async {
    _preferences = await SharedPreferences.getInstance();
    String? token = await FirebaseMessaging.instance.getAPNSToken();
    var voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    print("token ${token}");
    print("voipToken ${voipToken}");
    //String token = _preferences.getString('voiptoken') ?? "";
    String sipUser =
        _preferences.getString('auth_user') ?? "021-021OwnerVMobile2713";
    var data = {
      "token": voipToken,
      "devicetype": "ios",
      "sipuser": sipUser,
      // "environment": kDebugMode ? "debug" : "prod",
      "environment": "debug",
      "sessionAuthorization": "f3635738.b841.4602.9abd.01d3a3664f28",
      //Add session ID
      "dnd": "off",
    };

    var header = {
      "accept-mobile-api": "aditapp-mobile-api",
      "cookie":
          "s%3ATwGK-ypFf36Hn4AK08gcfgJxbxYrc38Z.zXBSwNMcSD15V3ApSD7eEM171mY00OxKoZliYKBs9rk",
      "authorization": "f3635738.b841.4602.9abd.01d3a3664f28",
    };

//https://betatelephony-manager.aditadv.xyz/pbx/proxyapi.php?key=ZNmuP3wMJqsXujtN
    //var url = Uri.https('https://betamobileapi.adit.com', '/pbx/proxyapi.php?key=ZNmuP3wMJqsXujtN');
    //   var url = Uri.parse("https://betatelephony-manager.aditadv.xyz/pbx/proxyapi.php?key=ZNmuP3wMJqsXujtN");
    // print(url);
    print(data);

    var response = await dio.post(
        'https://betamobileapi.adit.com/bridge/mobiletokensave',
        data: data,
        options: Options(headers: header));

    if (response.statusCode == 200) {
      print('Response body: ${response}');
      print(response.data.toString());
    }
    print('Response status: ${response.statusCode}');
  }
}

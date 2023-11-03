import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/call_manager.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/model/sip_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    String userName = "021-021OwnerVMobile1668";
    String password = "TFXzMSapF6hFUxZU";

    var sipConfiguration = SipConfigurationBuilder(
            extension: userName,
            domain: "pjsipbeta1.adit.com:65080",
            password: password)
        .setKeepAlive(true)
        .setPort(65080)
        .setTransport("Udp")
        .build();
    LinePhoneCallManager.callModule.initSipModule(sipConfiguration, context);
    // LinePhoneCallManager.callModule.eventStreamController.stream
    //     .listen((event) {
    //   switch (event['event']) {
    //     case SipEvent.AccountRegistrationStateChanged:
    //       {
    //         var body = event['body'];
    //
    //         print(body);
    //       }
    //       break;
    //     case SipEvent.Ring:
    //       {
    //         var body = event['body'];
    //         print("object  dialer ${body["isIncoming"]}");
    //         if (body["isIncoming"]) {
    //           Navigator.pushNamed(context, '/callaccept').then((value) {});
    //         }
    //       }
    //       break;
    //     case SipEvent.Up:
    //       {
    //         var body = event['body'];
    //         print("Up");
    //       }
    //       break;
    //     case SipEvent.Hangup:
    //       {
    //         var body = event['body'];
    //         print("Hangup");
    //       }
    //       break;
    //     case SipEvent.Paused:
    //       {
    //         print("Paused");
    //       }
    //       break;
    //     case SipEvent.Resuming:
    //       {
    //         print("Resuming");
    //       }
    //       break;
    //     case SipEvent.Missed:
    //       {
    //         var body = event['body'];
    //         print("Missed");
    //         print(body);
    //       }
    //       break;
    //     case SipEvent.Error:
    //       {
    //         var body = event['body'];
    //         print("Error");
    //         print(body);
    //       }
    //       break;
    //   }
    // });
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
}

import 'package:adit_lin_plugin/constant.dart';
import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/call_data_model.dart';
import 'package:adit_lin_plugin_example/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

class DialPadWidget extends StatefulWidget {
  final SIPUAHelper? _helper;
  const DialPadWidget(this._helper, {Key? key}) : super(key: key);
  @override
  MyDialPadWidget createState() => MyDialPadWidget();
}

Map<String, dynamic>? callData;

class MyDialPadWidget extends State<DialPadWidget>
    implements SipUaHelperListener {
//// handle outGoing
  Future<dynamic> _handleMethod(MethodCall methodCall) async {
    switch (methodCall.method) {
      case AppTexts.isRegistrationState:
        switch (methodCall.arguments) {
          case AppTexts.progress:
          debugPrint("register progress");
            break;
          case AppTexts.ok:
            _preferences.setBool('isLoginChannel', true);
            Fluttertoast.showToast(
                msg: "Registration Done!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            break;
          case AppTexts.cleared:
            break;
          case AppTexts.failed:
            _preferences.setBool('isLoginChannel', false);
            Fluttertoast.showToast(
                msg: "Registration Faild!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            break;
          default:
        }
        break;
      default:
    }
  }

//// handle incomingnn                      
  Future<dynamic> handleMethodIncoming(MethodCall call) async {
    if (call.arguments != null) {
      CallManager().call = CallDataModel(
          call.arguments["callId"],
          call.arguments["callerName"],
          call.arguments["duration"],
          call.arguments["state"],
          call.arguments["direction"]);
    }
    switch (call.method) {
      case AppTexts.isAcceptCallChannel:
        CallManager().isBackToBackground = true;
        Navigator.pushNamed(context, '/callscreen').then((value) {
          _loadSettings();
        });
        break;
      default:
    }
  }

  String? _dest;
  SIPUAHelper? get helper => widget._helper;
  TextEditingController? _textController;
  late SharedPreferences _preferences;
  String? receivedMsg;

  @override
  initState() {
    super.initState();
    receivedMsg = "";
    _bindEventListeners();
    _loadSettings();
    _textController?.text = "";
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? '3463471545';
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;
    var isLogedIn = _preferences.getBool('isLoginChannel');
    if (isLogedIn == false || isLogedIn == null) {
      CallManager().connectCall(AppTexts.isLoginChannel, "3463471545");
    } else {
      CallManager().connectCall(AppTexts.isAlreadyLogin, "3463471545");
    }

    CallManager()
        .aditLinPlugin
        ?.methodChannel
        .setMethodCallHandler((_handleMethod));
    CallManager()
        .demoCallBack
        .callBackChannel
        ?.setMethodCallHandler(handleMethodIncoming);
    setState(() {});
  }

  void _bindEventListeners() {
    helper!.addSipUaHelperListener(this);
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
                      _preferences.setString(
                          'dest', _textController?.text ?? "");
                      CallManager().connectCall(AppTexts.isOutgoingChannel,
                          _textController?.text ?? ""); //"12817191772"
                      CallManager().call = CallDataModel(
                          "", _textController?.text ?? "", 0, "", "");
                      Navigator.pushNamed(context, '/callscreen').then((value) {
                        _loadSettings();
                      });
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

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {});
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void callStateChanged(Call call, CallState callState) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //Save the incoming message to DB
    String? msgBody = msg.request.body as String?;
    setState(() {
      receivedMsg = msgBody;
    });
  }

  @override
  void onNewNotify(Notify ntf) {}
}

// ignore_for_file: sort_child_properties_last
// ignore: depend_on_referenced_packages

import 'dart:async';
import 'package:adit_lin_plugin/constant.dart';
import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/call_data_model.dart';
import 'package:adit_lin_plugin_example/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sip_ua/sip_ua.dart';

// ignore: must_be_immutable
class CallScreenWidget extends StatefulWidget {
  final SIPUAHelper? _helper;
  const CallScreenWidget(this._helper, {Key? key}) : super(key: key);
  @override
  MyCallScreenWidget createState() => MyCallScreenWidget();
}

class MyCallScreenWidget extends State<CallScreenWidget>
    implements SipUaHelperListener {
  bool _showNumPad = false;
  String _timeLabel = 'Ringing...';
  late Timer _timer;
  bool _audioMuted = false;
  bool _speakerOn = false;
  bool _hold = false;
  SIPUAHelper? get helper => widget._helper;

  CallDataModel? get call => CallManager().call;

  bool callConnected = false;

  TextEditingController? textController;

  @override
  initState() {
    super.initState();
    helper!.addSipUaHelperListener(this);
    CallManager()
        .aditLinPlugin
        ?.methodChannel
        .setMethodCallHandler((_handleMethod));

    CallManager()
        .demoCallBack
        .callBackChannel
        ?.setMethodCallHandler(handleMethodIncoming);

    textController?.text = "";
    if (CallManager().isBackToBackground) {
      _startTimer();
      callConnected = true;
      CallManager().isBackToBackground = false;
    }
    
  }

  @override
  deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      if (mounted) {
        setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void callStateChanged(Call call, CallState callState) {}

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  void _handleHangup() {
    if (_timeLabel != 'Ringing...') {
      _timer.cancel();
    }
    CallManager().connectCall(AppTexts.isHungUpChannel, "8324765379");
    CallManager().demoCallBack;
    Navigator.pop(context);
  }

   void moveDialor() {
    if (_timeLabel != 'Ringing...') {
      _timer.cancel();
    }
    CallManager().connectCall(AppTexts.isAlreadyLogin, "8324767957");
    CallManager().demoCallBack;
    Navigator.pop(context);
  }

  void _muteAudio() {
    if (_audioMuted) {
      CallManager().connectCall(AppTexts.isUnMuteCallChannel, "8324765379");
    } else {
      CallManager().connectCall(AppTexts.isMuteCallChannel, "8324765379");
    }
  }

  void _handleHold() {
    CallManager().connectCall(AppTexts.isHoldAndUnhold, "8324765379");
  }

  late String transferTarget;
  void _handleTransfer() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter target to transfer.'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                transferTarget = text;
              });
            },
            decoration: const InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                // call!.refer(transferTarget);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleNum(String number) {
    setState(() {
      textController?.text += number;
    });
  }

  void _handleKeyPad() {
    setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  void _handleAdd() {
    setState(() {});
  }

  void _handleBackSpace([bool deleteAll = false]) {
    var text = textController!.text;
    if (text.isNotEmpty) {
      setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        textController!.text = text;
      });
    }
  }

  void _toggleSpeaker() {
    CallManager().connectCall(AppTexts.isSpeakerChannel, "8324765379");
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
            padding: const EdgeInsets.all(5),
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

  Widget _buildActionButtons() {
    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];
    var advanceActionsTemp = <Widget>[];
    if (callConnected == true) {
      {
        advanceActions.add(ActionButton(
          title: _audioMuted ? 'Unmute' : 'Mute',
          icon: _audioMuted ? Icons.mic_off : Icons.mic,
          checked: _audioMuted,
          onPressed: () => _muteAudio(),
        ));

        advanceActions.add(ActionButton(
          title: _hold ? 'Unhold' : 'Hold',
          icon: _hold ? Icons.play_arrow : Icons.pause,
          checked: _hold,
          onPressed: () => _handleHold(),
        ));

        advanceActions.add(ActionButton(
          title: _speakerOn ? 'Speaker off' : 'Speaker on',
          icon: _speakerOn ? Icons.volume_off : Icons.volume_up,
          checked: _speakerOn,
          onPressed: () => _toggleSpeaker(),
        ));

        if (!_showNumPad) {
          basicActions.add(ActionButton(
            title: "Add",
            icon: Icons.add,
            onPressed: () => _handleAdd(),
          ));
        }

        if (!_showNumPad) {
          basicActions.add(ActionButton(
            title: "Keypad",
            icon: Icons.dialpad,
            onPressed: () => _handleKeyPad(),
          ));
        }

        if (_showNumPad) {
          basicActions.add(ActionButton(
            title: "Back",
            icon: Icons.keyboard_arrow_down,
            onPressed: () => _handleKeyPad(),
          ));
          basicActions.add(ActionButton(
            icon: Icons.keyboard_arrow_left,
            onPressed: () => _handleBackSpace(),
            onLongPress: () => _handleBackSpace(true),
          ));
        } else {
          basicActions.add(ActionButton(
            title: "Transfer",
            icon: Icons.phone_forwarded,
            onPressed: () => _handleTransfer(),
          ));
        }
      }
    }

    // advanceActionsTemp.add(ActionButton(
    //   title: "",
    //   onPressed: () => _handleHangup(),
    //   icon: Icons.call_sharp,
    //   fillColor: Colors.green,
    // ));

    advanceActionsTemp.add(ActionButton(
      title: "",
      onPressed: () => _handleHangup(),
      icon: Icons.call_end,
      fillColor: Colors.red,
    ));

    var actionWidgets = <Widget>[];

    if (_showNumPad) {
      actionWidgets.addAll(_buildNumPad());
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: advanceActions)));
      }
    }

    actionWidgets.add(Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basicActions)));
    if (!_showNumPad) {
      actionWidgets.add(Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: advanceActionsTemp)));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget _buildContent() {
    var stackWidgets = <Widget>[];
    stackWidgets.addAll([
      Positioned(
        top: !_showNumPad ? 48 : 5,
        left: 0,
        right: 0,
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showNumPad
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black54),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal)),
                          ),
                          controller: textController,
                        )),
                  )
                : Container(),
            !_showNumPad
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          ('VOICE CALL') + (_hold ? ' PAUSED BY' : ''),
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black54),
                        )))
                : Container(),
            !_showNumPad
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          call?.callerName ?? "",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54),
                        )))
                : Container(),
            !_showNumPad
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(_timeLabel,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54))))
                : Container(),
          ],
        )),
      ),
    ]);

    return Stack(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false, title: const Text("Calling")),
        body: Container(
          child: _buildContent(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
            child: SizedBox(width: 320, child: _buildActionButtons())));
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {}

  /// MARK: --- Outgoing ------

  Future<dynamic> _handleMethod(MethodCall methodCall) async {
    if (methodCall.arguments != null) {
      CallManager().call = CallDataModel(
          methodCall.arguments["callId"],
          methodCall.arguments["callerName"],
          methodCall.arguments["duration"],
          methodCall.arguments["state"],
          methodCall.arguments["direction"]);
    }
    switch (methodCall.method) {
      case AppTexts.isCallEventChannel:
        switch (call?.state) {
          case AppTexts.outgoingRinging:
            break;
          case AppTexts.connected:
            _startTimer();
            callConnected = true;
            break;
          case AppTexts.streamsRunning:
            break;
          case AppTexts.error:
            moveDialor();
            break;
          case AppTexts.end:
            moveDialor();
            break;
          default: 
        }
        break;
      case AppTexts.isPausedChannel:
        _hold = true;
        setState(() {});
        break;
      case AppTexts.isResumChannel:
        _hold = false;
        setState(() {});
        break;
      case AppTexts.isMuteCallChannel:
        _audioMuted = true;
        setState(() {});
        break;
      case AppTexts.isUnMuteCallChannel:
        _audioMuted = false;
        setState(() {});
        break;
      case AppTexts.isOnSpeakerChannel:
        _speakerOn = true;
        setState(() {});
        break;
      case AppTexts.isOffSpeakerChannel:
        _speakerOn = false;
        setState(() {});
        break;
      case AppTexts.isRingingCallTerminate:
        _speakerOn = false;
        setState(() {});
        break;
      case AppTexts.isStartCallChannel:
        debugPrint("linphone call channel 11");
        break;
      default:
    }
  }

  /// MARK: --- Incoming ------

  Future<dynamic> handleMethodIncoming(MethodCall methodCall) async {
    if (methodCall.arguments != null) {
      CallManager().call = CallDataModel(
          methodCall.arguments["callId"],
          methodCall.arguments["callerName"],
          methodCall.arguments["duration"],
          methodCall.arguments["state"],
          methodCall.arguments["direction"]);
    }
    switch (methodCall.method) {
      case AppTexts.isCallEventChannel:
      switch (call?.state) {
          case AppTexts.connected:
            break;
          case AppTexts.streamsRunning:
            break;
          case AppTexts.error:
            moveDialor();
            break;
          case AppTexts.end:
            moveDialor();
            break;
          default:   
        }
        break;
      case AppTexts.isPausedChannel:
        _hold = true;
        setState(() {});
        break;
      case AppTexts.isResumChannel:
        _hold = false;
        setState(() {});
        break;
      case AppTexts.isMuteCallChannel:
        _audioMuted = true;
        setState(() {});
        break;
      case AppTexts.isUnMuteCallChannel:
        _audioMuted = false;
        setState(() {});
        break;
      case AppTexts.isOnSpeakerChannel:
        _speakerOn = true;
        setState(() {});
        break;
      case AppTexts.isOffSpeakerChannel:
        _speakerOn = false;
        setState(() {});
        break;
      case AppTexts.isRingingCallTerminate:
        break;
      case AppTexts.isStartCallChannel:
        debugPrint("Incoming call 11");
        break;
      default:
    }
  }
}

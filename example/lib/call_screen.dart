import 'dart:async';

import 'package:adit_lin_plugin_example/action_button.dart';
import 'package:adit_lin_plugin_example/linphone_initial_setup/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget({Key? key}) : super(key: key);

  @override
  MyCallScreenWidget createState() => MyCallScreenWidget();
}

class MyCallScreenWidget extends State<CallScreenWidget> {
  bool _showNumPad = false;
  String _timeLabel = 'Ringing...';
  late Timer _timer;
  bool _audioMuted = false;
  bool _speakerOn = false;
  bool _hold = false;

  bool callConnected = false;

  TextEditingController? textController;

  @override
  initState() {
    super.initState();

    textController?.text = "";
  }

  @override
  deactivate() {
    super.deactivate();
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

  void _handleHangup() {
    LinePhoneCallManager.callModule.hangup();

    Navigator.pop(context);
  }

  void moveDialor() {
    if (_timeLabel != 'Ringing...') {
      _timer.cancel();
    }

    Navigator.pop(context);
  }

  void _muteAudio() {
    LinePhoneCallManager.callModule.toggleMic();
  }

  void _handleHold() {
    LinePhoneCallManager.callModule.pause();
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
    LinePhoneCallManager.callModule.toggleSpeaker();
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
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          "",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
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
}

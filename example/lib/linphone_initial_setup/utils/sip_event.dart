import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum SipEvent {
  AccountRegistrationStateChanged,
  Ring,
  Up,
  Paused,
  Resuming,
  Missed,
  Hangup,
  Error,
  // Released
}

showToast(String message) async {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}

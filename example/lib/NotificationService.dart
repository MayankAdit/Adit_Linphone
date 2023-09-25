import 'dart:io';
import 'dart:math';

int lastSavedNotificationId = -1;

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();
  //var voipPush = vo.FlutterVoipPushNotification();

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal() {
    _configureSelectNotificationSubject();
  }

  void initializeFcm() async {
    //voipPush.configure(onMessage: onMessage, onResume: onResume);
    intItLocalNotificationSetting();
  }

  handleClickEvent(Map message, {bool isFromBackground = false}) async {}

  Future<dynamic> onMessage(bool isLocal, Map<String, dynamic> payload) async {
    if (Platform.isAndroid) {
      onRemoteMessageiOS(payload);
    }
    return Future.value(payload);
  }

  Future<dynamic> onResume(bool isLocal, Map<String, dynamic> payload) async {
    onRemoteMessageiOS(payload, isBackground: true);

    return Future.value(payload);
  }

  var random = Random();

  var callerNumber = "";
  var lastNotificationID = 0;

  onRemoteMessageiOS(Map<String, dynamic> message,
      {bool isBackground = false}) async {}

  intItLocalNotificationSetting() async {}

  Future<void> showOngoingCallNotification(
      String number, callerId, String lastTime,
      {bool showWhen = false}) async {}

  void _configureSelectNotificationSubject() {}
}

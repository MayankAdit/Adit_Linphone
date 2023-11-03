import 'package:adit_lin_plugin_example/linphone_initial_setup/call_manager.dart';
import 'package:flutter/material.dart';

class CallAcceptReject extends StatefulWidget {
  const CallAcceptReject({Key? key}) : super(key: key);

  @override
  State<CallAcceptReject> createState() => _CallAcceptRejectState();
}

class _CallAcceptRejectState extends State<CallAcceptReject>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Accept Reject"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                LinePhoneCallManager.callModule.answer();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/callscreen').then((value) {});
              },
              child: const Text("Accept"),
            ),
            const SizedBox(
              width: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                LinePhoneCallManager.callModule.reject();
              },
              child: const Text("Reject"),
            ),
          ],
        )
      ]),
    );
  }
}

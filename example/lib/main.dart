
import 'package:adit_lin_plugin_example/call_screen.dart';
import 'package:adit_lin_plugin_example/dialor_screen.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:sip_ua/sip_ua.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // if (WebRTC.platformIsDesktop) {
  //   debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  // }
  runApp(MyApp());
}

typedef PageContentBuilder = Widget Function(
    [ Object? arguments]);

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  //final SIPUAHelper _helper = SIPUAHelper();
  Map<String, PageContentBuilder> routes = {
    '/': ([Object? arguments]) => DialPadWidget(),
    '/callscreen': ([Object? arguments]) =>
        CallScreenWidget(),
  };

  MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) =>
                pageContentBuilder(settings.arguments));
        return route;
      } else {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) => pageContentBuilder());
        return route;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

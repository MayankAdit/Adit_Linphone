import 'package:adit_lin_plugin_example/call_accept_reject.dart';
import 'package:adit_lin_plugin_example/call_manager.dart';
import 'package:adit_lin_plugin_example/call_screen.dart';
import 'package:adit_lin_plugin_example/dialor_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CallManager();
  runApp(MyApp());
}

typedef PageContentBuilder = Widget Function([Object? arguments]);

class MyApp extends StatelessWidget {
  Map<String, PageContentBuilder> routes = {
    '/': ([Object? arguments]) => const DialPadWidget(),
    '/callscreen': ([Object? arguments]) => const CallScreenWidget(),
    '/callaccept': ([Object? arguments]) => const CallAcceptReject(),
  };

  MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) => pageContentBuilder(settings.arguments));
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

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vkid_flutter_sdk_example/screen/one_tap_screen.dart';
import 'package:vkid_flutter_sdk_example/screen/sheet_screen.dart';
import 'package:vkid_flutter_sdk_example/screen/utils_screen.dart';
import 'package:vkid_flutter_sdk_example/screen/oauth_widget_screen.dart';
import 'package:vkid_flutter_sdk_example/vkid_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String clientID = "Unknown";
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _vkidFlutterSdkPlugin = VkidFlutterSdk();
  int? _selectedIndex;

  List<Widget> pages = [];
  @override
  void initState() {
    super.initState();
    initClientID();
  }

  Future<void> initClientID() async {
    String id;
    try {
      id = await _vkidFlutterSdkPlugin.getClientID() ?? 'Unknown client id';
    } on PlatformException {
      id = 'Failed to get client id.';
    }
    if (!mounted) return;
    setState(() {
      clientID = id;
      _selectedIndex = 0;
      pages = <Widget>[
        UtilsScreen(messengerKey, clientID),
        OneTapScreen(messengerKey, clientID),
        SheetScreen(messengerKey, clientID),
        OAuthWidgetScreen(messengerKey, clientID),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: messengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        backgroundColor: Colors.purple,
        body: _selectedIndex != null
            ? pages[_selectedIndex!]
            : const Text("Loading..."),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Utils"),
            BottomNavigationBarItem(
                icon: Icon(Icons.ads_click), label: "OneTap"),
            BottomNavigationBarItem(
                icon: Icon(Icons.short_text), label: "Sheet"),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_week), label: "Widget"),
          ],
          currentIndex: _selectedIndex ?? 0,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../functions.dart';

import 'home.dart';
import 'welcome_screen.dart';


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  functions functions1 = functions();

  @override
  Widget build(BuildContext context) {
    Widget finalWidget;
    if (functions1.settings1.firsttime == true) {
      finalWidget = WelcomeScreen();
    }
    else {
      finalWidget = HomePage();
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: finalWidget,
    );
  }




}
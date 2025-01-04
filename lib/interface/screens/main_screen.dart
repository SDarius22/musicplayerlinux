import 'package:flutter/material.dart';
import '../../controller/settings_controller.dart';
import 'home.dart';
import 'welcome_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  late Future<Widget> _timerFuture;

  @override
  void initState() {
    super.initState();
    _timerFuture = Future.delayed(const Duration(milliseconds: 500), () async {
      if (SettingsController.firstTime) {
        return const WelcomeScreen();
      } else {
        return const HomePage();
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _timerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!;
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
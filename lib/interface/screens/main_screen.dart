import 'package:flutter/material.dart';

import '../../controller/app_audio_handler.dart';
import '../../controller/app_manager.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/data_controller.dart';
import '../../controller/online_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/worker_controller.dart';
import '../../repository/objectBox.dart';
import 'home.dart';
import 'welcome_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Future _timerFuture;

  @override
  void initState() {
    _timerFuture = Future(() async {
      await ObjectBox.initialize();
      SettingsController.init();
      WorkerController.init();
      DataController.init();
      await AppAudioHandler.init();
      AppManager.init();
      OnlineController.init();

      final apc = AudioPlayerController();
      apc.updateCurrentSong(SettingsController.currentSongPath);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _timerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (SettingsController.firstTime) {
            return const WelcomeScreen();
          } else {
            return const HomePage();
          }
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
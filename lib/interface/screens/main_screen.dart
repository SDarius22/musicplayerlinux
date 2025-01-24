import 'package:bitsdojo_window/bitsdojo_window.dart';
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
  final List<String> args;
  const MyApp({super.key, required this.args});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Future<Widget> _timerFuture;

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

      if (widget.args.isNotEmpty){
        debugPrint("App is already running, should add to queue!");
        SettingsController.queue = widget.args;
        SettingsController.index = 0;
      }

      final apc = AudioPlayerController();
      apc.updateCurrentSong(SettingsController.currentSongPath);
      doWhenWindowReady(() {
        final win = appWindow;
        win.minSize = const Size(800, 600);
        win.alignment = Alignment.center;
        win.title = 'Music Player';
        win.maximize();
        win.show();
      });
      if (SettingsController.firstTime) {
        return const WelcomeScreen();
      } else {
        return const HomePage();
      }
    });
    super.initState();
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
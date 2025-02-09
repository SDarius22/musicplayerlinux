import 'package:flutter/material.dart';
import '../../controller/settings_controller.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 1));
    // await ObjectBox.initialize();
    // SettingsController.init();
    // WorkerController.init();
    // DataController.init();
    // await AppAudioHandler.init();
    // AppManager.init();
    // OnlineController.init();
    //
    // final apc = AudioPlayerController();
    // apc.updateCurrentSong(SettingsController.currentSongPath);
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        SettingsController.firstTime ? '/welcome' : '/home',
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
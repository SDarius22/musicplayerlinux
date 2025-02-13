import 'package:flutter/material.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/worker_controller.dart';

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
    // await Future.delayed(const Duration(seconds: 1));
    await WorkerController.retrieveAllSongs();
    if (SettingsController.queue.isEmpty){
      debugPrint("Queue is empty");
      var songs = await DataController.getSongs('');
      SettingsController.queue = songs.map((e) => e.path).toList();
      int newIndex = 0;
      SettingsController.index = newIndex;
    }
    else{
      // debugPrint(SettingsController.index.toString());
      // debugPrint(SettingsController.shuffledQueue.toString());
    }
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        SettingsController.firstTime ? '/welcome' : '/tracks',
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
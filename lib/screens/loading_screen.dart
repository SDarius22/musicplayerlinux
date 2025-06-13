import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/screens/home_screen.dart';
import 'package:musicplayer/screens/welcome_screen.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const LoadingScreen(),
    );
  }

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with AfterLayoutMixin<LoadingScreen> {
  @override
  void afterFirstLayout(BuildContext context) {
    _routeUser();
  }

  void _routeUser() async {
    if (mounted) {
      // var infoProvider = Provider.of<InfoProvider>(context, listen: false);
      var pageProvider = Provider.of<AppStateProvider>(context, listen: false);
      await Provider.of<AudioProvider>(context, listen: false).init(Provider.of<SettingsService>(context, listen: false));
      // if (infoProvider.currentAudioInfo.unshuffledQueue.isEmpty){
      //   debugPrint("Queue is empty");
      //   var songs = await LocalDataProvider().getSongs('');
      //   infoProvider.currentAudioInfo.unshuffledQueue = songs.map((e) => e.data).toList();
      //   infoProvider.index = 0;
      // }
      if (pageProvider.appSettings.firstTime) {
        Navigator.pushReplacement(context, WelcomeScreen.route());
      }
      else {
        Navigator.pushReplacement(context, HomeScreen.route());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});
//   @override
//   State<LoadingScreen> createState() => _LoadingScreenState();
// }
//
// class _LoadingScreenState extends State<LoadingScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     _initApp();
//   }
//
//   Future<void> _initApp() async {
//     // await Future.delayed(const Duration(seconds: 1));
//     await WorkerController.retrieveAllSongs();
//     if (SettingsController.queue.isEmpty){
//       debugPrint("Queue is empty");
//       var songs = await DataController.getSongs('');
//       SettingsController.queue = songs.map((e) => e.path).toList();
//       int newIndex = 0;
//       SettingsController.index = newIndex;
//     }
//     else{
//       // debugPrint(SettingsController.index.toString());
//       // debugPrint(SettingsController.shuffledQueue.toString());
//     }
//     if (mounted) {
//       Navigator.pushReplacementNamed(
//         context,
//         SettingsController.firstTime ? '/welcome' : '/tracks',
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
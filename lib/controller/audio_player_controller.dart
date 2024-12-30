import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/settings_controller.dart';


class AudioPlayerController {
  static final AudioPlayerController _instance = AudioPlayerController._internal();

  factory AudioPlayerController() => _instance;

  AudioPlayerController._internal();

  static AudioPlayer audioPlayer = AudioPlayer();
  
  static void init (){
    audioPlayer.onPositionChanged.listen((Duration event) {
      SettingsController.slider = event.inMilliseconds;
    });
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      SettingsController.playing = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        if (SettingsController.repeat) {
          print("repeat");
          SettingsController.slider = 0;
          playSong();
        } else {
          print("next");
          nextSong();
        }
      }
    });
  }

  static Future<void> playSong() async {
      print("play");
      await audioPlayer.play(
          DeviceFileSource(SettingsController.currentSongPath),
          position: Duration(milliseconds: SettingsController.slider),
          volume: SettingsController.volume,
          balance: SettingsController.balance,
      );
      SettingsController.playing = true;
  }
  
  static Future<void> pauseSong() async{
    print("pause");
    await audioPlayer.pause();
    SettingsController.playing = false;
  }

  static Future<void> nextSong() async {
    if (SettingsController.index == SettingsController.queue.length - 1) {
      SettingsController.index = 0;
    } else {
      SettingsController.index = SettingsController.index + 1;
    }
    playSong();
  }

  static Future<void> previousSong() async {
    if (SettingsController.slider > 5000) {
      audioPlayer.seek(const Duration(milliseconds: 0));
    } else {
        if (SettingsController.index == 0) {
          SettingsController.index = SettingsController.queue.length - 1;
        } else {
          SettingsController.index = SettingsController.index - 1;
        }
        playSong();
    }
  }

  void setTimer(String time) {
    final am = AppManager();
    switch (time) {
      case '1 minute':
        print("1 minute");
        SettingsController.sleepTimer = 1 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 1 minute", 3500);
        break;
      case '15 minutes':
        SettingsController.sleepTimer = 15 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 15 minutes", 3500);
        break;
      case '30 minutes':
        SettingsController.sleepTimer = 30 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 30 minutes", 3500);
        break;
      case '45 minutes':
        SettingsController.sleepTimer = 45 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 45 minutes", 3500);
        break;
      case '1 hour':
        SettingsController.sleepTimer = 1 * 60 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 1 hour", 3500);
        break;
      case '2 hours':
        SettingsController.sleepTimer = 2 * 60 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 2 hours", 3500);
        break;
      case '3 hours':
        SettingsController.sleepTimer = 3 * 60 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 3 hours", 3500);
        break;
      case '4 hours':
        SettingsController.sleepTimer = 4 * 60 * 60 * 1000;
        startTimer();
        am.showNotification("Sleep timer set to 4 hours", 3500);
        break;
      default:
        SettingsController.sleepTimer = 0;
        am.showNotification("Sleep timer has been turned off", 3500);
        break;
    }
  }

  void startTimer() {
    final am = AppManager();
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (SettingsController.sleepTimer > 0) {
        SettingsController.sleepTimer -= 10;
      } else {
        timer.cancel();
        audioPlayer.pause();
        SettingsController.playing = false;
        am.showNotification("Sleep timer has ended", 3500);
      }
    });
  }


}
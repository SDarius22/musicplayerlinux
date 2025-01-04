import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/domain/song_type.dart';
import 'package:path_provider/path_provider.dart';


class AudioPlayerController extends BaseAudioHandler {
  static final AudioPlayerController _instance = AudioPlayerController._internal();
  String _filePath = "SomeNonExistentPath";
  factory AudioPlayerController() => _instance;

  AudioPlayerController._internal(){
    init();
  }

  static AudioPlayer audioPlayer = AudioPlayer();

  void init (){
    audioPlayer.onPositionChanged.listen((Duration event) {
      SettingsController.slider = event.inMilliseconds;
    });
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      SettingsController.playing = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        if (SettingsController.repeat) {
          print("repeat");
          SettingsController.slider = 0;
          play();
        } else {
          print("next");
          skipToNext();
        }
      }
    });
  }


  Future<void> addSong(SongType song, Uint8List bytes) async {
    File lastFile = File(_filePath);
    if (lastFile.existsSync()) {
      lastFile.deleteSync();
    }
    final ByteData data = ByteData.view(bytes.buffer);
    final String dir = (await getApplicationCacheDirectory()).path;
    final String path = '$dir/${song.album}-${song.title}.jpeg';
    _filePath = path;
    final File file = File(path);
    await file.writeAsBytes(data.buffer.asUint8List());
    MediaItem item = MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artists,
      duration: Duration(milliseconds: song.duration),
      artUri: Uri.file(path),
    );
    mediaItem.add(item);
  }

  @override
  Future<void> play() async {
      print("play");
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: [MediaControl.pause],
      ));
      await audioPlayer.play(
          DeviceFileSource(SettingsController.currentSongPath),
          position: Duration(milliseconds: SettingsController.slider),
          volume: SettingsController.volume,
          balance: SettingsController.balance,
      );
      SettingsController.playing = true;
  }

  @override
  Future<void> pause() async{
    print("pause");
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));
    await audioPlayer.pause();
    SettingsController.playing = false;
  }

  @override
  Future<void> skipToNext() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToNext],
    ));
    if (SettingsController.index == SettingsController.queue.length - 1) {
      SettingsController.index = 0;
    } else {
      SettingsController.index = SettingsController.index + 1;
    }
    play();
  }

  @override
  Future<void> skipToPrevious() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToPrevious],
    ));
    if (SettingsController.slider > 5000) {
      audioPlayer.seek(const Duration(milliseconds: 0));
    } else {
        if (SettingsController.index == 0) {
          SettingsController.index = SettingsController.queue.length - 1;
        } else {
          SettingsController.index = SettingsController.index - 1;
        }
        play();
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
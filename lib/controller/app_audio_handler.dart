import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'audio_player_controller.dart';

class AppAudioHandler{
  static final AppAudioHandler _instance = AppAudioHandler._internal();
  factory AppAudioHandler() => _instance;

  AppAudioHandler._internal();
  static late var audioHandler;

  static Future<void> init () async {
    if (Platform.isLinux) {
      audioHandler = await AudioService.init(
        builder: () => AudioPlayerController(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.musicplayer',
          androidNotificationChannelName: 'Music Player',
          androidNotificationOngoing: true,
        ),
      );
    }
    else if (Platform.isWindows) {
      final apc = AudioPlayerController();
      await apc.init();
      audioHandler = SMTCWindows(
        metadata: const MusicMetadata(
          title: 'Title',
          album: 'Album',
          albumArtist: 'Album Artist',
          artist: 'Artist',
        ),
        timeline: const PlaybackTimeline(
          startTimeMs: 0,
          endTimeMs: 1000,
          positionMs: 0,
          minSeekTimeMs: 0,
          maxSeekTimeMs: 1000,
        ),
        config: const SMTCConfig(
          fastForwardEnabled: false,
          nextEnabled: true,
          pauseEnabled: true,
          playEnabled: true,
          rewindEnabled: false,
          prevEnabled: true,
          stopEnabled: false,
        ),
      );
      try {
        audioHandler.buttonPressStream.listen((event) async {
          switch (event) {
            case PressedButton.play:
              await play();
              break;
            case PressedButton.pause:
              await pause();
              break;
            case PressedButton.next:
              print('Next');
              await skipToNext();
              break;
            case PressedButton.previous:
              print('Previous');
              await skipToPrevious();
              break;
            case PressedButton.stop:
              print('Stop');
              await stop();
              break;
            default:
              break;
          }
        });
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  static Future<void> play() async {
    if (Platform.isLinux){
      await audioHandler.play();
    }
    else if (Platform.isWindows){
      await audioHandler.setPlaybackStatus(PlaybackStatus.Playing);
      final apc = AudioPlayerController();
      await apc.play();
    }
  }

  static Future<void> pause() async {
    if (Platform.isLinux){
      await audioHandler.pause();
    }
    else if (Platform.isWindows){
      await audioHandler.setPlaybackStatus(PlaybackStatus.Paused);
      final apc = AudioPlayerController();
      await apc.pause();
    }
  }

  static Future<void> skipToNext() async {
    if (Platform.isLinux){
      await audioHandler.skipToNext();
    }
    else if (Platform.isWindows){
      final apc = AudioPlayerController();
      await apc.skipToNext();
    }
  }

  static Future<void> skipToPrevious() async {
    if (Platform.isLinux){
      await audioHandler.skipToPrevious();
    }
    else if (Platform.isWindows){
      final apc = AudioPlayerController();
      await apc.skipToPrevious();
    }
  }

  static Future<void> stop() async {
    if (Platform.isLinux){
      await audioHandler.stop();
    }
    else if (Platform.isWindows){
      audioHandler.setPlaybackStatus(PlaybackStatus.Stopped);
      audioHandler.disableSmtc();
      final apc = AudioPlayerController();
      await apc.stop();
    }
  }
}
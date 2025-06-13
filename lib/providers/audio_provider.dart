import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart' as PlatformService;
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/app_audio_service.dart';
import 'package:musicplayer/services/settings_service.dart';


class AudioProvider with ChangeNotifier {
  AppAudioService? _audioHandler;

  Song get currentSong => _audioHandler?.currentSong ?? Song();
  Uint8List ? get image => _audioHandler?.image;

  bool get playing => _audioHandler?.audioSettings.playing ?? false;
  bool get repeat => _audioHandler?.audioSettings.repeat ?? false;
  bool get shuffle => _audioHandler?.audioSettings.shuffle ?? false;
  double get volume => _audioHandler?.audioSettings.volume ?? 0.5;
  get queue => _audioHandler?.audioSettings.queue;
  get audioPlayer => _audioHandler?.audioPlayer;


  Future<void> init(SettingsService settingsService) async {
    if (Platform.isLinux) {
      _audioHandler = await PlatformService.AudioService.init(
        builder: () => AppAudioService(settingsService),
        config: const PlatformService.AudioServiceConfig(
          androidNotificationChannelId: 'com.example.musicplayer',
          androidNotificationChannelName: 'Music Player',
          androidNotificationOngoing: true,
        ),
      );
      await _audioHandler?.updateCurrentSong();
      notifyListeners();
    }
    // else if (Platform.isWindows) {
    //   AudioService();
    //   audioHandler = SMTCWindows(
    //     metadata: const MusicMetadata(
    //       title: 'Title',
    //       album: 'Album',
    //       albumArtist: 'Album Artist',
    //       artist: 'Artist',
    //     ),
    //     timeline: const PlaybackTimeline(
    //       startTimeMs: 0,
    //       endTimeMs: 1000,
    //       positionMs: 0,
    //       minSeekTimeMs: 0,
    //       maxSeekTimeMs: 1000,
    //     ),
    //     config: const SMTCConfig(
    //       fastForwardEnabled: false,
    //       nextEnabled: true,
    //       pauseEnabled: true,
    //       playEnabled: true,
    //       rewindEnabled: false,
    //       prevEnabled: true,
    //       stopEnabled: false,
    //     ),
    //   );
    //   try {
    //     audioHandler.buttonPressStream.listen((event) async {
    //       switch (event) {
    //         case PressedButton.play:
    //           await play();
    //           break;
    //         case PressedButton.pause:
    //           await pause();
    //           break;
    //         case PressedButton.next:
    //           debugPrint('Next');
    //           await skipToNext();
    //           break;
    //         case PressedButton.previous:
    //           debugPrint('Previous');
    //           await skipToPrevious();
    //           break;
    //         case PressedButton.stop:
    //           debugPrint('Stop');
    //           await stop();
    //           break;
    //         default:
    //           break;
    //       }
    //     });
    //   } catch (e) {
    //     debugPrint("Error: $e");
    //   }
    // }
  }

  Future<void> play() async {
    if (Platform.isLinux){
      await _audioHandler?.play();
    }
    // else if (Platform.isWindows){
    //   await audioHandler.setPlaybackStatus(PlaybackStatus.Playing);
    //   final apc = AudioPlayerController();
    //   await apc.play();
    // }
  }

  Future<void> pause() async {
    if (Platform.isLinux){
      await _audioHandler?.pause();
    }
    // else if (Platform.isWindows){
    //   await audioHandler.setPlaybackStatus(PlaybackStatus.Paused);
    //   final apc = AudioPlayerController();
    //   await apc.pause();
    // }
  }

  Future<void> skipToNext() async {
    if (Platform.isLinux){
      await _audioHandler?.skipToNext();
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.skipToNext();
    // }
    notifyListeners();
  }

  Future<void> skipToPrevious() async {
    if (Platform.isLinux){
      await _audioHandler?.skipToPrevious();
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.skipToPrevious();
    // }
    notifyListeners();
  }

  Future<void> stop() async {
    if (Platform.isLinux){
      await _audioHandler?.stop();
    }
    // else if (Platform.isWindows){
    //   audioHandler.setPlaybackStatus(PlaybackStatus.Stopped);
    //   audioHandler.disableSmtc();
    //   final apc = AudioPlayerController();
    //   await apc.stop();
    // }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (Platform.isLinux){
      await _audioHandler?.seek(position);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.seek(position);
    // }
    notifyListeners();
  }

  void setVolume(double volume) {
    if (Platform.isLinux){
      _audioHandler?.setVolume(volume);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setVolume(volume);
    // }
    notifyListeners();
  }

  void setBalance(double balance) {
    if (Platform.isLinux){
      _audioHandler?.setBalance(balance);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setBalance(balance);
    // }
    notifyListeners();
  }

  void setRepeat(bool repeat) {
    if (Platform.isLinux){
      _audioHandler?.setRepeat(repeat);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setRepeat(repeat);
    // }
    notifyListeners();
  }

  void setShuffle(bool shuffle) {
    if (Platform.isLinux){
      _audioHandler?.setShuffle(shuffle);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setShuffle(shuffle);
    // }
    notifyListeners();
  }

  void setQueue(List<String> songs) {
    if (Platform.isLinux){
      _audioHandler?.setQueue(songs);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setQueue(songs);
    // }
    notifyListeners();
  }

  void setSlider(int slider) {
    if (Platform.isLinux){
      _audioHandler?.setSlider(slider);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setSlider(slider);
    // }
  }

  Future<Duration> getDuration() async {
    if (Platform.isLinux){
      return await _audioHandler?.getDuration() ?? Duration.zero;
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   return await apc.getDuration();
    // }
    return Duration.zero;
  }

  void addToQueue(String songPath) {
    if (Platform.isLinux){
      _audioHandler?.addToQueue(songPath);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.addToQueue(songPath);
    // }
    notifyListeners();
  }

  void removeFromQueue(String songPath) {
    if (Platform.isLinux){
      _audioHandler?.removeFromQueue(songPath);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.removeFromQueue(songPath);
    // }
    notifyListeners();
  }

  Future<void> setCurrentIndex(String path) async {
    if (Platform.isLinux){
      await _audioHandler?.setCurrentIndex(path);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.updateCurrentSong();
    // }
    notifyListeners();
  }

  Future<void> updateCurrentSong() async {
    if (Platform.isLinux){
      await _audioHandler?.updateCurrentSong();
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.updateCurrentSong();
    // }
    notifyListeners();
  }





}
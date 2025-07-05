import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart' as platform_service;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/app_audio_service.dart';
import 'package:musicplayer/services/file_service.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:musicplayer/services/song_service.dart';


class AudioProvider with ChangeNotifier {
  AppAudioService? _audioHandler;

  Song get currentSong => _audioHandler?.currentSong ?? Song();
  Uint8List ? get image => _audioHandler?.image;
  List<String> get queue => _audioHandler?.audioSettings.queue ?? [];
  get audioPlayer => _audioHandler?.audioPlayer;

  ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> repeatNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> shuffleNotifier = ValueNotifier<bool>(false);
  ValueNotifier<int> sliderNotifier = ValueNotifier<int>(0);
  ValueNotifier<double> balanceNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);
  ValueNotifier<double> playbackSpeedNotifier = ValueNotifier<double>(1.0);

  bool hasBeenInitialized = false;

  late Future queueFuture;

  Future<void> init(SettingsService settingsService, SongService songService) async {
    if (Platform.isLinux) {
      if (!hasBeenInitialized) {
        _audioHandler = await platform_service.AudioService.init(
          builder: () => AppAudioService(settingsService, songService),
          config: const platform_service.AudioServiceConfig(
            androidNotificationChannelId: 'com.example.musicplayer',
            androidNotificationChannelName: 'Music Player',
            androidNotificationOngoing: true,
          ),
        );
        hasBeenInitialized = true;
      }
      await _audioHandler?.updateCurrentSong();
      await _audioHandler?.initSettings();
      await changeMediaItem();
      queueFuture = Future(() => _audioHandler?.getQueue());
      repeatNotifier.value = _audioHandler?.audioSettings.repeat ?? false;
      shuffleNotifier.value = _audioHandler?.audioSettings.shuffle ?? false;
      sliderNotifier.value = _audioHandler?.audioSettings.slider ?? 0;
      balanceNotifier.value = _audioHandler?.audioSettings.balance ?? 0.0;
      volumeNotifier.value = _audioHandler?.audioSettings.volume ?? 0.5;

      audioPlayer.onPositionChanged.listen((Duration event) {
        sliderNotifier.value = event.inMilliseconds;
        _audioHandler?.setSlider(event.inMilliseconds);
      });
      audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        playingNotifier.value = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          if (repeatNotifier.value) {
            debugPrint("Repeat is enabled, repeating song");
            repeat();
          } else {
            skipToNext();
          }
        }
      });
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
    debugPrint("play called, current song: ${currentSong.path}");
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
    //}
    await changeMediaItem();
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
    await changeMediaItem();
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
    sliderNotifier.value = position.inMilliseconds;
    if (Platform.isLinux){
      await _audioHandler?.seek(position);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.seek(position);
    // }
  }

  Future<void> repeat() async {
    if (Platform.isLinux){
      await _audioHandler?.repeat();
    }
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeedNotifier.value = speed;
    if (Platform.isLinux){
      _audioHandler?.setPlaybackSpeed(speed);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setPlaybackSpeed(speed);
    // }
  }

  void setVolume(double volume) {
    volumeNotifier.value = volume;
    if (Platform.isLinux){
      _audioHandler?.setVolume(volume);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setVolume(volume);
    // }
  }

  void setBalance(double balance) {
    balanceNotifier.value = balance;
    if (Platform.isLinux){
      _audioHandler?.setBalance(balance);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setBalance(balance);
    // }
  }

  void setRepeat(bool repeat) {
    repeatNotifier.value = repeat;
    if (Platform.isLinux){
      _audioHandler?.setRepeat(repeat);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setRepeat(repeat);
    // }
  }

  void setShuffle(bool shuffle) {
    shuffleNotifier.value = shuffle;
    if (Platform.isLinux){
      _audioHandler?.setShuffle(shuffle);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setShuffle(shuffle);
    // }
  }

  void setQueue(List<String> songs) {
    if (Platform.isLinux){
      _audioHandler?.setQueue(songs);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.setQueue(songs);
    // }
    queueFuture = Future(() => _audioHandler?.getQueue());
    notifyListeners();
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
    queueFuture = Future(() => _audioHandler?.getQueue());
    notifyListeners();
  }

  void addMultipleToQueue(List<String> songPaths) {
    if (Platform.isLinux){
      _audioHandler?.addMultipleToQueue(songPaths);
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.addMultipleToQueue(songPaths);
    // }
    queueFuture = Future(() => _audioHandler?.getQueue());
    notifyListeners();
  }

  void addNextToQueue(String songPath) {
    if (Platform.isLinux){
      _audioHandler?.addToQueueAtIndex(
        songPath,
        _audioHandler?.audioSettings.currentQueue.indexOf(currentSong.path) + 1
      );
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.addNextToQueue(songPath);
    // }
    queueFuture = Future(() => _audioHandler?.getQueue());
    notifyListeners();
  }

  void addMultipleNextToQueue(List<String> songPaths) {
    if (Platform.isLinux){
      _audioHandler?.addMultipleToQueueAtIndex(
        songPaths,
        _audioHandler?.audioSettings.currentQueue.indexOf(currentSong.path) + 1
      );
    }
    // else if (Platform.isWindows){
    //   final apc = AudioPlayerController();
    //   await apc.addMultipleNextToQueue(songPaths);
    // }
    queueFuture = Future(() => _audioHandler?.getQueue());
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
    queueFuture = Future(() => _audioHandler?.getQueue());
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
    await changeMediaItem();
    notifyListeners();
  }

  Future<void> changeMediaItem() async {
    File tempFile = await FileService.createWorkaroundFile(
        _audioHandler?.image ?? Uint8List(0), currentSong.id);
    if (Platform.isLinux) {
      platform_service.MediaItem item = platform_service.MediaItem(
          id: currentSong.id.toString(),
          album: currentSong.album,
          title: currentSong.name,
          artist: currentSong.trackArtist,
          duration: Duration(milliseconds: currentSong.duration),
          artUri: tempFile.uri
      );
      _audioHandler?.mediaItem.add(item);
    }
    // else if (Platform.isWindows){
    //   AppAudioHandler.audioHandler.updateMetadata(
    //     MusicMetadata(
    //       title: song.title,
    //       album: song.album,
    //       albumArtist: song.albumArtist,
    //       artist: song.trackArtist,
    //     ),
    //   );
    // }
  }

    // try{
    //   File lastFile = File(_filePath);
    //   if (lastFile.existsSync()) {
    //     lastFile.deleteSync();
    //   }
    //   _filePath = path;
    // }
    // catch(e){
    //   debugPrint(e.toString());
    // }
}
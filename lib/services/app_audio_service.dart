import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/entities/audio_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/file_service.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:musicplayer/services/song_service.dart';

class AppAudioService extends BaseAudioHandler {
  final AudioPlayer audioPlayer = AudioPlayer();
  AudioSettings audioSettings = AudioSettings();
  late final SettingsService settingsService;
  late final SongService songService;

  Song? currentSong = Song();
  ValueNotifier<bool> currentSongNotifier = ValueNotifier<bool>(false);
  Uint8List? image;


  AppAudioService(this.settingsService, this.songService) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      systemActions: {MediaAction.seek},
      playing: false,
    ));
    audioSettings = settingsService.getAudioSettings() ?? AudioSettings();
    debugPrint("Audio settings loaded: $audioSettings");
  }

  @override
  Future<void> play() async {
    debugPrint("play");
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    if (audioSettings.queue.isNotEmpty) {
      await audioPlayer.play(
        DeviceFileSource(audioSettings.currentQueue[
          audioSettings.index
        ]),
        position: Duration(milliseconds: audioSettings.slider),
        volume: audioSettings.volume,
        balance: audioSettings.balance,
      );
    }
  }

  @override
  Future<void> pause() async{
    debugPrint("pause");
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));
    await audioPlayer.pause();
  }

  @override
  Future<void> skipToNext() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToNext],
    ));
    await setCurrentIndex(audioSettings.currentQueue[
      (audioSettings.index + 1) % audioSettings.currentQueue.length
    ]);
  }

  @override
  Future<void> skipToPrevious() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToPrevious],
    ));
    if (audioSettings.slider < 3000) {
      await setCurrentIndex(audioSettings.currentQueue[
        (audioSettings.index - 1 + audioSettings.currentQueue.length) %
        audioSettings.currentQueue.length
      ]);
    }
    else {
      await seek(Duration.zero);
    }
  }

  Future<void> setCurrentIndex(String path) async {
    audioSettings.index = audioSettings.currentQueue.indexOf(path);
    settingsService.updateAudioSettings(audioSettings);
    await updateCurrentSong();
    seek(Duration.zero);
    play();
  }

  Future<void> repeat() async {
    currentSong?.lastPlayed = DateTime.now();
    currentSong?.playCount = (currentSong?.playCount ?? 0) + 1;
    songService.updateSong(currentSong!);
    seek(Duration.zero);
    play();
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint("seek to $position");
    setSlider(position.inMilliseconds);
    audioPlayer.seek(position);
  }

  void setVolume(double volume) {
    audioSettings.volume = volume;
    audioPlayer.setVolume(volume);
    settingsService.updateAudioSettings(audioSettings);
  }

  void setPlaybackSpeed(double speed) {
    audioPlayer.setPlaybackRate(speed);
  }

  void setBalance(double balance) {
    audioSettings.balance = balance;
    audioPlayer.setBalance(balance);
    settingsService.updateAudioSettings(audioSettings);
  }

  void setRepeat(bool repeat) {
    audioSettings.repeat = repeat;
    settingsService.updateAudioSettings(audioSettings);
  }

  void setShuffle(bool shuffle) {
    audioSettings.shuffle = shuffle;
    audioSettings.index = audioSettings.currentQueue.indexOf(
      currentSong?.path ?? audioSettings.queue[audioSettings.index]
    );
    settingsService.updateAudioSettings(audioSettings);
  }

  void setSlider(int slider) {
    audioSettings.slider = slider;
    settingsService.updateAudioSettings(audioSettings);
  }

  Future<void> initSettings() async {
    try {
      await audioPlayer.setSource(
        DeviceFileSource(currentSong?.path ?? ''),
      );
      await audioPlayer.seek(
        Duration(milliseconds: audioSettings.slider),
      );
      debugPrint("Audio player: ${await audioPlayer.getCurrentPosition()}");
    }
    catch (e) {
      debugPrint("Error initializing audio player: $e");
    }
  }

  Future<void> updateCurrentSong() async {
    if (audioSettings.queue.isEmpty) {
      debugPrint("Queue is empty, cannot update current song.");
      return;
    }
    currentSong = Song();
    String path = audioSettings.shuffle ?
        audioSettings.shuffledQueue[audioSettings.index] :
        audioSettings.queue[audioSettings.index];

    var metadata = await FileService.retrieveSong(path);
    currentSong?.fromJson(metadata);
    image = metadata['image'] as Uint8List?;
    Song? existingSong = songService.getSong(path);
    currentSong?.id = existingSong?.id ?? 0;
    currentSong?.lastPlayed = DateTime.now();
    currentSong?.playCount = (existingSong?.playCount ?? 0) + 1;
    debugPrint("Current song updated: ${currentSong?.name}, play count: ${currentSong?.playCount}");
    songService.updateSong(currentSong!);
    currentSongNotifier.value = !currentSongNotifier.value;
    changeMediaItem();
  }

  Future<void> changeMediaItem() async {
    File tempFile = await FileService.createWorkaroundFile(image ?? Uint8List(0), currentSong?.id ?? 0);
    if (Platform.isLinux) {
      MediaItem item = MediaItem(
          id: currentSong?.id.toString() ?? '-1',
          album: currentSong?.album ?? 'Unknown Album',
          title: currentSong?.name ?? 'Unknown Song',
          artist: currentSong?.trackArtist ?? 'Unknown Artist',
          duration: Duration(milliseconds: currentSong?.duration ?? 0),
          artUri: tempFile.uri
      );
      mediaItem.add(item);
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

  Future<Duration> getDuration() async {
    var duration = await audioPlayer.getDuration();
    debugPrint("Duration: $duration");
    if (duration == null) {
      // debugPrint("Duration is null, using current song duration, ${currentSong.duration})");
      return currentSong != null && currentSong!.duration > 0
          ? Duration(seconds: currentSong!.duration)
          : Duration.zero;
    }
    if (currentSong != null && currentSong!.duration <= 0) {
      currentSong!.duration = duration.inSeconds;
    }
    return duration;
  }

  void addToQueue(String songPath) {
    if (!audioSettings.queue.contains(songPath)) {
      audioSettings.queue.add(songPath);
      audioSettings.shuffledQueue.add(songPath);
      settingsService.updateAudioSettings(audioSettings);
    }
  }

  void addMultipleToQueue(List<String> songPaths) {
    for (String songPath in songPaths) {
      if (!audioSettings.queue.contains(songPath)) {
        audioSettings.queue.add(songPath);
        audioSettings.shuffledQueue.add(songPath);
      }
    }
    settingsService.updateAudioSettings(audioSettings);
  }

  void addToQueueAtIndex(String songPath, int index) {
    if (!audioSettings.queue.contains(songPath)) {
      audioSettings.queue.insert(index, songPath);
      audioSettings.shuffledQueue.insert(index, songPath);
      settingsService.updateAudioSettings(audioSettings);
    }
  }

  void addMultipleToQueueAtIndex(List<String> songPaths, int index) {
    for (String songPath in songPaths) {
      if (!audioSettings.queue.contains(songPath)) {
        audioSettings.queue.insert(index, songPath);
        audioSettings.shuffledQueue.insert(index, songPath);
        index++;
      }
    }
    settingsService.updateAudioSettings(audioSettings);
  }

  void removeFromQueue(String songPath) {
    if (audioSettings.queue.contains(songPath)) {
      audioSettings.queue.remove(songPath);
      audioSettings.shuffledQueue.remove(songPath);
      settingsService.updateAudioSettings(audioSettings);

    }
  }

  void setQueue(List<String> songs) async {
    if (audioSettings.queue.equals(songs)) {
      return;
    }
    audioSettings.queue = List.from(songs);
    audioSettings.shuffledQueue = List.from(songs);
    audioSettings.shuffledQueue.shuffle();
  }

  Future<List<Song>> getQueue() async {
    List<Song> queueSongs = [];
    for (String path in audioSettings.queue) {
      Song? song = songService.getSong(path);
      if (song != null) {
        queueSongs.add(song);
      } else {
        debugPrint("Song not found in service: $path");
        var metadata = await FileService.retrieveSong(path);
        song = Song();
        song.fromJson(metadata);
        songService.songRepo.addSong(song);
        queueSongs.add(song);
      }
    }
    return queueSongs;
  }

}
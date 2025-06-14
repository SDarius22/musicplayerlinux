import 'dart:typed_data';

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

  int previousIndex = 0;

  Song? currentSong = Song();
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
    previousIndex = audioSettings.index - 1 < 0
        ? audioSettings.queue.length - 1
        : audioSettings.index - 1;
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
        DeviceFileSource(audioSettings.queue[audioSettings.index]),
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
    await seek(Duration.zero);
    previousIndex = audioSettings.index;
    audioSettings.index = (audioSettings.index + 1) % audioSettings.queue.length;
    settingsService.updateAudioSettings(audioSettings);
    await updateCurrentSong();
    await play();
  }

  @override
  Future<void> skipToPrevious() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToPrevious],
    ));
    await seek(Duration.zero);
    if (!audioSettings.repeat) {
      previousIndex = audioSettings.index;
      audioSettings.index = (audioSettings.index - 1 + audioSettings.queue.length) % audioSettings.queue.length;
      settingsService.updateAudioSettings(audioSettings);
      await updateCurrentSong();
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    debugPrint("seek to $position");
    audioSettings.slider = position.inMilliseconds;
    settingsService.updateAudioSettings(audioSettings);
    await audioPlayer.seek(position);
  }

  void setVolume(double volume) {
    audioSettings.volume = volume;
    audioPlayer.setVolume(volume);
    settingsService.updateAudioSettings(audioSettings);
    
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
    settingsService.updateAudioSettings(audioSettings);
    
  }

  void setSlider(int slider) {
    audioSettings.slider = slider;
    settingsService.updateAudioSettings(audioSettings);
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
    debugPrint("Image size: ${image?.lengthInBytes ?? 0} bytes");
  }

  Future<void> setCurrentIndex(String path) async {
    audioSettings.index = audioSettings.currentQueue.indexOf(path);
    audioSettings.slider = 0; // Reset the slider to the beginning
    settingsService.updateAudioSettings(audioSettings);
    await updateCurrentSong();
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
    return duration;
  }

  void addToQueue(String songPath) {
    if (!audioSettings.queue.contains(songPath)) {
      audioSettings.queue.add(songPath);
      audioSettings.shuffledQueue = List.from(audioSettings.queue);
      settingsService.updateAudioSettings(audioSettings);
    }
  }

  void removeFromQueue(String songPath) {
    if (audioSettings.queue.contains(songPath)) {
      audioSettings.queue.remove(songPath);
      audioSettings.shuffledQueue = List.from(audioSettings.queue);
      settingsService.updateAudioSettings(audioSettings);

    }
  }

  void setQueue(List<String> songs) async {
    if (audioSettings.queue == songs) {
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
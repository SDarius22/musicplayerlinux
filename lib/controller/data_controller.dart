import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/audio_player_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/controller/worker_controller.dart';

import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/playlist_type.dart';
import '../domain/song_type.dart';
import '../repository/objectBox.dart';
import '../repository/objectbox.g.dart';

class DataController {
  static final DataController _instance = DataController._internal();

  factory DataController() => _instance;

  DataController._internal();

  static get albumBox => ObjectBox.store.box<AlbumType>();
  static get artistBox => ObjectBox.store.box<ArtistType>();
  static get playlistBox => ObjectBox.store.box<PlaylistType>();
  static get songBox => ObjectBox.store.box<SongType>();

  static void init() {
    // initialize the data controller
  }

  static void reset() {
    ObjectBox.store.box<AlbumType>().removeAll();
    ObjectBox.store.box<ArtistType>().removeAll();
    ObjectBox.store.box<PlaylistType>().removeAll();
    ObjectBox.store.box<SongType>().removeAll();
  }

  static Future<List<AlbumType>> getAlbums(String searchValue) async {
    return ObjectBox.store.box<AlbumType>()
        .query(AlbumType_.name.contains(searchValue, caseSensitive: false))
        .order(AlbumType_.name)
        .build()
        .find();
  }

  static Future<List<ArtistType>> getArtists(String searchValue) async {
    return ObjectBox.store.box<ArtistType>()
        .query(ArtistType_.name.contains(searchValue, caseSensitive: false))
        .order(ArtistType_.name)
        .build()
        .find();
  }

  static Future<Duration> getDuration(SongType song) async {
    try {
      if (song.duration != 0) {
        return Duration(seconds: song.duration);
      } else {
        Duration songDuration = await AudioPlayerController.audioPlayer.getDuration() ?? Duration.zero;
        song.duration = songDuration.inSeconds;
        songBox.put(song);
        return songDuration;
      }
    } catch (e) {
      debugPrint(e.toString());
      // return Duration.zero;
      return await AudioPlayerController.audioPlayer.getDuration() ?? Duration.zero;
    }
  }

  static Future<List<String>> getLyrics(String path) async {
    var song = ObjectBox.store.box<SongType>().query(SongType_.path.equals(path)).build().findFirst();
    if (song == null) {
      return ["No lyrics found", "No lyrics found"];
    } else {
      if (song.lyricsPath.isEmpty) {
        try {
          // return await searchLyrics(path);
          return ["No lyrics found", "No lyrics found"];
        } catch (e) {
          debugPrint(e.toString());
          return ["No lyrics found", "No lyrics found"];
        }
      } else {
        return [File(song.lyricsPath).readAsStringSync(), File(song.lyricsPath).readAsStringSync()];
      }
    }
  }

  static Future<PlaylistType> getPlaylist(String name) async {
    return playlistBox.query(PlaylistType_.name.equals(name)).build().findFirst();
  }

  static Future<List<PlaylistType>> getPlaylists(String searchValue) async {
    return ObjectBox.store.box<PlaylistType>()
        .query(PlaylistType_.name.contains(searchValue, caseSensitive: false))
        .order(PlaylistType_.indestructible, flags: Order.descending)
        .order(PlaylistType_.name)
        .build()
        .find();
  }

  static Future<List<SongType>> getQueue() async {
    List<SongType> metadataQueue = [];
    for (String path in SettingsController.queue) {
      var song = songBox.query(SongType_.path.equals(path)).build().findFirst();
      if (song != null) {
        metadataQueue.add(song);
      } else {
        metadataQueue.add(await getSong(path));
      }
    }
    return metadataQueue;
  }

  static Future<SongType> getSong(String path) async {
    var song = ObjectBox.store.box<SongType>().query(SongType_.path.equals(path)).build().findFirst();
    if (song != null) {
      debugPrint(song.duration.toString());

    } else {
      song = await WorkerController.retrieveSong(path);
      await WorkerController.makeAlbumArtist(song);
      ObjectBox.store.box<SongType>().put(song);
    }
    return song;
  }

  static Future<List<SongType>> getSongs(String searchValue, [int? limit]) async {
    return songBox
        .query(SongType_.title.contains(searchValue, caseSensitive: false) |
    SongType_.artists.contains(searchValue, caseSensitive: false) |
    SongType_.album.contains(searchValue, caseSensitive: false))
        .order(SongType_.title)
        .build()
        .find();

  }

  Future<void> addToPlaylist(PlaylistType playlist, List<SongType> songs) async {
    if (playlist.nextAdded == 'last') {
      for (var song in songs) {
        if (playlist.paths.contains(song.path)) {
          continue;
        }
        playlist.paths.add(song.path);
        playlist.duration += song.duration;
        bool found = false;
        for (var artistCountStr in playlist.artistCount){
          if (artistCountStr.contains(song.artists)){
            int count = int.parse(artistCountStr.split(" - ")[1]);
            count += 1;
            playlist.artistCount.remove(artistCountStr);
            playlist.artistCount.add("${song.artists} - $count");
            found = true;
            break;
          }
        }
        if (!found){
          playlist.artistCount.add("${song.artists} - 1");
        }
      }
      playlistBox.put(playlist);
    } else {
      for (int i = songs.length - 1; i >= 0; i--) {
        if (playlist.paths.contains(songs[i].path)) {
          continue;
        }
        playlist.paths.insert(0, songs[i].path);
        playlist.duration += songs[i].duration;
        bool found = false;
        for (var artistCountStr in playlist.artistCount){
          if (artistCountStr.contains(songs[i].artists)){
            int count = int.parse(artistCountStr.split(" - ")[1]);
            count += 1;
            playlist.artistCount.remove(artistCountStr);
            playlist.artistCount.add("${songs[i].artists} - $count");
            found = true;
            break;
          }
        }
        if (!found){
          playlist.artistCount.add("${songs[i].artists} - 1");
        }
      }
      playlistBox.put(playlist);
    }
    exportPlaylist(playlist);
  }

  Future<void> removeFromPlaylist(PlaylistType playlist, String song) async {
    try {
      playlist.paths.remove(song);
      playlist.duration -= (await getDuration(await getSong(song))).inSeconds;
      playlistBox.put(playlist);
      exportPlaylist(playlist);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addToQueue(List<String> songs) async {
    debugPrint("Adding to queue ${songs.length} songs.");
    if (SettingsController.queueAdd == 'last') {
      SettingsController.queue = List<String>.from(SettingsController.queue)..addAll(songs);
    } else if (SettingsController.queueAdd == 'next') {
      SettingsController.queue = List<String>.from(SettingsController.queue)..insertAll(SettingsController.index + 1, songs);
    }
  }

  Future<void> createPlaylist(PlaylistType playlist) async {
    playlistBox.put(playlist);
    exportPlaylist(playlist);
  }

  Future<void> deletePlaylist(PlaylistType playlist) async {
    playlistBox.remove(playlist.id);
    try {
      var file = File("${SettingsController.directory}/${playlist.name}.m3u");
      file.delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> exportPlaylist(PlaylistType playlist) async {
    var file = File("${SettingsController.directory}/${playlist.name}.m3u");
    file.writeAsStringSync("#EXTM3U\n");
    for (var song in playlist.paths) {
      file.writeAsStringSync('$song\n', mode: FileMode.append);
    }
  }

  Future<void> removeFromQueue(String song) async {
    if (SettingsController.shuffledQueue.length == 1) {
      debugPrint("The queue cannot be empty");
      final am = AppManager();
      am.showNotification("The queue cannot be empty", 3000);
      return;
    }
    String currentSong = SettingsController.currentSongPath;
    SettingsController.queue = List<String>.from(SettingsController.queue)..remove(song);
    if (!SettingsController.queue.contains(currentSong)) {
      SettingsController.index = 0;
    } else {
      SettingsController.index = SettingsController.currentQueue.indexOf(currentSong);
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    String song = SettingsController.queue.removeAt(oldIndex);
    SettingsController.queue.insert(newIndex, song);
    if (oldIndex == SettingsController.index) {
      SettingsController.index = newIndex;
    } else if (oldIndex < SettingsController.index && newIndex >= SettingsController.index) {
      SettingsController.index -= 1;
    } else if (oldIndex > SettingsController.index && newIndex <= SettingsController.index) {
      SettingsController.index += 1;
    }
  }

  Future<void> updateLiked(SongType song) async {
    song.liked = !song.liked;
    if (song.liked) {
      PlaylistType favs = await DataController.getPlaylist("Favorites");
      await addToPlaylist(favs, [song]);
    } else {
      PlaylistType favs = await DataController.getPlaylist("Favorites");
      await removeFromPlaylist(favs, song.path);
    }
    songBox.put(song);
  }

  static Future<void> updateIndestructible() async {
    await updateMostPlayed();
    await updateRecentlyPlayed();
  }

  static Future<void> updatePlayed(SongType song) async {
    song.playCount += 1;
    songBox.put(song);
  }

  static Future<void> updateMostPlayed() async {
    PlaylistType mostPlayed = await DataController.getPlaylist("Most Played");
    var query = songBox.query(SongType_.playCount.greaterThan(0)).order(SongType_.playCount, flags: Order.descending).build();
    query.limit = 100;
    var songs = query.find();
    mostPlayed.artistCount = [];
    mostPlayed.paths = [];
    mostPlayed.duration = 0;
    for (var song in songs) {
      mostPlayed.paths.add(song.path);
      int duration = song.duration + mostPlayed.duration;
      mostPlayed.duration = duration;
      bool found = false;
      for (var artistCountStr in mostPlayed.artistCount){
        if (artistCountStr.contains(song.artists)){
          int count = int.parse(artistCountStr.split(" - ")[1]);
          count += 1;
          mostPlayed.artistCount.remove(artistCountStr);
          mostPlayed.artistCount.add("${song.artists} - $count");
          found = true;
          break;
        }
      }
      if (!found){
        mostPlayed.artistCount.add("${song.artists} - 1");
      }
    }

    playlistBox.put(mostPlayed);
  }

  static Future<void> updateLastPlayed(SongType song) async {
    song.lastPlayed = DateTime.now();
    songBox.put(song);
  }

  static Future<void> updateRecentlyPlayed() async {
    PlaylistType recentlyPlayed = await DataController.getPlaylist("Recently Played");
    var query = songBox.query(SongType_.lastPlayed.notNull()).order(SongType_.lastPlayed, flags: Order.descending).build();
    query.limit = 100;
    var songs = query.find();
    recentlyPlayed.artistCount = [];
    recentlyPlayed.paths = [];
    recentlyPlayed.duration = 0;
    for (var song in songs) {
      recentlyPlayed.paths.add(song.path);
      int duration = song.duration + recentlyPlayed.duration;
      recentlyPlayed.duration = duration;
      bool found = false;
      for (var artistCountStr in recentlyPlayed.artistCount){
        if (artistCountStr.contains(song.artists)){
          int count = int.parse(artistCountStr.split(" - ")[1]);
          count += 1;
          recentlyPlayed.artistCount.remove(artistCountStr);
          recentlyPlayed.artistCount.add("${song.artists} - $count");
          found = true;
          break;
        }
      }
      if (!found){
        recentlyPlayed.artistCount.add("${song.artists} - 1");
      }
    }
    playlistBox.put(recentlyPlayed);
  }

  Future<void> updatePlaying(List<String> songs, int newIndex) async {
    if (SettingsController.queuePlay == 'all') {
      SettingsController.queue = songs;
      SettingsController.index = newIndex;
    } else {
      addToQueue([songs[newIndex]]);
    }
  }

}
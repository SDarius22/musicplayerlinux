import 'dart:io';

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
      print(e);
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
          print(e);
          return ["No lyrics found", "No lyrics found"];
        }
      } else {
        return [File(song.lyricsPath).readAsStringSync(), File(song.lyricsPath).readAsStringSync()];
      }
    }
  }

  static Future<List<PlaylistType>> getPlaylists(String searchValue) async {
    return ObjectBox.store.box<PlaylistType>()
        .query(PlaylistType_.name.contains(searchValue, caseSensitive: false))
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
      print(song.duration);

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
      }
      playlistBox.put(playlist);
    } else {
      for (int i = songs.length - 1; i >= 0; i--) {
        if (playlist.paths.contains(songs[i].path)) {
          continue;
        }
        playlist.paths.insert(0, songs[i].path);
      }
      playlistBox.put(playlist);
    }
    exportPlaylist(playlist);
  }

  Future<void> addToQueue(List<String> songs) async {
    print("Adding to queue ${songs.length} songs.");
    if (SettingsController.queueAdd == 'last') {
      final updatedQueue = List<String>.from(SettingsController.queue)..addAll(songs);
      final updatedControllerQueue = List<String>.from(SettingsController.shuffledQueue)..addAll(songs);
      SettingsController.queue = updatedQueue;
      SettingsController.shuffledQueue = updatedControllerQueue;
    } else if (SettingsController.queueAdd == 'next') {
      final updatedQueue = List<String>.from(SettingsController.queue)..insertAll(SettingsController.index + 1, songs);
      final updatedControllerQueue = List<String>.from(SettingsController.shuffledQueue)..insertAll(SettingsController.index + 1, songs);
      SettingsController.queue = updatedQueue;
      SettingsController.shuffledQueue = updatedControllerQueue;
    } else if (SettingsController.queueAdd == 'first') {
      final updatedQueue = List<String>.from(SettingsController.queue)..insertAll(0, songs)..insertAll(0, songs);
      final updatedControllerQueue = List<String>.from(SettingsController.shuffledQueue)..insertAll(0, songs)..insertAll(0, songs);
      SettingsController.queue = updatedQueue;
      SettingsController.shuffledQueue = updatedControllerQueue;
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
      print(e);
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
      print("The queue cannot be empty");
      return;
    }

    final List<String> updatedQueue = List<String>.from(SettingsController.queue)..remove(song);
    final List<String> updatedControllerQueue = List<String>.from(SettingsController.shuffledQueue)..remove(song);
    SettingsController.queue = updatedQueue;
    SettingsController.shuffledQueue = updatedControllerQueue;
    if (!SettingsController.queue.contains(SettingsController.currentSongPath)) {
      SettingsController.index = 0;
    } else {
      SettingsController.index = SettingsController.queue.indexOf(SettingsController.currentSongPath);
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

  Future<void> updatePlaying(List<String> songs, int newIndex) async {
    if (SettingsController.queuePlay == 'all') {
      SettingsController.queue = songs;
      SettingsController.index = newIndex;
    } else {
      addToQueue([songs[newIndex]]);
    }
  }

}
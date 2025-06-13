import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/repository/playlist_repo.dart';
import 'package:musicplayer/services/song_service.dart';

class PlaylistService {
  final PlaylistRepository playlistRepo;
  final SongService songService;

  PlaylistService(this.playlistRepo, this.songService);

  Future<void> addPlaylist(String name, List<String> songs) async {
    if (name.isEmpty) {
      throw ArgumentError("Playlist name cannot be empty");
    }
    if (songs.isEmpty) {
      throw ArgumentError("Playlist must contain at least one song");
    }
    // Check if the playlist already exists
    final existingPlaylist =  playlistRepo.getPlaylist(name);
    if (existingPlaylist != null) {
      throw Exception("Playlist with name '$name' already exists");
    }
    Playlist newPlaylist = Playlist();
    newPlaylist.name = name;
    newPlaylist.pathsInOrder = List<String>.from(songs);
    try {
       playlistRepo.addPlaylist(newPlaylist);
    } catch (e) {
      debugPrint("Error adding playlist: $e");
    }
  }

  Future<Playlist?> getPlaylist(String name) async {
    if (name.isEmpty) {
      throw ArgumentError("Playlist name cannot be empty");
    }
    try {
      return  playlistRepo.getPlaylist(name);
    } catch (e) {
      debugPrint("Error fetching playlist: $e");
      return null;
    }
  }

  void initializeIndestructible() {
    Playlist mostPlayed = Playlist();
    mostPlayed.name = "Most Played";
    mostPlayed.pathsInOrder = [];
    mostPlayed.artistCount = [];
    mostPlayed.duration = 0;
    mostPlayed.indestructible = true;
    Playlist recentlyPlayed = Playlist();
    recentlyPlayed.name = "Recently Played";
    recentlyPlayed.pathsInOrder = [];
    recentlyPlayed.artistCount = [];
    recentlyPlayed.duration = 0;
    recentlyPlayed.indestructible = true;
    Playlist favorites = Playlist();
    favorites.name = "Favorites";
    favorites.pathsInOrder = [];
    favorites.artistCount = [];
    favorites.duration = 0;
    favorites.indestructible = true;
    playlistRepo.addPlaylist(mostPlayed);
    playlistRepo.addPlaylist(recentlyPlayed);
    playlistRepo.addPlaylist(favorites);
  }

  Future<List<Playlist>> getIndestructiblePlaylists() async {
    try {
      return  playlistRepo.getIndestructiblePlaylists();
    } catch (e) {
      debugPrint("Error fetching indestructible playlists: $e");
      return [];
    }
  }

  Future<List<Playlist>> getPlaylists(String query, String sortField, bool flag, int currentPage, int perPage) async {
    try {
      return  playlistRepo.getPlaylists(query, sortField, flag, currentPage, perPage);
    } catch (e) {
      debugPrint("Error fetching playlists: $e");
      return [];
    }
  }

  Future<void> addToPlaylist(Playlist playlist, List<Song> songs) async {
    if (playlist.nextAdded == 'last') {
      for (var song in songs) {
        if (playlist.pathsInOrder.contains(song.path)) {
          continue;
        }
        playlist.pathsInOrder.add(song.path);
        playlist.duration += song.duration;
        bool found = false;
        for (var artistCountStr in playlist.artistCount){
          if (artistCountStr.contains(song.trackArtist)){
            int count = int.parse(artistCountStr.split(" - ")[1]);
            count += 1;
            playlist.artistCount.remove(artistCountStr);
            playlist.artistCount.add("${song.trackArtist} - $count");
            found = true;
            break;
          }
        }
        if (!found){
          playlist.artistCount.add("${song.trackArtist} - 1");
        }
      }
      playlistRepo.updatePlaylist(playlist);
    } else {
      for (int i = songs.length - 1; i >= 0; i--) {
        if (playlist.pathsInOrder.contains(songs[i].path)) {
          continue;
        }
        playlist.pathsInOrder.insert(0, songs[i].path);
        playlist.duration += songs[i].duration;
        bool found = false;
        for (var artistCountStr in playlist.artistCount){
          if (artistCountStr.contains(songs[i].trackArtist)){
            int count = int.parse(artistCountStr.split(" - ")[1]);
            count += 1;
            playlist.artistCount.remove(artistCountStr);
            playlist.artistCount.add("${songs[i].trackArtist} - $count");
            found = true;
            break;
          }
        }
        if (!found){
          playlist.artistCount.add("${songs[i].trackArtist} - 1");
        }
      }
      playlistRepo.updatePlaylist(playlist);
    }
    // exportPlaylist(playlist);
  }

  Future<void> deleteFromPlaylist(Playlist playlist, String song) async {
    if (!playlist.pathsInOrder.contains(song)) {
      throw Exception("Song not found in playlist");
    }
    try {
      playlist.pathsInOrder.remove(song);
      Song? songObj = await songService.getSong(song);
      if (songObj == null) {
        throw Exception("Song object not found for path: $song");
      }
      playlist.duration -= songObj.duration;
      for (var artistCountStr in playlist.artistCount){
        if (artistCountStr.contains(songObj.trackArtist)){
          int count = int.parse(artistCountStr.split(" - ")[1]);
          count -= 1;
          playlist.artistCount.remove(artistCountStr);
          if (count > 0) {
            playlist.artistCount.add("${songObj.trackArtist} - $count");
          }
          break;
        }
      }
      playlistRepo.updatePlaylist(playlist);
    }
    catch (e) {
      debugPrint("Error removing song from playlist: $e");
    }
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    if (playlist.id == 0) {
      throw ArgumentError("Playlist ID cannot be zero");
    }
    try {
       playlistRepo.deletePlaylist(playlist);
      // Optionally, delete the associated file if it exists
      // var file = File("${FileService.mainSongPlace}/${playlist.name}.m3u");
      // if (file.existsSync()) {
      //   file.deleteSync();
      // }
    } catch (e) {
      debugPrint("Error deleting playlist: $e");
    }
  }

  Future<void> updateIndestructible() async {
     updateMostPlayed();
     updateRecentlyPlayed();
  }

  Future<void> updateMostPlayed() async {
    Playlist? mostPlayed =  playlistRepo.getPlaylist("Most Played");
    if (mostPlayed == null) {
      mostPlayed = Playlist();
      mostPlayed.name = "Most Played";
      mostPlayed.pathsInOrder = [];
      mostPlayed.artistCount = [];
      mostPlayed.duration = 0;
    }
    // var query = songBox.query(Song_.playCount.greaterThan(0)).order(Song_.playCount, flags: Order.descending).build();
    // query.limit = 100;
    var songs = await songService.getSongsWithPlayCount();
    mostPlayed.artistCount = [];
    mostPlayed.pathsInOrder = [];
    mostPlayed.duration = 0;
    for (var song in songs) {
      mostPlayed.pathsInOrder.add(song.path);
      int duration = song.duration + mostPlayed.duration;
      mostPlayed.duration = duration;
      bool found = false;
      for (var artistCountStr in mostPlayed.artistCount){
        if (artistCountStr.contains(song.trackArtist)){
          int count = int.parse(artistCountStr.split(" - ")[1]);
          count += 1;
          mostPlayed.artistCount.remove(artistCountStr);
          mostPlayed.artistCount.add("${song.trackArtist} - $count");
          found = true;
          break;
        }
      }
      if (!found){
        mostPlayed.artistCount.add("${song.trackArtist} - 1");
      }
    }
    playlistRepo.updatePlaylist(mostPlayed);
  }

  Future<void> updateRecentlyPlayed() async {
    Playlist? recentlyPlayed =  playlistRepo.getPlaylist("Recently Played");
    if (recentlyPlayed == null) {
      recentlyPlayed = Playlist();
      recentlyPlayed.name = "Recently Played";
      recentlyPlayed.pathsInOrder = [];
      recentlyPlayed.artistCount = [];
      recentlyPlayed.duration = 0;
    }
    // var query = songBox.query(Song_.lastPlayed.notNull()).order(Song_.lastPlayed, flags: Order.descending).build();
    // query.limit = 100;
    var songs = await songService.getSongsWithLastPlayed();
    recentlyPlayed.artistCount = [];
    recentlyPlayed.pathsInOrder = [];
    recentlyPlayed.duration = 0;
    for (var song in songs) {
      recentlyPlayed.pathsInOrder.add(song.path);
      int duration = song.duration + recentlyPlayed.duration;
      recentlyPlayed.duration = duration;
      bool found = false;
      for (var artistCountStr in recentlyPlayed.artistCount){
        if (artistCountStr.contains(song.trackArtist)){
          int count = int.parse(artistCountStr.split(" - ")[1]);
          count += 1;
          recentlyPlayed.artistCount.remove(artistCountStr);
          recentlyPlayed.artistCount.add("${song.trackArtist} - $count");
          found = true;
          break;
        }
      }
      if (!found){
        recentlyPlayed.artistCount.add("${song.trackArtist} - 1");
      }
    }
    playlistRepo.updatePlaylist(recentlyPlayed);
  }
}
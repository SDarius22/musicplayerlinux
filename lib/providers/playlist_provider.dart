import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/playlist_service.dart';

class PlaylistProvider with ChangeNotifier {
  final PlaylistService _playlistService;

  bool isAscending = false;
  String query = '';
  String sortField = 'Name'; // Name, Duration, Number of Songs, Created At

  late Future playlistsFuture;

  PlaylistProvider(this._playlistService) {
    playlistsFuture = Future(() => _playlistService.getAllPlaylists());

    playlistsStream.listen((_) {
      debugPrint("Playlists stream updated");
      playlistsFuture = Future(() => _playlistService.getPlaylists(query, sortField, isAscending));
      notifyListeners();
    });
  }

  Stream get playlistsStream => _playlistService.watchPlaylists();

  void setFlag(bool value) {
    isAscending = value;
    playlistsFuture = Future(() => _playlistService.getPlaylists(query, sortField, isAscending));
    notifyListeners();
  }

  void setSortField(String field) {
    sortField = field;
    playlistsFuture = Future(() => _playlistService.getPlaylists(query, sortField, isAscending));
    notifyListeners();
  }

  void setQuery(String newQuery) {
    query = newQuery;
    playlistsFuture = Future(() => _playlistService.getPlaylists(query, sortField, isAscending));
    notifyListeners();
  }

  void addPlaylist(String name, List<String> songs, String whereToAdd, Uint8List? coverArt) {
    _playlistService.addPlaylist(name, songs, whereToAdd, coverArt);
    notifyListeners();
  }

  void deletePlaylist(Playlist playlist) {
    _playlistService.deletePlaylist(playlist);
    notifyListeners();
  }

  Playlist? getPlaylist(String name) {
    return _playlistService.getPlaylist(name);
  }

  List<Playlist> getIndestructiblePlaylists() {
    return _playlistService.getIndestructiblePlaylists();
  }

  List<Playlist> getNormalPlaylists() {
    return _playlistService.getNormalPlaylists();
  }

  List<Playlist> getPlaylists() {
    return _playlistService.getPlaylists(query, sortField, isAscending);
  }


  void addSongsToPlaylist(Playlist playlist, List<Song> songs) {
    _playlistService.addToPlaylist(playlist, songs);
    notifyListeners();
  }

  void deleteSongFromPlaylist(Playlist playlist, Song song) {
    _playlistService.deleteFromPlaylist(playlist, song.path);
    notifyListeners();
  }
}
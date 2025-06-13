import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/playlist_service.dart';

class PlaylistProvider with ChangeNotifier {
  final PlaylistService _playlistService;
  int currentPage = 1;
  int perPage = 7;
  bool flag = false;
  String sortField = 'name'; // name or createdAt

  PlaylistProvider(this._playlistService);

  void resetPage() {
    currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setPerPage(int count) {
    perPage = count;
    notifyListeners();
  }

  void setFlag(bool value) {
    flag = value;
    notifyListeners();
  }

  void setSortField(String field) {
    sortField = field;
    notifyListeners();
  }

  void initializeIndestructible() {
    _playlistService.initializeIndestructible();
    notifyListeners();
  }

  Future<void> addPlaylist(String name, List<String> songs) async {
    await _playlistService.addPlaylist(name, songs);
    notifyListeners();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _playlistService.deletePlaylist(playlist);
    notifyListeners();
  }

  Future<Playlist?> getPlaylist(String name) async {
    return await _playlistService.getPlaylist(name);
  }

  Future<List<Playlist>> getIndestructiblePlaylists() async {
    return await _playlistService.getIndestructiblePlaylists();
  }

  Future<List<Playlist>> getPlaylists(String query) async {
    return await _playlistService.getPlaylists(query, sortField, flag, currentPage, perPage);
  }

  Future<void> addSongsToPlaylist(Playlist playlist, List<Song> songs) async {
    await _playlistService.addToPlaylist(playlist, songs);
    notifyListeners();
  }

  Future<void> deleteSongFromPlaylist(Playlist playlist, Song song) async {
    await _playlistService.deleteFromPlaylist(playlist, song.path);
    notifyListeners();
  }

  Future<void> updateIndestructiblePlaylists() async {
    await _playlistService.updateIndestructible();
    notifyListeners();
  }


}
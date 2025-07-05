import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/services/song_service.dart';
import 'package:rxdart/rxdart.dart';

class SongProvider with ChangeNotifier {
  final SongService _songService;

  bool isAscending = false;
  String query = '';
  String sortField = 'Name'; // Name or Duration

  bool _finishedLoading  = true;

  late Future songsFuture;

  SongProvider(this._songService) {
    songsFuture = Future(() => _songService.getAllSongs());


    songsStream.throttleTime(const Duration(seconds: 10)).listen((_) {
      if (!_finishedLoading) {
        debugPrint("Songs stream updated");
        songsFuture = Future(() => _songService.getSongs(query, sortField, isAscending));
        notifyListeners();
      }
    });

    fileChangesStream.throttleTime(const Duration(seconds: 10)).listen((event) {
      debugPrint("File changes detected $event");
      notifyListeners();
    });
    

  }

  Stream get songsStream => _songService.watchSongs();
  Stream get fileChangesStream => _songService.fileChangesStream();

  void setFlag(bool value) {
    isAscending = value;
    songsFuture = Future(() => _songService.getSongs(query, sortField, isAscending));
    notifyListeners();
  }

  void setSortField(String field) {
    sortField = field;
    songsFuture = Future(() => _songService.getSongs(query, sortField, isAscending));
    notifyListeners();
  }

  void setQuery(String newQuery) {
    query = newQuery;
    songsFuture = Future(() => _songService.getSongs(query, sortField, isAscending));
    notifyListeners();
  }

  void addSong(String songPath) {
    _songService.addSong(songPath);
    notifyListeners();
  }

  void removeSong(Song song) {
    _songService.deleteSong(song);
    notifyListeners();
  }

  void updateSong(Song song) {
    _songService.updateSong(song);
    notifyListeners();
  }

  Song? getSong(String songPath) {
    return _songService.getSong(songPath);
  }

  Song? getSongContaining(String query) {
    return _songService.getSongContaining(query);
  }

  List<Song> getSongs(String query, String sortField, bool flag) {
    return _songService.getSongs(query, sortField, flag);
  }

  List<Song> getSongsFromPaths(List<String> paths) {
    return _songService.getSongsFromPaths(paths);
  }

  List<Song> getAllSongs() {
    return _songService.getAllSongs();
  }

  Future<void> startLoadingSongs() async {
    _finishedLoading = false;
    debugPrint("Loading songs...");
    try {
      await _songService.retrieveAllSongs();
    } catch (e) {
      debugPrint("Error loading songs: $e");
    }
    _finishedLoading = true;
  }
}
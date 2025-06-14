import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/services/album_service.dart';
import 'package:rxdart/rxdart.dart';

class AlbumProvider with ChangeNotifier {
  final AlbumService _albumService;

  bool isAscending = false;
  String query = '';
  String sortField = 'Name'; // Name, Duration, Number of Songs

  late Future albumsFuture;

  AlbumProvider(this._albumService) {
    albumsFuture = Future(() => _albumService.getAllAlbums());

    albumsStream.debounceTime(const Duration(seconds: 10)).listen((_) {
      debugPrint("Albums stream updated");
      albumsFuture = Future(() => _albumService.getAlbums(query, sortField, isAscending));
      notifyListeners();
    });

  }

  Stream get albumsStream => _albumService.watchAlbums();

  void setFlag(bool value) {
    isAscending = value;
    albumsFuture = Future(() => _albumService.getAlbums(query, sortField, isAscending));
    notifyListeners();
  }

  void setSortField(String field) {
    sortField = field;
    albumsFuture = Future(() => _albumService.getAlbums(query, sortField, isAscending));
    notifyListeners();
  }

  void setQuery(String newQuery) {
    query = newQuery;
    albumsFuture = Future(() => _albumService.getAlbums(query, sortField, isAscending));
    notifyListeners();
  }

  void addAlbum(String name)  {
    _albumService.addAlbum(name);
    notifyListeners();
  }

  void deleteAlbum(Album album)  {
     _albumService.deleteAlbum(album);
    notifyListeners();
  }

  void updateAlbum(Album album)  {
    _albumService.updateAlbum(album);
    notifyListeners();
  }

  Album? getAlbum(String name)  {
    return _albumService.getAlbum(name);
  }

  List<Album> getAlbums()  {
    return _albumService.getAlbums(query, sortField, isAscending);
  }

  List<Album> getAllAlbums()  {
    return _albumService.getAllAlbums();
  }


}
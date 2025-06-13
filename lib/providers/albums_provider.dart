import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/services/album_service.dart';

class AlbumProvider with ChangeNotifier {
  final AlbumService _albumService;
  int currentPage = 1;
  int perPage = 7;
  bool flag = false;

  AlbumProvider(this._albumService);

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

  Future<void> addAlbum(String name) async {
    await _albumService.addAlbum(name);
    notifyListeners();
  }

  Future<void> deleteAlbum(Album album) async {
    await _albumService.deleteAlbum(album);
    notifyListeners();
  }

  Future<void> updateAlbum(Album album) async {
    await _albumService.updateAlbum(album);
    notifyListeners();
  }

  Future<Album?> getAlbum(String name) async {
    return await _albumService.getAlbum(name);
  }

  Future<List<Album>> getAlbums(String query) async {
    return await _albumService.getAlbums(query, flag, currentPage, perPage);
  }

  Future<List<Album>> getAllAlbums() async {
    return await _albumService.getAllAlbums();
  }


}
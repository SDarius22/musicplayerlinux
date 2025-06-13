import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/artist.dart';
import 'package:musicplayer/services/artist_service.dart';

class ArtistProvider with ChangeNotifier {
  final ArtistService _artistService;
  int currentPage = 1;
  int perPage = 7;
  bool flag = false;

  ArtistProvider(this._artistService);

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

  Future<void> addArtist(String name) async {
    await _artistService.addArtist(name);
    notifyListeners();
  }

  Future<void> deleteArtist(Artist artist) async {
    await _artistService.deleteArtist(artist);
    notifyListeners();
  }

  Future<void> updateArtist(Artist artist) async {
    await _artistService.updateArtist(artist);
    notifyListeners();
  }

  Future<Artist?> getArtist(String name) async {
    return await _artistService.getArtist(name);
  }

  Future<List<Artist>> getArtists(String query) async {
    return await _artistService.getArtists(query, flag, currentPage, perPage);
  }

  Future<List<Artist>> getAllArtists() async {
    return await _artistService.getAllArtists();
  }
}
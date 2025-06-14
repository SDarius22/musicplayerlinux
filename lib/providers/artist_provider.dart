import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/artist.dart';
import 'package:musicplayer/services/artist_service.dart';
import 'package:rxdart/rxdart.dart';

class ArtistProvider with ChangeNotifier {
  final ArtistService _artistService;

  bool isAscending = false;
  String query = '';
  String sortField = 'Name'; // Name, Duration, Number of Songs

  late Future artistsFuture;

  ArtistProvider(this._artistService) {
    artistsFuture = Future(() => _artistService.getAllArtists());

    artistsStream.debounceTime(const Duration(seconds: 10)).listen((_) {
      debugPrint("Artists stream updated");
      artistsFuture = Future(() => _artistService.getArtists(query, sortField, isAscending));
      notifyListeners();
    });
  }

  Stream get artistsStream => _artistService.watchArtists();

  void setFlag(bool value) {
    isAscending = value;
    artistsFuture = Future(() => _artistService.getArtists(query, sortField, isAscending));
    notifyListeners();
  }

  void setSortField(String field) {
    sortField = field;
    artistsFuture = Future(() => _artistService.getArtists(query, sortField, isAscending));
    notifyListeners();
  }

  void setQuery(String newQuery) {
    query = newQuery;
    artistsFuture = Future(() => _artistService.getArtists(query, sortField, isAscending));
    notifyListeners();
  }


  void addArtist(String name) {
    _artistService.addArtist(name);
    notifyListeners();
  }

  void deleteArtist(Artist artist) {
    _artistService.deleteArtist(artist);
    notifyListeners();
  }

  void updateArtist(Artist artist) {
    _artistService.updateArtist(artist);
    notifyListeners();
  }

  Artist? getArtist(String name) {
    return _artistService.getArtist(name);
  }

  List<Artist> getArtists() {
    return _artistService.getArtists(query, sortField, isAscending);
  }

  List<Artist> getAllArtists() {
    return _artistService.getAllArtists();
  }
}
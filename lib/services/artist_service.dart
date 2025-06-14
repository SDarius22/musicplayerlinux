import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/artist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/repository/artist_repo.dart';

class ArtistService {
  final ArtistRepository artistRepo;

  ArtistService(this.artistRepo);

  Stream watchArtists() => artistRepo.watchAllArtists();

  void addArtist(String name) async {
    if (name.isEmpty) {
      throw ArgumentError("Artist name cannot be empty");
    }
    // Check if the artist already exists
    final existingArtist =  artistRepo.getArtist(name);
    if (existingArtist != null) {
      throw Exception("Artist with name '$name' already exists");
    }
    Artist newArtist = Artist();
    newArtist.name = name;
    try {
       artistRepo.addArtist(newArtist);
    } catch (e) {
      debugPrint("Error adding artist: $e");
    }
  }

  Artist? getArtist(String name) {
    if (name.isEmpty) {
      throw ArgumentError("Artist name cannot be empty");
    }
    try{
      return  artistRepo.getArtist(name);
    } catch (e) {
      debugPrint("Error fetching artist: $e");
      return null;
    }
  }

  List<Artist> getArtists(String query, String sortField, bool flag) {
    try{
      return  artistRepo.getArtists(query, sortField, flag);
    }
    catch (e) {
      debugPrint("Error fetching artists: $e");
      return [];
    }
  }

  List<Artist> getAllArtists() {
    try {
      return artistRepo.getAllArtists();
    } catch (e) {
      debugPrint("Error fetching all artists: $e");
      return [];
    }
  }

  void updateArtist(Artist artist) {
    if (artist.name.isEmpty) {
      throw ArgumentError("Artist name cannot be empty");
    }
    try {
       artistRepo.updateArtist(artist);
    } catch (e) {
      debugPrint("Error updating artist: $e");
    }
  }

  void deleteArtist(Artist artist) {
    if (artist.id <= 0) {
      throw ArgumentError("Invalid artist ID");
    }
    try {
       artistRepo.deleteArtist(artist);
    } catch (e) {
      debugPrint("Error deleting artist: $e");
    }
  }

  void addSongToArtist(Song song, String artistName) {
    Artist? artist = artistRepo.getArtist(artistName);
    if (artist == null) {
      artist = Artist();
      artist.name = artistName;
      artist.songs.add(song);
      artist.duration += song.duration;
      artistRepo.addArtist(artist);
    }
    else {
      artist.songs.add(song);
      artist.duration += song.duration;
      artistRepo.updateArtist(artist);
    }
  }
}
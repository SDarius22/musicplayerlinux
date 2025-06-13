import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/artist.dart';
import 'package:musicplayer/repository/artist_repo.dart';

class ArtistService {
  final ArtistRepository artistRepo;

  ArtistService(this.artistRepo);

  Future<void> addArtist(String name) async {
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

  Future<Artist?> getArtist(String name) async {
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

  Future<List<Artist>> getArtists(String query, bool flag, int currentPage, int perPage) async {
    try{
      return  artistRepo.getArtists(query, flag, currentPage, perPage);
    }
    catch (e) {
      debugPrint("Error fetching artists: $e");
      return [];
    }
  }

  Future<List<Artist>> getAllArtists() async {
    try {
      return  artistRepo.getAllArtists();
    } catch (e) {
      debugPrint("Error fetching all artists: $e");
      return [];
    }
  }

  Future<void> updateArtist(Artist artist) async {
    if (artist.name.isEmpty) {
      throw ArgumentError("Artist name cannot be empty");
    }
    try {
       artistRepo.updateArtist(artist);
    } catch (e) {
      debugPrint("Error updating artist: $e");
    }
  }

  Future<void> deleteArtist(Artist artist) async {
    if (artist.id <= 0) {
      throw ArgumentError("Invalid artist ID");
    }
    try {
       artistRepo.deleteArtist(artist);
    } catch (e) {
      debugPrint("Error deleting artist: $e");
    }
  }
}
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/repository/album_repo.dart';

class AlbumService {
  final AlbumRepository albumRepo;

  AlbumService(this.albumRepo);

  Future<void> addAlbum(String name) async {
    if (name.isEmpty) {
      throw ArgumentError("Album name cannot be empty");
    }
    Album album = Album();
    album.name = name;

    try{
      albumRepo.addAlbum(album);
    } catch (e) {
      debugPrint("Error adding album: $e");
    }
  }

  Future<Album?> getAlbum(String name) async {
    if (name.isEmpty) {
      throw ArgumentError("Album name cannot be empty");
    }
    try {
      return  albumRepo.getAlbum(name);
    } catch (e) {
      debugPrint("Error fetching album: $e");
      return null;
    }
  }

  Future<List<Album>> getAlbums(String query, bool flag, int currentPage, int perPage) async {
    try {
      return  albumRepo.getAlbums(query, flag, currentPage, perPage);
    } catch (e) {
      debugPrint("Error fetching albums: $e");
      return [];
    }
  }

  Future<List<Album>> getAllAlbums() async {
    try {
      return  albumRepo.getAllAlbums();
    } catch (e) {
      debugPrint("Error fetching all albums: $e");
      return [];
    }
  }

  Future<void> deleteAlbum(Album album) async {
    if (album.id == 0) {
      throw ArgumentError("Album ID cannot be zero");
    }
    try {
       albumRepo.deleteAlbum(album);
    } catch (e) {
      debugPrint("Error deleting album: $e");
    }
  }

  Future<void> updateAlbum(Album album) async {
    if (album.id == 0) {
      throw ArgumentError("Album ID cannot be zero");
    }
    try {
       albumRepo.updateAlbum(album);
    } catch (e) {
      debugPrint("Error updating album: $e");
    }
  }
}
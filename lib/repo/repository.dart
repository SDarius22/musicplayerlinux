import 'dart:core';

import 'package:flutter/cupertino.dart';

import '../domain/metadata_type.dart';
import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/playlist_type.dart';

class Repository{
  ValueNotifier<List<MetadataType>> songs = ValueNotifier([]);
  List<AlbumType> albums = [];
  List<ArtistType> artists = [];
  List<PlaylistType> playlists = [];
}
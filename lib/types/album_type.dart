import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'featured_artist_type.dart';
import 'metadata_type.dart';

class album_type{
  String name = "Unknown album";
  List<featured_artist_type> featuredartists = [];
  Uint8List image = File("./assets/bg.png").readAsBytesSync();
  List<metadata_type> songs = [];
  String duration = "Unknown duration";

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'featuredartists': featuredartists,
      'songs': songs,
      'duration': duration,
    };
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'featured_artist_type.dart';
import 'metadata_type.dart';

class playlist{
  String name = "Unknown playlist";
  List<String> paths = [];
  List<metadata_type> songs = [];
  String duration = "Unknown duration";
  List<featured_artist_type> featuredartists = [];
  Uint8List image = File("assets\\bg.png").readAsBytesSync();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paths': paths,
      'duration': duration,
      'featuredartists': featuredartists,
    };
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'metadata_type.dart';

class artist_type{
  String name = "Unknown artist";
  Uint8List image = File("assets\\bg.png").readAsBytesSync();
  List<metadata_type> songs = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'songs': songs,
    };
  }
}
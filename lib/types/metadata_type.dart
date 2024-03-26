import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class metadata_type{
  String title = "Unknown Song";
  String artists = "Unknown artist";
  String album = "Unknown album";
  String durationString = "00:00";
  int duration = 0;
  Uint8List image = File("./assets/bg.png").readAsBytesSync();
  String path = "";
  String lyrics = "No lyrics";
  int tracknumber = 0;
  int discnumber = 0;
  bool imageloaded = false;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artists': artists,
      'album': album,
      'durationString': durationString,
      'duration': duration,
      'image': image,
      'path': path,
      'lyrics': lyrics,
      'tracknumber': tracknumber,
      'discnumber': discnumber,
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      'title': title,
      'artists': artists,
      'album': album,
      'durationString': durationString,
      'duration': duration,
      'path': path,
      'lyrics': lyrics,
      'tracknumber': tracknumber,
      'discnumber': discnumber,
    };
  }


}
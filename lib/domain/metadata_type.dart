import 'package:flutter/material.dart';

class MetadataType{
  String title = "Unknown Song";
  String artists = "Unknown artist";
  String album = "Unknown album";
  int duration = 0;
  String path = "";
  String lyricsPath = "No lyrics";
  int trackNumber = 0;
  int discNumber = 0;

  Map<String, dynamic> toJson() {
    return {
        "title": title,
        "artists": artists,
        "album": album,
        "duration": duration,
        "path": path,
        "lyricsPath": lyricsPath,
        "trackNumber": trackNumber,
        "discNumber": discNumber,
    };
  }

  MetadataType();

  MetadataType.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        artists = json['artists'],
        album = json['album'],
        duration = json['duration'],
        path = json['path'],
        lyricsPath = json['lyricsPath'],
        trackNumber = json['trackNumber'],
        discNumber = json['discNumber'];
}
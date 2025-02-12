import 'package:objectbox/objectbox.dart';

@Entity()
class SongType{
  @Id()
  int id = 0;
  String title = "Unknown Song";
  String trackArtist = "Unknown artist";
  String album = "Unknown album";
  String albumArtist = "Unknown album artist";
  int duration = 0;
  String path = "";
  String lyricsPath = "";
  int trackNumber = 0;
  int discNumber = 0;
  int year = 0;
  String genre = "Unknown genre";


  bool liked = false;
  DateTime? lastPlayed;
  int playCount = 0;

  @override
  bool operator ==(Object other) =>
    other is SongType && other.runtimeType == runtimeType && other.path == path;

  @override
  int get hashCode => path.hashCode;

}
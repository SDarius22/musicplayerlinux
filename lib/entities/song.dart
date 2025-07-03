import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Song extends AbstractEntity{
  @Id()
  int id = 0;

  @Unique()
  String path = "";

  String lyricsPath = "";

  // Real field for ObjectBox
  String _name = "Unknown song";

  // Override the abstract getter
  @override
  String get name => _name;

  @override
  set name(String value) => _name = value;

  String genre = "Unknown genre";
  String trackArtist = "Unknown artist";
  String album = "Unknown album";
  String albumArtist = "Unknown album artist";
  int duration = 0; // in seconds
  int trackNumber = 0;
  int discNumber = 0;
  int year = 0;


  // Addition user oriented properties
  @Property(type: PropertyType.date) // milliseconds since epoch
  DateTime? lastPlayed;
  int playCount = 0;
  bool liked = false;
  bool fullyLoaded = false;
  @Transient()
  bool existsExternally = false;

  @override
  bool operator ==(Object other) =>
    other is Song && other.runtimeType == runtimeType && other.path == path;

  @override
  int get hashCode => path.hashCode;

  void fromJson(Map<String, dynamic> json) {
    path = json['path'] ?? "";
    lyricsPath = json['lyricsPath'] ?? "";
    name = json['title'] ?? "Unknown Song";
    genre = json['genre'] ?? "Unknown genre";
    trackArtist = json['trackArtist'] ?? "Unknown artist";
    album = json['album'] ?? "Unknown album";
    albumArtist = json['albumArtist'] ?? "Unknown album artist";
    duration = json['duration'] ?? 0;
    trackNumber = json['trackNumber'] ?? 0;
    discNumber = json['discNumber'] ?? 0;
    year = json['year'] ?? 0;
  }

}
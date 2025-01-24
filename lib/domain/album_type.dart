import 'song_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AlbumType{
  @Id()
  int id = 0;
  String name = "Unknown album";
  final songs = ToMany<SongType>();

  int duration = 0; // in seconds
}
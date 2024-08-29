import 'song_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ArtistType{
  @Id()
  int id = 0;
  String name = "Unknown artist";
  final songs = ToMany<SongType>();
}
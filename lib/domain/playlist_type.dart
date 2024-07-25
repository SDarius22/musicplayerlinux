import 'artist_type.dart';
import 'metadata_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistType{
  @Id()
  int id = 0;
  String name = "Unknown playlist";
  String duration = "Unknown duration";
  final songs = ToMany<MetadataType>();
  final artists = ToMany<ArtistType>();
}
import 'artist_type.dart';
import 'metadata_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AlbumType{
  @Id()
  int id = 0;
  String name = "Unknown album";
  String duration = "Unknown duration";
  final songs = ToMany<MetadataType>();
  final artists = ToMany<ArtistType>();
}
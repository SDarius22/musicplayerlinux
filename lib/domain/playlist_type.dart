import 'metadata_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistType{
  @Id()
  int id = 0;
  String name = "Unknown playlist";
  final songs = ToMany<MetadataType>();
}
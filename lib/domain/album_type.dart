import 'metadata_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AlbumType{
  @Id()
  int id = 0;
  String name = "Unknown album";
  final songs = ToMany<MetadataType>();
}
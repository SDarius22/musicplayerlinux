import 'package:objectbox/objectbox.dart';
import 'metadata_type.dart';

@Entity()
class Settings{
  @Id()
  int id = 0;
  String directory = '/';
  int lastPlayingIndex = 0;
  bool firstTime = true;
  final playingSongs = ToMany<MetadataType>();
  final playingSongsUnShuffled = ToMany<MetadataType>();
}
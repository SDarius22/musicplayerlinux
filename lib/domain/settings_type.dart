import 'package:objectbox/objectbox.dart';
import 'metadata_type.dart';

@Entity()
class Settings{
  @Id()
  int id = 0;
  String directory = '/';
  int lastPlayingIndex = 0;
  bool firstTime = true;
  bool showSystemTray = true;
  bool showAppNotifications = true;
  String deezerToken = '';
  String queueAdd = 'last';
  String queuePlay = 'all';
  final playingSongs = ToMany<MetadataType>();
  final playingSongsUnShuffled = ToMany<MetadataType>();
}
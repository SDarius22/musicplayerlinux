import 'package:objectbox/objectbox.dart';

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
  List<String> playingSongs = [];
  List<String> playingSongsUnShuffled = [];
}
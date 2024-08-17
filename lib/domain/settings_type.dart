import 'package:objectbox/objectbox.dart';

@Entity()
class Settings{
  @Id()
  int id = 0;
  String directory = '/';
  int index = 0; // this is the index of the song in the unshuffled queue
  bool firstTime = true;
  bool systemTray = true;
  bool appNotifications = true;
  String deezerARL = '';
  String queueAdd = 'last';
  String queuePlay = 'all';
  List<String> queue = []; // this is the queue of songs, unshuffled
}
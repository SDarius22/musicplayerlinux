import 'package:objectbox/objectbox.dart';
import 'package:musicplayer/entities/user.dart';

@Entity()
class AppSettings {
  @Id()
  int id = 0;

  final user = ToOne<User>();

  bool firstTime = true;
  bool systemTray = true;
  bool fullClose = false;

  String mainSongPlace = '';

  List<String> songPlaces = [];
  List<int> songPlaceIncludeSubfolders = [];

  List<String> missingSongs = []; //TBD
}
import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistType{
  @Id()
  int id = 0;
  @Unique()
  String name = "Unknown playlist";
  String nextAdded = "last";
  List<String> paths = [];
  bool indestructible = false;
  int duration = 0; // in seconds
  List<String> artistCount = []; // Strings of form "Artist - Count"
}
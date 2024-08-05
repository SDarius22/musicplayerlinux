import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistType{
  @Id()
  int id = 0;
  String name = "Unknown playlist";
  List<String> paths = [];
}
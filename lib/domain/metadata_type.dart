import 'package:objectbox/objectbox.dart';

@Entity()
class MetadataType{
  @Id()
  int id = 0;
  int orderPosition = 0;

  String title = "Unknown Song";
  String artists = "Unknown artist";
  String album = "Unknown album";
  int duration = 0;
  String path = "";
  String lyricsPath = "No lyrics";
  int trackNumber = 0;
  int discNumber = 0;

  @override
  bool operator ==(Object other) =>
    other is MetadataType && other.runtimeType == runtimeType && other.path == path;

  @override
  int get hashCode => path.hashCode;

}
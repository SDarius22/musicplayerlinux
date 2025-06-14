import 'package:musicplayer/entities/abstract/abstract_collection.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:objectbox/objectbox.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';

@Entity()
class Album extends AbstractEntity with AbstractCollection{
  @Id()
  int id = 0;

  // Real field for ObjectBox
  String _name = "Unknown album";

  // Override the abstract getter
  @override
  String get name => _name;

  @override
  set name(String value) => _name = value;

  final _songs = ToMany<Song>();

  @override
  ToMany<Song> get songs => _songs;

  int duration = 0;
}
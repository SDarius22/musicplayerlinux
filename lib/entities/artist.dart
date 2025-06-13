import 'package:musicplayer/entities/abstract/abstract_collection.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Artist extends AbstractEntity with AbstractCollection {
  @Id()
  int id = 0;

  @Unique()
  String _name = "Unknown artist";

  // Override the abstract getter
  @override
  String get name => _name;

  @override
  set name(String value) => _name = value;

  final _songs = ToMany<Song>();
  @override
  List<Song> get songs => _songs.toList();

  int duration = 0; // in seconds
}
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/song.dart';

mixin AbstractCollection {
  ToMany<Song> get songs;
}
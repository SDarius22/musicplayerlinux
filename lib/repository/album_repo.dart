import 'package:musicplayer/database/objectBox.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/album.dart';

class AlbumRepository {
  get albumBox => ObjectBox.store.box<Album>();

  void addAlbum(Album album) {
    albumBox.put(album);
  }

  Album? getAlbum(String name) {
    return albumBox.query(Album_.name.equals(name)).build().findUnique();
  }

  List<Album> getAlbums(String query, bool flag, int currentPage, int perPage) {
    return albumBox
        .query(Album_.name.contains(query, caseSensitive: false))
        .order(Album_.name,
          flags: flag ? Order.descending : null,
        )
        ..offset((currentPage - 1) * perPage)
        ..limit(perPage)
        .build()
        .find();
  }

  List<Album> getAllAlbums() {
    return albumBox.getAll();
  }

  void deleteAlbum(Album album) {
    albumBox.remove(album.id);
  }

  void updateAlbum(Album album)  {
     albumBox.put(album);
  }
}
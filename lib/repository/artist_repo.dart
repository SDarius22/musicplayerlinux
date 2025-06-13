import 'package:musicplayer/database/objectBox.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/artist.dart';

class ArtistRepository {
  get artistBox => ObjectBox.store.box<Artist>();

  void addArtist(Artist artist) {
    artistBox.put(artist);
  }

  Artist? getArtist(String name) {
    return artistBox.query(Artist_.name.equals(name)).build().findUnique();
  }

  List<Artist> getArtists(String query, bool flag, int currentPage, int perPage)  {
    return artistBox
        .query(Artist_.name.contains(query, caseSensitive: false))
        .order(Artist_.name,
          flags: flag ? Order.descending : null,
        )
        ..offset((currentPage - 1) * perPage)
        ..limit(perPage)
        .build()
        .find();
  }

  List<Artist> getAllArtists()  {
    return artistBox.getAll();
  }

  void deleteArtist(Artist artist)  {
    artistBox.remove(artist.id);
  }

  void updateArtist(Artist artist)  {
    artistBox.put(artist);
  }
}
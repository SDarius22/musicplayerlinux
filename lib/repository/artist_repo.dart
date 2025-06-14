import 'package:musicplayer/database/objectBox.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/artist.dart';

class ArtistRepository {
  get artistBox => ObjectBox.store.box<Artist>();

  void addArtist(Artist artist) {
    artistBox.put(artist);
  }

  Stream watchAllArtists() {
    final query = artistBox.query();
    return query.watch();
  }

  Artist? getArtist(String name) {
    return artistBox.query(Artist_.name.equals(name)).build().findUnique();
  }

  List<Artist> getArtists(String query, String sortField, bool flag)  {
    var builderQuery;
    if (flag == false) {
      builderQuery = artistBox
          .query(Artist_.name.contains(query, caseSensitive: false))
          .order(
        sortField == 'Name' ? Artist_.name : Artist_.duration,
      ).build();
    } else {
      builderQuery = artistBox
          .query(Artist_.name.contains(query, caseSensitive: false))
          .order(
        sortField == 'Name' ? Artist_.name : Artist_.duration,
        flags: Order.descending,
      ).build();
    }
    return builderQuery.find();
  }

  List<Artist> getAllArtists()  {
    return artistBox.query().order(Artist_.name).build().find();
  }

  void deleteArtist(Artist artist)  {
    artistBox.remove(artist.id);
  }

  void updateArtist(Artist artist)  {
    artistBox.put(artist);
  }
}
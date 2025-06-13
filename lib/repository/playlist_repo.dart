import 'package:musicplayer/database/objectBox.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/playlist.dart';

class PlaylistRepository {
  get playlistBox => ObjectBox.store.box<Playlist>();

  void addPlaylist(Playlist playlist)  {
    playlistBox.put(playlist);
  }

  Playlist? getPlaylist(String name)  {
    return playlistBox.query(Playlist_.name.equals(name)).build().findUnique();
  }

  List<Playlist> getIndestructiblePlaylists()  {
    return playlistBox
        .query(Playlist_.indestructible.equals(true))
        .order(Playlist_.name)
        .build()
        .find();
  }

  List<Playlist> getNormalPlaylists()  {
    return playlistBox
        .query(Playlist_.indestructible.equals(false))
        .order(Playlist_.name)
        .build()
        .find();
  }

  List<Playlist> getPlaylists(String query, String sortField, bool flag, int currentPage, int perPage)  {
    return playlistBox
        .query(Playlist_.name.contains(query, caseSensitive: false)
            .and(Playlist_.indestructible.equals(false)))
        .order(
          sortField == 'name' ? Playlist_.name : Playlist_.createdAt,
          flags: flag ? Order.descending : null,
        )
        ..offset((currentPage - 1) * perPage)
        ..limit(perPage)
        .build()
        .find();
  }

  void deletePlaylist(Playlist playlist)  {
    playlistBox.remove(playlist.id);
  }

  void updatePlaylist(Playlist playlist)  {
    playlistBox.put(playlist);
  }
}
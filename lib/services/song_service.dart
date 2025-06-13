import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/app_settings.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/repository/song_repo.dart';
import 'package:musicplayer/services/file_service.dart';
import 'package:musicplayer/services/settings_service.dart';

class SongService {
  final SongsRepository songRepo;
  final SettingsService settingsService;

  SongService(this.songRepo, this.settingsService);

  Stream watchSongs() => songRepo.watchAllSongs();

  Stream fileChangesStream() {
    return FileService.watchForFileChanges(
      settingsService.getAppSettings()?.songPlaces ?? [],
    );
  }

  Future<void> addSong(String songPath) async {
    if (songPath.isEmpty) {
      throw ArgumentError("Song path cannot be empty");
    }

    // Check if the song already exists
    final existingSong =  songRepo.getSong(songPath);
    if (existingSong != null) {
      throw Exception("Song with path '$songPath' already exists");
    }

    Song newSong = Song();
    var metadata = await FileService.retrieveSong(songPath);
    newSong.fromJson(metadata);

    try {
       songRepo.addSong(newSong);
    } catch (e) {
      throw Exception("Error adding song: $e");
    }
  }

  Song? getSong(String songPath) {
    if (songPath.isEmpty) {
      throw ArgumentError("Song path cannot be empty");
    }

    try {
      return songRepo.getSong(songPath);
    } catch (e) {
      debugPrint("Error fetching song: $e");
      return null;
    }
  }

  List<Song> getSongs(String query, String sortField, bool flag) {
    try {
      return songRepo.getSongs(query, sortField, flag);
    } catch (e) {
      debugPrint("Error fetching songs: $e");
      return [];
    }
  }

  List<Song> getAllSongs() {
    try {
      return songRepo.getAllSongs();
    } catch (e) {
      debugPrint("Error fetching all songs: $e");
      return [];
    }
  }

  int getSongCount() {
    try {
      return songRepo.getTotalSongsCount();
    } catch (e) {
      debugPrint("Error fetching song count: $e");
      return 0;
    }
  }

  void updateSong(Song song) {
    if (song.path.isEmpty) {
      throw ArgumentError("Song path cannot be empty");
    }

    try {
       songRepo.updateSong(song);
    } catch (e) {
      debugPrint("Error updating song: $e");
    }
  }

  void deleteSong(Song song) {
    if (song.path.isEmpty) {
      throw ArgumentError("Song path cannot be empty");
    }

    try {
       songRepo.deleteSong(song);
    } catch (e) {
      debugPrint("Error deleting song: $e");
    }
  }

  List<Song> getSongsWithPlayCount() {
    try {
      return  songRepo.getSongsWithPlayCount();
    } catch (e) {
      debugPrint("Error fetching songs with play count: $e");
      return [];
    }
  }

  List<Song> getSongsWithLastPlayed() {
    try {
      return  songRepo.getSongsWithLastPlayed();
    } catch (e) {
      debugPrint("Error fetching songs with last played: $e");
      return [];
    }
  }

  List<Song> getSongsFromPaths(List<String> paths) {
    if (paths.isEmpty) {
      return [];
    }

    try {
      return songRepo.getSongsFromPaths(paths);
    } catch (e) {
      debugPrint("Error fetching songs from paths: $e");
      return [];
    }
  }

  Future<void> retrieveAllSongs() async {
    var appSettings = settingsService.getAppSettings() ?? AppSettings();
    List<String> songPlaces = appSettings.songPlaces;
    final audioFiles = await FileService.getAudioFiles(songPlaces);

    for (final file in audioFiles) {
      final song = songRepo.getSong(file.path);
      if (song == null) {
        final song = Song();
        song.path = file.path;
        song.name = file.path.split('/').last;
        songRepo.addSong(song);

        compute(FileService.retrieveSong, file.path).then((metadata) {
          song.fromJson(metadata);
          debugPrint("Retrieved metadata for ${file.path}: ${song.id}");
          song.fullyLoaded = true;
          songRepo.updateSong(song);
        })
            .catchError((error) {
          debugPrint("Error retrieving metadata for ${file.path}: $error");
        });
      }
      else if (song.fullyLoaded == false) {
        compute(FileService.retrieveSong, file.path).then((metadata) {
          song.fromJson(metadata);
          debugPrint("Retrieved metadata for ${file.path}: ${song.id}");
          song.fullyLoaded = true;
          songRepo.updateSong(song);
        })
            .catchError((error) {
          debugPrint("Error retrieving metadata for ${file.path}: $error");
        });
      }
    }
  }
}
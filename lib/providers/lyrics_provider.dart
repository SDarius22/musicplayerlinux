import 'package:flutter/cupertino.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/services/file_service.dart';
import 'package:musicplayer/utils/lyric_reader/lyrics_model_builder.dart';
import 'package:musicplayer/utils/lyric_reader/lyrics_reader_model.dart';

class LyricsProvider with ChangeNotifier {
  late final AudioProvider _audioProvider;
  late LyricsReaderModel lyricsModelBuilder;
  late String unsyncedLyrics;

  void init(AudioProvider audioProvider) {
    _audioProvider = audioProvider;
    buildLyricsModel();
    _audioProvider.addListener(() {
      buildLyricsModel();
    });
  }

  Future<void> buildLyricsModel() async {
    String? lyrics = await _getLyricsForCurrentSong();
    lyricsModelBuilder = LyricsModelBuilder.create().bindLyricToMain(lyrics ?? '').getModel();
    debugPrint('LyricsModelBuilder: ${lyricsModelBuilder.lyrics.length} lines');
    if (lyricsModelBuilder.lyrics.isEmpty) {
      unsyncedLyrics = lyrics ?? '';
    } else {
      unsyncedLyrics = '';
    }
    notifyListeners();
  }

  Future<String?> _getLyricsForCurrentSong() async {
    return await FileService.getLyrics(_audioProvider.currentSong.path);
  }

}
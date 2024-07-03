class Settings{
  String directory;
  List<String> lastPlaying;
  int lastPlayingIndex;
  bool firstTime;

  Settings.fromJson(Map<String, dynamic> json):
        firstTime = json['firstTime'],
        directory = json['directory'],
        lastPlaying = json['lastPlaying'].cast<String>(),
        lastPlayingIndex = json['lastPlayingIndex'];

  Map<String, dynamic> toJson() {
    return {
      'firstTime': firstTime,
      'directory': directory,
      'lastPlaying': lastPlaying,
      'lastPlayingIndex': lastPlayingIndex,
    };
  }
}
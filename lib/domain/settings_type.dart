class Settings{
  String directory;
  List<String> lastPlaying;
  int lastPlayingIndex;
  bool firstTime;

  Settings.fromJson(Map<String, dynamic> json):
        firstTime = json['firstTime'],
        directory = json['directory'],
        lastPlayingIndex = json['lastPlayingIndex'],
        lastPlaying = json['lastPlaying'].cast<String>();


  Map<String, dynamic> toJson() {
    return {
      'firstTime': firstTime,
      'directory': directory,
      'lastPlayingIndex': lastPlayingIndex,
      'lastPlaying': lastPlaying,
    };
  }
}
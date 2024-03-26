class settings{
  String directory;
  List<String> lastplaying;
  int lastplayingindex;
  bool firsttime;

  settings.fromJson(Map<String, dynamic> json):
        firsttime = json['firsttime'],
        directory = json['directory'],
        lastplaying = json['lastplaying'].cast<String>(),
        lastplayingindex = json['lastplayingindex'];

  Map<String, dynamic> toJson() {
    return {
      'firsttime': firsttime,
      'directory': directory,
      'lastplaying': lastplaying,
      'lastplayingindex': lastplayingindex,
    };
  }
}
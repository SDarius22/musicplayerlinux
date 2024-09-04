import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';
import 'package:system_tray/system_tray.dart';
import 'package:deezer/deezer.dart';
import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/song_type.dart';
import '../domain/playlist_type.dart';
import '../domain/settings_type.dart';
import '../utils/objectbox.g.dart';
import '../utils/dominant_color/dominant_color.dart';
import '../utils/flac_metadata/flacstream.dart';
import '../utils/id3tag/id3tag.dart';
import 'objectBox.dart';



class Controller{
  AudioPlayer audioPlayer = AudioPlayer();

  bool firstTimeRetrieving = true;

  final navigatorKey = GlobalKey<NavigatorState>();

  final Menu _menuMain = Menu();
  final SystemTray _systemTray = SystemTray();

  late Box<AlbumType> albumBox;
  late Box<ArtistType> artistBox;
  late Box<PlaylistType> playlistBox;
  late Box<Settings> settingsBox;
  late Box<SongType> songBox;
  late Deezer instance;

  List<String> controllerQueue = []; // this is the queue, this can be shuffled
  
  Settings settings = Settings();

  ValueNotifier<bool> downloadNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> finishedRetrievingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> hasBeenChanged = ValueNotifier<bool>(false);
  ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> repeatNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> searchNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> shuffleNotifier = ValueNotifier<bool>(false);

  ValueNotifier<Color> colorNotifier = ValueNotifier<Color>(Colors.white); // Light color, for lyrics and sliders
  ValueNotifier<Color> colorNotifier2 = ValueNotifier<Color>(Colors.black); // Dark color, for background of player and window bar

  ValueNotifier<double> balanceNotifier = ValueNotifier<double>(0);
  ValueNotifier<double> speedNotifier = ValueNotifier<double>(1);
  ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);

  ValueNotifier<int> indexNotifier = ValueNotifier<int>(0); // index of the song in the queue that can be shuffled
  ValueNotifier<int> sleepTimerNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> sliderNotifier = ValueNotifier<int>(0);
  ValueNotifier<String> timerNotifier = ValueNotifier<String>('Off');


  /// Constructor for the Controller class
  Controller(List<String> args) {
    settingsBox = ObjectBox.store.box<Settings>();
    if (settingsBox.isEmpty()) {
      print("Initialising settings");
      settingsBox.put(settings);
    }
    else {
      settings = settingsBox.getAll().last;
      // for (Settings setting in settingsBox.getAll()){
      //   print(setting.playingSongsUnShuffled.first.title);
      // }
    }
    if(settings.systemTray){
      initSystemTray();
    }
    if(settings.deezerARL.isNotEmpty){
      initDeezer();
    }

    songBox = ObjectBox.store.box<SongType>();
    albumBox = ObjectBox.store.box<AlbumType>();
    artistBox = ObjectBox.store.box<ArtistType>();
    playlistBox = ObjectBox.store.box<PlaylistType>();
    audioPlayer.onPositionChanged.listen((Duration event){
        sliderNotifier.value = event.inMilliseconds;
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      playingNotifier.value = state == PlayerState.playing;
      if(state == PlayerState.completed){
        if(repeatNotifier.value){
          print("repeat");
          sliderNotifier.value = 0;
          playSong();
        }
        else {
          print("next");
          nextSong();
        }
      }
    });

    controllerQueue.addAll(settings.queue);

    if (args.isNotEmpty) {
      print(args);
      List<String> songs = args.where((element) => element.endsWith(".mp3") || element.endsWith(".flac") || element.endsWith(".wav") || element.endsWith(".m4a")).toList();
      updatePlaying(songs, 0);
      indexChange(controllerQueue[0]);
      playSong();
    }
    else{
      if(controllerQueue.isNotEmpty){
        indexChange(controllerQueue[settings.index]);
        //playSong();
      }
    }

  }

  Future<void> addToPlaylist(PlaylistType playlist, List<SongType> songs) async {
    if(playlist.nextAdded == 'last'){
      for(var song in songs){
        if (playlist.paths.contains(song.path)){
          continue;
        }
        playlist.paths.add(song.path);
      }
      playlistBox.put(playlist);
    }
    else{
      for(int i = songs.length - 1; i >= 0; i--){
        if (playlist.paths.contains(songs[i].path)){
          continue;
        }
        playlist.paths.insert(0, songs[i].path);
      }
      playlistBox.put(playlist);
    }
    exportPlaylist(playlist);

  }

  Future<void> addToQueue(List<String> songs) async {
    print("Adding to queue ${songs.length} songs.");
    //loadingNotifier.value = true;
    if (settings.queueAdd == 'last') {
      //print("last");
      controllerQueue.addAll(songs);
      settings.queue.addAll(songs);
      //print(settings.queue);
      settingsBox.put(settings);
    }
    else if (settings.queueAdd == 'next') {
      //print("next");
      controllerQueue.insertAll(indexNotifier.value + 1, songs);
      settings.queue.insertAll(indexNotifier.value + 1, songs);
      settingsBox.put(settings);
    }
    else if (settings.queueAdd == 'first') {
      //print("first");
      controllerQueue.insertAll(0, songs);
      settings.queue.insertAll(0, songs);
      settingsBox.put(settings);
    }
    shuffleSongs();
    //loadingNotifier.value = false;
  }

  Future<void> createPlaylist(PlaylistType playlist) async {
    playlistBox.put(playlist);
    exportPlaylist(playlist);
  }

  Future<void> deletePlaylist(PlaylistType playlist) async {
    playlistBox.remove(playlist.id);
    try {
      var file = File("${settings.directory}/${playlist.name}.m3u");
      file.delete();
    }
    catch(e){
      print(e);
    }
  }

  Future<void> exportPlaylist(PlaylistType playlist) async {
    var file = File("${settings.directory}/${playlist.name}.m3u");
    file.writeAsStringSync("#EXTM3U\n");
    for (var song in playlist.paths){
      file.writeAsStringSync('$song\n', mode: FileMode.append);
    }
  }

  Future<List<AlbumType>> getAlbums(String searchValue) async {
    return albumBox.query(AlbumType_.name.contains(searchValue, caseSensitive: false)).order(AlbumType_.name).build().find();
  }

  Future<List<ArtistType>> getArtists(String searchValue) async {
    return artistBox.query(ArtistType_.name.contains(searchValue, caseSensitive: false)).order(ArtistType_.name).build().find();
  }

  Future<Duration> getDuration(SongType song) async {
    try{
      if(song.duration != 0){
        return Duration(seconds: song.duration);
      }
      else{
        Duration songDuration = await audioPlayer.getDuration() ?? Duration.zero;
        song.duration = songDuration.inSeconds;
        songBox.put(song);
        return songDuration;
      }
    }
    catch(e){
      print(e);
      return await audioPlayer.getDuration() ?? Duration.zero;
    }
  }
  
  Future<Uint8List> getImage(String path) async{
    ByteData data = await rootBundle.load('assets/bg.png');
    Uint8List image =  data.buffer.asUint8List();
    var metadataVar = await AudioTags.read(path);
    if(metadataVar?.pictures.isEmpty == true){
      if(path.endsWith(".flac")) {
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        List<String> imageBytes = metadatas[3].toString().substring(
            1, metadatas[3]
            .toString()
            .length - 1).split(", ");
        image = Uint8List.fromList(
            imageBytes.map(int.parse).toList());
      }
      else if(path.endsWith(".mp3")) {
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        List<String> imageBytes = tags.pictures.isEmpty ? [] : tags.pictures[0].toString().substring(21, tags.pictures.first.toString().length - 3).split(", ");
        image = imageBytes.isEmpty? image : Uint8List.fromList(imageBytes.map(int.parse).toList());
      }
    }
    else{
      image = metadataVar?.pictures[0].bytes ?? image;
    }
    return image;
  }

  Future<List<String>> getLyrics(String path) async{
    var song = songBox.query(SongType_.path.equals(path)).build().findFirst();
    if (song == null){
      return ["No lyrics found", "No lyrics found"];
    }
    else{
      if(song.lyricsPath.isEmpty){
        try {
          return await searchLyrics(path);
        }
        catch(e){
          print(e);
          return ["No lyrics found", "No lyrics found"];
        }
      }
      else{
        return [File(song.lyricsPath).readAsStringSync(), File(song.lyricsPath).readAsStringSync()];
      }
    }
  }

  Future<List<PlaylistType>> getPlaylists(String searchValue) async {
    return playlistBox.query(PlaylistType_.name.contains(searchValue, caseSensitive: false)).order(PlaylistType_.name).build().find();
  }

  Future<List<SongType>> getQueue() async {
    List<SongType> queue = [];
    for (String path in controllerQueue){
      var song = songBox.query(SongType_.path.equals(path)).build().findFirst();
      if(song != null){
        queue.add(song);
      }
      else{
        queue.add(await getSong(path));
      }
    }
    return queue;
  }

  Future<SongType> getSong(String path) async {
    var song = songBox.query(SongType_.path.equals(path)).build().findFirst();
    if(song != null){
      return song;
    }
    SongType metadataVariable = SongType();
    metadataVariable.path = path;
    var metadataVar = await AudioTags.read(path);
    if(metadataVar == null){
      print("metadata is null for $path");
      if(path.endsWith(".flac")) {
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        String metadata = metadatas[2].toString();
        //print(metadata);
        metadata = metadata.substring(1, metadata.length - 1);
        List<String> metadata2 = metadata.split(', *1234a678::876a4321*,');

        //print(metadata2);
        for (var metadate2 in metadata2) {
          if (metadate2.contains("TITLE=")) {
            metadataVariable.title = metadate2.substring(6);
          }
          if (metadate2.contains("ARTIST=") &&
              !metadate2.contains("ALBUMARTIST=")) {
            metadataVariable.artists = metadate2.substring(8);
          }
          if(metadate2.contains("ALBUMARTIST=")){
            metadataVariable.albumArtist = metadate2.substring(12);
          }
          if (metadate2.contains("trackNumber=")) {
            metadataVariable.trackNumber = int.parse(metadate2.substring(13));
          }
          if(metadate2.contains("discNumber=")){
            metadataVariable.discNumber = int.parse(metadate2.substring(12));
          }
          if (metadate2.contains("ALBUM=")) {
            metadataVariable.album = metadate2.substring(7);
          }
          if (metadate2.contains("LENGTH=")) {
            metadataVariable.duration = int.parse(metadate2.substring(8));
          }
        }
      }
      else {
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        metadataVariable.title = tags.title ?? path.replaceAll("\\", "/").split("/").last;
        metadataVariable.artists = tags.artist ?? "Unknown Artist";
        metadataVariable.album = tags.album ?? 'Unknown Album';
        metadataVariable.discNumber = int.parse(tags.trackNumber ?? "0");
        metadataVariable.trackNumber = int.parse(tags.track ?? "0");
        metadataVariable.duration = tags.duration?.inSeconds ?? 0;
      }
    }
    else {
      metadataVariable.title = metadataVar.title ?? path.replaceAll("\\", "/").split("/").last;
      metadataVariable.album = metadataVar.album ?? "Unknown Album";
      metadataVariable.duration = metadataVar.duration ?? 0;
      metadataVariable.trackNumber = metadataVar.trackNumber ?? 0;
      metadataVariable.artists = metadataVar.trackArtist ?? "Unknown Artist";
      metadataVariable.albumArtist = metadataVar.albumArtist ?? "Unknown Album Artist";
      metadataVariable.discNumber = metadataVar.discNumber ?? 0;
    }
    var lyrPath = path.replaceRange(path.lastIndexOf("."), path.length, ".lrc");
    //print(lyrPath);
    bool exists = File(lyrPath).existsSync();
    //print(exists);
    if (!exists) {
      metadataVariable.lyricsPath = "";
    }
    else {
      metadataVariable.lyricsPath = lyrPath;
    }

    await makeAlbumArtist(metadataVariable);

    if(metadataVariable.duration == 0){
      print("duration is 0 for $path");
      var parser = ID3TagReader.path(path);
      var tags = parser.readTagSync();
      metadataVariable.duration = tags.duration?.inSeconds ?? 0;
    }
    songBox.put(metadataVariable);
    return metadataVariable;
  }

  Future<List<SongType>> getSongs(String searchValue) async {
    // Use a Set for faster lookup operations
    Set<String> paths = songBox.getAll().map((e) => e.path).toSet();

    // Remove paths that no longer exist asynchronously
    List<String> toRemove = [];
    for (String path in paths) {
      if (!await File(path).exists()) {
        toRemove.add(path);
      }
    }
    for (String path in toRemove) {
      var query = songBox.query(SongType_.path.equals(path)).build();
      var result = query.findFirst();  // Use findFirst() for safety
      if (result != null) {
        songBox.remove(result.id);
        if(controllerQueue.contains(path)){
          if(controllerQueue[indexNotifier.value] == path){
            indexChange(controllerQueue[0]);
          }
          controllerQueue.remove(path);
          settings.queue.remove(path);
        }
      }
    }

    // Use a Queue for efficient directory traversal
    Queue<Directory> dirs = Queue<Directory>();
    dirs.add(Directory(settings.directory));

    //List<MetadataType> newSongs = [];

    while (dirs.isNotEmpty) {
      final dir = dirs.removeFirst();
      await for (FileSystemEntity entity in dir.list(followLinks: false)) {
        if (entity is File) {
          String path = entity.path.replaceAll("\\", "/");
          if (path.endsWith(".flac") || path.endsWith(".mp3") || path.endsWith(".wav") || path.endsWith(".m4a")) {
            if (!paths.contains(path)) {
              paths.add(path);
              await getSong(path);
              //newSongs.add(await retrieveSong(path));  // Async operation to retrieve song metadata
            }
          }
        } else if (entity is Directory) {
          dirs.add(Directory(entity.path));
        }
      }
    }
    //await makeAlbumsArtists(newSongs);

    if (settings.queue.isEmpty){
      print("empty");
      List<String> initialQueue = songBox.query().order(SongType_.title).build().find().map((e) => e.path).toList();
      print(initialQueue.length);
      controllerQueue.addAll(initialQueue);
      settings.queue.addAll(initialQueue);
    }
    if(controllerQueue.isEmpty){
      controllerQueue.addAll(settings.queue);
      settings.index = 0;
      indexNotifier.value = 0;
      indexChange(controllerQueue[0]);
    }

    // if(!playingNotifier.value){
    //   try{
    //     indexChange(controllerQueue[settings.index]);
    //   }
    //   catch(e){
    //     print(e);
    //     indexChange(controllerQueue[0]);
    //   }
    // }
    if(settings.firstTime){
      settings.firstTime = false;
    }
    settingsBox.put(settings);
    if(firstTimeRetrieving){
      firstTimeRetrieving = false;
      finishedRetrievingNotifier.value = true;
    }

    //finishedRetrievingNotifier.value = true;
    return songBox.query(SongType_.title.contains(searchValue, caseSensitive: false)).order(SongType_.title).build().find();
  }

  Future<void> indexChange(String song) async{
    sliderNotifier.value = 0;
    playingNotifier.value = false;
    indexNotifier.value = controllerQueue.indexOf(song);
    settings.index = settings.queue.indexOf(song);
    settingsBox.put(settings);
    hasBeenChanged.value = !hasBeenChanged.value;
  }

  Future<dynamic> initDeezer() async {
    try{
      instance = await Deezer.create(arl: settings.deezerARL);
    }
    catch(e){
      print(e);
    }
  }

  Future<void> initSystemTray() async {
    if (settings.systemTray == false){
      await _systemTray.destroy();
    }
    else{
      await _systemTray.initSystemTray(iconPath: 'assets/bg.png');
      _systemTray.registerSystemTrayEventHandler((eventName) {
        // debugPrint("eventName: $eventName");
        if (eventName == kSystemTrayEventClick) {
          _systemTray.popUpContextMenu();
        }
      });

      await _menuMain.buildFrom(
        [
          MenuItemLabel(
            label: 'Music Player',
            //image: 'bg.png',
            enabled: false,
          ),
          MenuSeparator(),
          MenuItemLabel(
            label: 'Previous',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Previous'");
              await previousSong();
            },
          ),
          MenuItemLabel(
            label: playingNotifier.value ? 'Pause' : 'Play',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Play'");
              await playSong();
            },
          ),
          MenuItemLabel(
            label: 'Next',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Next'");
              await nextSong();
            },
          ),
          MenuSeparator(),
          MenuItemCheckbox(
            label: 'Repeat',
            name: 'repeat',
            checked: repeatNotifier.value,
            onClicked: (menuItem) async {
              debugPrint("click 'Repeat'");
              await menuItem.setCheck(!menuItem.checked);
              setRepeat();
            },
          ),
          MenuItemCheckbox(
            label: 'Shuffle',
            name: 'shuffle',
            checked: shuffleNotifier.value,
            onClicked: (menuItem) async {
              debugPrint("click 'Shuffle'");
              await menuItem.setCheck(!menuItem.checked);
              setShuffle();
            },
          ),
          MenuSeparator(),
          MenuItemLabel(
              label: 'Show',
              //image: getImagePath('darts_icon'),
              onClicked: (menuItem) => appWindow.show()
          ),
          MenuItemLabel(
              label: 'Exit',
              //image: getImagePath('darts_icon'),
              onClicked: (menuItem) => appWindow.close()
          ),
        ],
      );
      _systemTray.setContextMenu(_menuMain);
    }

  }

  Future<void> makeAlbumArtist(SongType metadataVariable) async {
    Query<AlbumType> albumQuery = albumBox.query(AlbumType_.name.equals(metadataVariable.album)).build();
    AlbumType? album = albumQuery.findFirst();
    if (album == null){
      album = AlbumType();
      album.name = metadataVariable.album;
      album.songs.add(metadataVariable);
      albumBox.put(album);
    }
    else{
      album.songs.add(metadataVariable);
      albumBox.put(album);
    }
    List<String> songArtists = metadataVariable.artists.split("; ");
    for (String artist in songArtists){
      Query<ArtistType> artistQuery = artistBox.query(ArtistType_.name.equals(artist)).build();
      ArtistType? artistType = artistQuery.findFirst();
      if (artistType == null){
        artistType = ArtistType();
        artistType.name = artist;
        artistType.songs.add(metadataVariable);
        artistBox.put(artistType);
      }
      else{
        artistType.songs.add(metadataVariable);
        artistBox.put(artistType);
      }
    }
  }

  Future<void> nextSong() async {
    int newIndex;
    if (indexNotifier.value == controllerQueue.length - 1) {
      newIndex = 0;
    } else {
      newIndex = indexNotifier.value + 1;
    }
    indexChange(controllerQueue[newIndex]);
    playSong();
  }

  Future<void> playSong() async {

    if (playingNotifier.value){
      print("pause");
      await audioPlayer.pause();
      playingNotifier.value = false;
    }
    else{
      print("resume");
      await audioPlayer.play(DeviceFileSource(controllerQueue[indexNotifier.value]), position: Duration(milliseconds: sliderNotifier.value));
      playingNotifier.value = true;
    }
    if (settings.systemTray) {
      initSystemTray();
    }
  }

  Future<void> previousSong() async {
    if(sliderNotifier.value > 5000){
      audioPlayer.seek(const Duration(milliseconds: 0));
    }
    else {
      int newIndex;
      if (indexNotifier.value == 0) {
        newIndex = controllerQueue.length - 1;
      } else {
        newIndex = indexNotifier.value - 1;
      }
      indexChange(controllerQueue[newIndex]);
      playSong();
    }
  }

  Future<void> removeFromQueue(String song) async {
    if(controllerQueue.length == 1){
      showNotification("The queue cannot be empty.", 3500);
      print("The queue cannot be empty");
      return;
    }

    String current = controllerQueue[indexNotifier.value];
    controllerQueue.remove(song);
    settings.queue.remove(song);
    if(!settings.queue.contains(current)){
      indexChange(controllerQueue[0]);
      playSong();
    }
    else{
      indexNotifier.value = controllerQueue.indexOf(current);
      settings.index = settings.queue.indexOf(current);
    }
    settingsBox.put(settings);
  }

  void reset(){
    finishedRetrievingNotifier.value = false;
    songBox.removeAll();
    albumBox.removeAll();
    artistBox.removeAll();
    playlistBox.removeAll();
    controllerQueue.clear();
    firstTimeRetrieving = true;
  }

  Future<dynamic> searchDeezer(String searchValue) async {
    if(searchValue.isEmpty){
      return [];
    }
    final Map<String, String> cookies = {'arl': settings.deezerARL};
    String searchUrl = 'https://api.deezer.com/search?q=$searchValue&limit=56&index=0&output=json';
    print(searchUrl);

    final http.Response getResponse = await http.get(Uri.parse(searchUrl), headers: {
      'Cookie': 'arl=${cookies['arl']}',
    });

    final Map<String, dynamic> getResponseJson = jsonDecode(getResponse.body);
    return(getResponseJson['data']);
  }

  Future<List<SongType>> searchLocal(String enteredKeyword) async {
    var query = songBox.query(SongType_.title.contains(enteredKeyword, caseSensitive: false) | SongType_.artists.contains(enteredKeyword, caseSensitive: false) | SongType_.album.contains(enteredKeyword, caseSensitive: false)).order(SongType_.title).build();
    query.limit = 25;
    return query.find();
  }

  Future<List<String>> searchLyrics(String path) async {
    //plainLyricNotifier.value = 'Searching for lyrics...';
    final Map<String, String> cookies = {'arl': settings.deezerARL};
    final Map<String, String> params = {'jo': 'p', 'rto': 'c', 'i': 'c'};
    const String loginUrl = 'https://auth.deezer.com/login/arl';
    const String deezerApiUrl = 'https://pipe.deezer.com/api';
    SongType song = songBox.query(SongType_.path.equals(path)).build().find().first;
    String title = song.title;
    String artist = song.artists;
    String searchUrl = 'https://api.deezer.com/search?q=$title-$artist&limit=1&index=0&output=json';
    print(searchUrl);

    final Uri uri = Uri.parse(loginUrl).replace(queryParameters: params);
    final http.Request postRequest = http.Request('POST', uri);
    postRequest.headers.addAll({
      'Content-Type': 'application/json',
      'Cookie': 'arl=${cookies['arl']}'
    });
    final http.StreamedResponse streamedResponse = await postRequest.send();
    final String postResponseString = await streamedResponse.stream.bytesToString();
    final Map<String, dynamic> postResponseJson = jsonDecode(postResponseString);

    //print(postResponseJson);
    final String jwt = postResponseJson['jwt'];
    //print(jwt);

    final http.Response getResponse = await http.get(Uri.parse(searchUrl), headers: {
      'Cookie': 'arl=${cookies['arl']}',
    });

    final Map<String, dynamic> getResponseJson = jsonDecode(getResponse.body);
    //print(getResponseJson['data'][0]['id']);

    final String trackId = getResponseJson['data'][0]['id'].toString();



    final Map<String, dynamic> jsonData = {
      'operationName': 'SynchronizedTrackLyrics',
      'variables': {
        'trackId': trackId,
      },
      'query': '''query SynchronizedTrackLyrics(\$trackId: String!) {
                            track(trackId: \$trackId) {
                              ...SynchronizedTrackLyrics
                              __typename
                            }
                          }
                      
                          fragment SynchronizedTrackLyrics on Track {
                            id
                            lyrics {
                              ...Lyrics
                              __typename
                            }
                            album {
                              cover {
                                small: urls(pictureRequest: {width: 100, height: 100})
                                medium: urls(pictureRequest: {width: 264, height: 264})
                                large: urls(pictureRequest: {width: 800, height: 800})
                              explicitStatus
                              __typename
                            }
                            __typename
                          }
                          __typename
                          }
                      
                          fragment Lyrics on Lyrics {
                            id
                            copyright
                            text
                            writers
                            synchronizedLines {
                              ...LyricsSynchronizedLines
                              __typename
                            }
                            __typename
                          }
                      
                          fragment LyricsSynchronizedLines on LyricsSynchronizedLine {
                            lrcTimestamp
                            line
                            lineTranslated
                            milliseconds
                            duration
                            __typename
                          }'''
    };

    final http.Response lyricResponse = await http.post(
      Uri.parse(deezerApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(jsonData),
    );

    final Map<String, dynamic> lyricResponseJson = jsonDecode(lyricResponse.body);
    //print(lyricResponseJson);

    String plainLyric = '';
    String syncedLyric = '';
    try{
      plainLyric += lyricResponseJson['data']['track']['lyrics']['text'] + "\n";
      plainLyric += "${"\nWriters: " + lyricResponseJson['data']['track']['lyrics']['writers']}\nCopyright: " + lyricResponseJson['data']['track']['lyrics']['copyright'];
    }
    catch(e){
      print(e);
      plainLyric = 'No lyrics found';
    }

    try {
      for (var line in lyricResponseJson['data']['track']['lyrics']['synchronizedLines']) {
        syncedLyric += "${line['lrcTimestamp']} ${line['line']}\n";
      }
      syncedLyric += "${"\nWriters: " + lyricResponseJson['data']['track']['lyrics']['writers']}\nCopyright: " + lyricResponseJson['data']['track']['lyrics']['copyright'];
    } catch (e) {
      print(e);
      syncedLyric = 'No lyrics found';
    }
    //print(plainLyric);

    // lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain(syncedLyric).getModel();
    // plainLyricNotifier.value = plainLyric;

    if(syncedLyric != 'No lyrics found'){
      var lyrPath = path.replaceAll(".mp3", ".lrc")
          .replaceAll(
          ".flac", ".lrc").replaceAll(".wav", ".lrc")
          .replaceAll(
          ".m4a", ".lrc");
      File lyrFile = File(lyrPath);
      lyrFile.writeAsStringSync(syncedLyric);
      song.lyricsPath = lyrFile.path;
    }
    else if (plainLyric != 'No lyrics found'){
      var lyrPath = path.replaceAll(".mp3", ".lrc")
          .replaceAll(
          ".flac", ".lrc").replaceAll(".wav", ".lrc")
          .replaceAll(
          ".m4a", ".lrc");
      File lyrFile = File(lyrPath);
      lyrFile.writeAsStringSync(plainLyric);
      song.lyricsPath = lyrFile.path;
    }
    songBox.put(song);
    return [plainLyric, syncedLyric];
  }

  void setRepeat() {
    repeatNotifier.value = !repeatNotifier.value;
    if (settings.systemTray) {
      initSystemTray();
    }
    print("repeat: ${repeatNotifier.value}");
  }

  void setShuffle() {
    int currentIndex = indexNotifier.value;
    shuffleNotifier.value = !shuffleNotifier.value;
    if (settings.systemTray) {
      initSystemTray();
    }
    print("shuffle: ${shuffleNotifier.value}");
    if (shuffleNotifier.value){
      shuffleSongs();
    }
    else{
      indexNotifier.value = settings.queue.indexOf(controllerQueue[currentIndex]);
      controllerQueue.clear();
      controllerQueue.addAll(settings.queue);
    }
    settingsBox.put(settings);
  }

  void setTimer(String time) {
    timerNotifier.value = time;
    switch(time){
      case '1 minute':
        print("1 minute");
        sleepTimerNotifier.value = 1 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 1 minute", 3500);
        break;
      case '15 minutes':
        sleepTimerNotifier.value = 15 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 15 minutes", 3500);
        break;
      case '30 minutes':
        sleepTimerNotifier.value = 30 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 30 minutes", 3500);
        break;
      case '45 minutes':
        sleepTimerNotifier.value = 45 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 45 minutes", 3500);
        break;
      case '1 hour':
        sleepTimerNotifier.value = 1 * 60 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 1 hour", 3500);
        break;
      case '2 hours':
        sleepTimerNotifier.value = 2 * 60 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 2 hours", 3500);
        break;
      case '3 hours':
        sleepTimerNotifier.value = 3 * 60 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 3 hours", 3500);
        break;
      case '4 hours':
        sleepTimerNotifier.value = 4 * 60 * 60 * 1000;
        startTimer();
        showNotification("Sleep timer set to 4 hours", 3500);
        break;
      default:
        sleepTimerNotifier.value = 0;
        showNotification("Sleep timer has been turned off", 3500);
        break;
    }
  }

  void showNotification(String message, int duration) {
    if(settings.appNotifications == false){
      return;
    }
    // userMessageNotifier.value = message;
    // Timer.periodic(
    //   const Duration(milliseconds: 10),
    //       (timer) {
    //     if(userMessageProgressNotifier.value > 0){
    //       userMessageProgressNotifier.value -= 10;
    //     }
    //     else{
    //       timer.cancel();
    //       userMessageNotifier.value = "";
    //       userMessageProgressNotifier.value = duration;
    //     }
    //   },
    // );
  }

  void shuffleSongs(){
    if(shuffleNotifier.value){
      String current = controllerQueue[indexNotifier.value];
      controllerQueue.shuffle();
      indexNotifier.value = controllerQueue.indexOf(current);
    }
  }

  void startTimer(){
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if(sleepTimerNotifier.value > 0){
        sleepTimerNotifier.value -= 10;
      }
      else{
        timer.cancel();
        audioPlayer.pause();
        playingNotifier.value = false;
        timerNotifier.value = 'Off';
        showNotification("Sleep timer has ended", 3500);
      }
    });
  }

  Future<void> updateColors(Uint8List image) async {
    DominantColors extractor = DominantColors(bytes: image, dominantColorsCount: 2);
    var colors = extractor.extractDominantColors();
    if(colors.first.computeLuminance() > 0.15 && colors.last.computeLuminance() > 0.15){
      colorNotifier.value = colors.first;
      colorNotifier2.value = Colors.black;
    }
    else if (colors.first.computeLuminance() < 0.15 && colors.last.computeLuminance() < 0.15){
      colorNotifier.value = Colors.blue;
      colorNotifier2.value = colors.first;
    }
    else{
      if(colors.first.computeLuminance() > 0.15){
        colorNotifier.value = colors.first;
        colorNotifier2.value = colors.last;
      }
      else{
        colorNotifier.value = colors.last;
        colorNotifier2.value = colors.first;
      }
    }
  }

  Future<void> updatePlaying(List<String> songs, int index) async {
    //loadingNotifier.value = true;
    //print(settings.queuePlay);
    if(settings.queuePlay == 'all'){
      settings.queue.clear();
      settings.queue.addAll(songs);
      settings.index = index;
      settingsBox.put(settings);
      controllerQueue.clear();
      controllerQueue.addAll(songs);
      indexNotifier.value = index;
      shuffleSongs();

    }
    else{
      addToQueue([songs[index]]);
    }
    //loadingNotifier.value = false;
  }
}
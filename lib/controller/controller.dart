import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';
import 'package:system_tray/system_tray.dart';
import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/metadata_type.dart';
import '../domain/playlist_type.dart';
import '../domain/settings_type.dart';
import '../utils/objectbox.g.dart';
import '../utils/dominant_color/dominant_color.dart';
import '../utils/flac_metadata/flacstream.dart';
import '../utils/id3tag/id3tag.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/lyric_reader/lyrics_reader_model.dart';
import 'objectBox.dart';


class Controller{
  late Box<Settings> settingsBox;
  late Box<MetadataType> songBox;
  late Box<PlaylistType> playlistBox;
  late Box<AlbumType> albumBox;
  late Box<ArtistType> artistBox;
  Settings settings = Settings();
  AudioPlayer audioPlayer = AudioPlayer();
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();
  final navigatorKey = GlobalKey<NavigatorState>();

  ValueNotifier<String> userMessageNotifier = ValueNotifier<String>('');
  ValueNotifier<int> userMessageProgressNotifier = ValueNotifier<int>(3500);
  ValueNotifier<String> timerNotifier = ValueNotifier<String>('Off');
  ValueNotifier<int> sleepTimerNotifier = ValueNotifier<int>(0);
  ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);
  ValueNotifier<double> speedNotifier = ValueNotifier<double>(1);
  ValueNotifier<double> balanceNotifier = ValueNotifier<double>(0);
  ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> sliderNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> minimizedNotifier = ValueNotifier<bool>(true);
  ValueNotifier<bool> hiddenNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> listNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> listChangeNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> repeatNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> shuffleNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> searchNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> retrievingChangedNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> finishedRetrievingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<LyricsReaderModel> lyricModelNotifier = ValueNotifier<LyricsReaderModel>(LyricsReaderModel());
  ValueNotifier<String> plainLyricNotifier = ValueNotifier<String>('');
  ValueNotifier<List<MetadataType>> found = ValueNotifier<List<MetadataType>>([]);
  ValueNotifier<List<MetadataType>> found2 = ValueNotifier<List<MetadataType>>([]);
  ValueNotifier<Color> colorNotifier = ValueNotifier<Color>(Colors.deepPurpleAccent.shade400); // Light color, for lyrics and sliders
  ValueNotifier<Color> colorNotifier2 = ValueNotifier<Color>(Colors.blueAccent.shade400); // Dark color, for background of player and window bar
  ValueNotifier<Uint8List> imageNotifier = ValueNotifier<Uint8List>(File("./assets/bg.png").readAsBytesSync());

  Controller(ObjectBox objectBox) {
    settingsBox = objectBox.store.box<Settings>();
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
    if(settings.showSystemTray){
      initSystemTray();
    }

    songBox = objectBox.store.box<MetadataType>();
    albumBox = objectBox.store.box<AlbumType>();
    artistBox = objectBox.store.box<ArtistType>();
    playlistBox = objectBox.store.box<PlaylistType>();
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
  }

  Future<void> createPlaylist(PlaylistType playlist) async {
    playlistBox.put(playlist);
    exportPlaylist(playlist);
  }

  Future<void> exportPlaylist(PlaylistType playlist) async {
    var file = File("${settings.directory}/${playlist.name}.m3u");
    file.writeAsStringSync("#EXTM3U\n");
    for (var song in playlist.paths){
      file.writeAsStringSync('$song\n', mode: FileMode.append);
    }
  }

  Future<void> addToPlaylist(PlaylistType playlist, List<MetadataType> songs) async {
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

  void showNotification(String message, int duration) {
    if(settings.showAppNotifications == false){
      return;
    }
    userMessageNotifier.value = message;
    Timer.periodic(
      const Duration(milliseconds: 10),
          (timer) {
        if(userMessageProgressNotifier.value > 0){
          userMessageProgressNotifier.value -= 10;
        }
        else{
          timer.cancel();
          userMessageNotifier.value = "";
          userMessageProgressNotifier.value = duration;
        }
      },
    );
  }


  Future<void> addToQueue(List<MetadataType> songs) async {
    loadingNotifier.value = true;
    if (settings.queueAdd == 'last') {
      for (int i = 0; i < songs.length; i++) {
        songs[i].orderPosition = settings.playingSongs.length + i;
        songBox.put(songs[i]);
      }
      settings.playingSongs.addAll(songs);
      settings.playingSongsUnShuffled.addAll(songs);
      if (shuffleNotifier.value) {
        settings.playingSongs.shuffle();
      }
      settingsBox.put(settings);
    }
    else if (settings.queueAdd == 'next') {
      // change the order position of the songs in the queue to make space for the new songs
      for (int i = 0; i < songs.length; i++) {
        songs[i].orderPosition = indexNotifier.value + 1 + i;
        songBox.put(songs[i]);
      }
      for (int i = indexNotifier.value + 1; i < settings.playingSongs.length; i++) {
        settings.playingSongs[i].orderPosition += songs.length;
        songBox.put(settings.playingSongs[i]);
      }
      settings.playingSongs.insertAll(indexNotifier.value + 1, songs);
      settings.playingSongsUnShuffled.insertAll(indexNotifier.value + 1, songs);
      settingsBox.put(settings);
    }
    else if (settings.queueAdd == 'first') {
      for (int i = 0; i < songs.length; i++) {
        songs[i].orderPosition = i;
        songBox.put(songs[i]);
      }
      for (int i = 0; i < settings.playingSongs.length; i++) {
        settings.playingSongs[i].orderPosition += songs.length;
        songBox.put(settings.playingSongs[i]);
      }
      settings.playingSongs.insertAll(0, songs);
      settings.playingSongsUnShuffled.insertAll(0, songs);
      settingsBox.put(settings);
    }
    loadingNotifier.value = false;
  }

  Future<void> removeFromQueue(MetadataType song) async {
    if(settings.playingSongs.length == 1){
      showNotification("The queue cannot be empty.", 3500);
      print("The queue cannot be empty");
      return;
    }

    int index = settings.playingSongs.indexOf(song);
    if (index == indexNotifier.value){
      if (index == settings.playingSongs.length - 1){
        indexNotifier.value = 0;
      }
      else{
        indexNotifier.value = index + 1;
      }
      indexChange(settings.playingSongs[indexNotifier.value]);
      await playSong();
      indexNotifier.value -= 1;
    }
    else{
      if (index < indexNotifier.value){
        indexNotifier.value -= 1;
      }
    }
    settings.playingSongs.removeAt(index);
    settings.playingSongsUnShuffled.removeAt(index);
    settingsBox.put(settings);
    listChangeNotifier.value = !listChangeNotifier.value;
  }


  Future<void> updatePlaying(List<MetadataType> songs, int index) async {
    loadingNotifier.value = true;
    if(settings.queuePlay == 'all'){
      settings.playingSongs.clear();
      settings.playingSongsUnShuffled.clear();
      for(int i = 0; i < songs.length; i++){
        songs[i].orderPosition = i;
        songBox.put(songs[i]);
      }
      settings.playingSongs.addAll(songs);
      settings.playingSongsUnShuffled.addAll(songs);
      if (shuffleNotifier.value){
        settings.playingSongs.shuffle();
      }
      settingsBox.put(settings);
    }
    else{
      addToQueue([songs[index]]);
    }
    loadingNotifier.value = false;
  }

  Future<void> retrieveSongs() async {
    List<MetadataType> songs = songBox.getAll();
    List<String> paths = [];
    for (int i = 0; i < songs.length; i++){
      paths.add(songs[i].path);
    }

    List<FileSystemEntity> allEntities = [];
    final dir = Directory(settings.directory);
    allEntities = await dir.list().toList();

    for(int i = 0; i < allEntities.length; i++){
      if(allEntities[i] is File){
        String path = allEntities[i].path.replaceAll("\\", "/");
        if (path.endsWith(".flac") || path.endsWith(".mp3") || path.endsWith(".wav") || path.endsWith(".m4a")) {
          if(paths.contains(path)){
            //print("already exists");
          }
          else{
            paths.add(allEntities[i].path);
            var song = await retrieveSong(allEntities[i].path, allEntities);
            song.orderPosition = songs.length;
            songBox.put(song);
            if (i % 25 == 0){
              retrievingChangedNotifier.value = !retrievingChangedNotifier.value;
            }
          }
        }
      }
      else if(allEntities[i] is Directory){
        allEntities.addAll(await Directory(allEntities[i].path).list().toList());
      }
    }
    await makeAlbumsArtists();

    if (settings.playingSongs.isEmpty){
      //print("empty");
      updatePlaying(songBox.query().order(MetadataType_.orderPosition).build().find(), 0);
    }
    else{
      //print("not empty");
      settings.playingSongsUnShuffled.sort((a, b) => a.orderPosition.compareTo(b.orderPosition));
      settings.playingSongs.sort((a, b) => a.orderPosition.compareTo(b.orderPosition));
      if (shuffleNotifier.value) {
        settings.playingSongs.shuffle();
      }
    }
    retrievingChangedNotifier.value = !retrievingChangedNotifier.value;

    //print(settings.playingSongsUnShuffled[settings.lastPlayingIndex].title);
    indexChange(settings.playingSongs[settings.lastPlayingIndex]);
    finishedRetrievingNotifier.value = true;
  }

  Future<MetadataType> retrieveSong(String path, List<FileSystemEntity> allEntities) async {
    MetadataType metadataVariable = MetadataType();
    metadataVariable.path = path;
    var metadataVar = await AudioTags.read(path);
    if(metadataVar == null || metadataVar.pictures.isEmpty == true){
      //print(path);
      if(path.endsWith(".flac")) {
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        String metadata = metadatas[2].toString();
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
      else if(path.endsWith(".mp3")){
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        metadataVariable.title = tags.title ?? path.replaceAll("\\", "/").split("/").last;
        metadataVariable.artists = tags.artist ?? "Unknown Artist";
        metadataVariable.album = tags.album ?? 'Unknown Album';
        metadataVariable.discNumber = int.parse(tags.trackNumber ?? "0");
        metadataVariable.trackNumber = int.parse(tags.track ?? "0");
        metadataVariable.duration = tags.duration?.inMilliseconds ?? 0;
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
    bool exists = allEntities.any((element) => element.path == lyrPath);
    //print(exists);
    if (!exists) {
      bool lyricsFound = false;
      if(path.endsWith(".flac")) {
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        String metadata = metadatas[2].toString();
        metadata = metadata.substring(1, metadata.length - 1);
        List<String> metadata2 = metadata.split(', *1234a678::876a4321*,');
        for (var metadate2 in metadata2) {
          if (metadate2.contains("LYRICS=")) {
            File lyrFile = File(path.replaceAll(".flac", ".lrc"));
            lyrFile.writeAsStringSync(metadate2.substring(7));
            metadataVariable.lyricsPath = lyrFile.path;
            lyricsFound = true;
          }
        }
      }
      else if(path.endsWith(".mp3")){
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        if (tags.lyrics.isEmpty == false) {
          File lyrFile = File(path.replaceAll(".mp3", ".lrc"));
          lyrFile.writeAsStringSync(tags.lyrics.first.toString());
          metadataVariable.lyricsPath = lyrFile.path;
          lyricsFound = true;
        }
      }
      if(!lyricsFound){
        metadataVariable.lyricsPath = "No Lyrics";
      }
    }
    else{
      metadataVariable.lyricsPath = lyrPath;
    }
    if(metadataVariable.duration == 0){
      //print("duration is 0");
      var metadataVar2 = await AudioTags.read(path);
      if (metadataVar2?.duration != null) {
        metadataVariable.duration = metadataVar2!.duration!;
      }


    }

    return metadataVariable;
  }

  Future<Uint8List> imageRetrieve(String path, bool update) async{
    Uint8List image = File("assets/bg.png").readAsBytesSync();
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
        image = imageBytes.isEmpty? File("./assets//bg.png").readAsBytesSync() : Uint8List.fromList(imageBytes.map(int.parse).toList());
      }
    }
    else{
      image = metadataVar?.pictures[0].bytes ?? File("assets/bg.png").readAsBytesSync();
    }
    if (update){
      print("image changed");
      imageNotifier.value = image;
    }
    return image;
  }

  Future<void> makeAlbumsArtists() async {
    List<MetadataType> songs = songBox.getAll();
    for(MetadataType song in songs) {
      Query<AlbumType> albumQuery = albumBox.query(AlbumType_.name.equals(song.album)).build();
      List<AlbumType> albums = albumQuery.find();
      if (albums.isEmpty){
        AlbumType album = AlbumType();
        album.name = song.album;
        album.songs.add(song);
        List<String> songArtists = song.artists.split("; ");
        for (String artist in songArtists){
          Query<ArtistType> artistQuery = artistBox.query(ArtistType_.name.equals(artist)).build();
          List<ArtistType> artists = artistQuery.find();
          if (artists.isEmpty){
            ArtistType artistType = ArtistType();
            artistType.name = artist;
            artistType.songs.add(song);
            artistBox.put(artistType);
          }
          else{
            artists.first.songs.add(song);
            artistBox.put(artists.first);
          }
        }
        albumBox.put(album);
      }
      else{
        albums.first.songs.add(song);
        albumBox.put(albums.first);
        List<String> songArtists = song.artists.split("; ");
        for (String artist in songArtists){
          Query<ArtistType> artistQuery = artistBox.query(ArtistType_.name.equals(artist)).build();
          List<ArtistType> artists = artistQuery.find();
          if (artists.isEmpty){
            ArtistType artistType = ArtistType();
            artistType.name = artist;
            artistType.songs.add(song);
            artistBox.put(artistType);
          }
          else{
            artists.first.songs.add(song);
            artistBox.put(artists.first);
          }
        }
      }
    }
  }

  Future<void> searchLyrics() async {
    plainLyricNotifier.value = 'Searching for lyrics...';
    final Map<String, String> cookies = {'arl': settings.deezerToken};
    final Map<String, String> params = {'jo': 'p', 'rto': 'c', 'i': 'c'};
    const String loginUrl = 'https://auth.deezer.com/login/arl';
    const String deezerApiUrl = 'https://pipe.deezer.com/api';
    MetadataType song = settings.playingSongs[indexNotifier.value];
    String title = song.title;
    String artist = song.artists;
    String path = song.path;
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

    lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain(syncedLyric).getModel();
    plainLyricNotifier.value = plainLyric;

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
  }

  void lyricModelReset() {
    //print(settings.playingSongs[indexNotifier.value].lyricsPath);
    if (settings.playingSongs[indexNotifier.value].lyricsPath.contains(".lrc")) {
      File lyrFile = File(settings.playingSongs[indexNotifier.value].lyricsPath);
      lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain(lyrFile.readAsStringSync()).getModel();
      if (lyricModelNotifier.value.lyrics.isEmpty) {
        lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain("No lyrics").getModel();
        plainLyricNotifier.value = lyrFile.readAsStringSync();
      }
    }
    else {
      lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain("No lyrics").getModel();
      plainLyricNotifier.value = "No lyrics";
    }
  }

  Future<void> indexChange(MetadataType song) async{
    sliderNotifier.value = 0;
    playingNotifier.value = false;
    indexNotifier.value = settings.playingSongs.indexOf(song);
    settings.lastPlayingIndex = indexNotifier.value;
    settingsBox.put(settings);

    await imageRetrieve(song.path, true);
    DominantColors extractor = DominantColors(bytes: imageNotifier.value, dominantColorsCount: 2);
    var colors = extractor.extractDominantColors();
    if(colors.first.computeLuminance() > 0.179 && colors.last.computeLuminance() > 0.179){
      colorNotifier.value = colors.first;
      colorNotifier2.value = Colors.black;
    }
    else if (colors.first.computeLuminance() < 0.179 && colors.last.computeLuminance() < 0.179){
      colorNotifier.value = Colors.blue;
      colorNotifier2.value = colors.first;
    }
    else{
      if(colors.first.computeLuminance() > 0.179){
        colorNotifier.value = colors.first;
        colorNotifier2.value = colors.last;
      }
      else{
        colorNotifier.value = colors.last;
        colorNotifier2.value = colors.first;
      }
    }
    lyricModelReset();
  }

  Future<void> playSong() async {
    if (playingNotifier.value){
      print("pause");
      await audioPlayer.pause();
      playingNotifier.value = false;
    }
    else{
      print("resume");
      await audioPlayer.play(DeviceFileSource(settings.playingSongs[indexNotifier.value].path), position: Duration(milliseconds: sliderNotifier.value));
      playingNotifier.value = true;
    }
    if (settings.showSystemTray) {
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
        newIndex = settings.playingSongs.length - 1;
      } else {
        newIndex = indexNotifier.value - 1;
      }
      indexChange(settings.playingSongs[newIndex]);
      playSong();
    }
  }

  Future<void> nextSong() async {
    int newIndex;
    if (indexNotifier.value == settings.playingSongs.length - 1) {
      newIndex = 0;
    } else {
      newIndex = indexNotifier.value + 1;
    }
    indexChange(settings.playingSongs[newIndex]);
    playSong();
  }

  Future<void> filter(String enteredKeyword, bool search) async {
    List<MetadataType> results = [];
    var query = songBox.query(MetadataType_.title.contains(enteredKeyword, caseSensitive: false) | MetadataType_.artists.contains(enteredKeyword, caseSensitive: false) | MetadataType_.album.contains(enteredKeyword, caseSensitive: false)).build();
    results = query.find();
    if(search) {
      found.value = List.from(results);
    }
    else{
      //print("found2");
      found2.value = List.from(results);
    }
  }

  void setRepeat() {
    repeatNotifier.value = !repeatNotifier.value;
    if (settings.showSystemTray) {
      initSystemTray();
    }
    print("repeat: ${repeatNotifier.value}");
  }

  void setShuffle() {
    int currentIndex = indexNotifier.value;
    shuffleNotifier.value = !shuffleNotifier.value;
    if (settings.showSystemTray) {
      initSystemTray();
    }
    print("shuffle: ${shuffleNotifier.value}");
    if (shuffleNotifier.value){
      settings.playingSongs.shuffle();
      indexNotifier.value = settings.playingSongs.indexOf(settings.playingSongsUnShuffled[currentIndex]);
    }
    else{
      indexNotifier.value = settings.playingSongsUnShuffled.indexOf(settings.playingSongs[currentIndex]);
      settings.playingSongs.clear();
      settings.playingSongs.addAll(settings.playingSongsUnShuffled);
    }
    settingsBox.put(settings);
  }

  Future<void> initSystemTray() async {
    if (settings.showSystemTray == false){
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
            image: 'bg.png',
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
}
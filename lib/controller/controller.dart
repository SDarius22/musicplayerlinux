import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';

import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/featured_artist_type.dart';
import '../domain/metadata_type.dart';
import '../domain/playlist_type.dart';
import '../domain/settings_type.dart';
import '../utils/dominant_color/dominant_color.dart';
import '../repo/repository.dart';
import '../utils/flac_metadata/flacstream.dart';
import '../utils/id3tag/id3tag.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/lyric_reader/lyrics_reader_model.dart';


class Controller{
  Settings settings = Settings.fromJson(jsonDecode(File("assets/settings.json").readAsStringSync()));
  Repository repo = Repository();
  AudioPlayer? audioPlayer;
  BuildContext? context;

  List<MetadataType> playingSongs = [];
  List<MetadataType> playingSongsUnShuffled = [];

  ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);
  ValueNotifier<double> speedNotifier = ValueNotifier<double>(1);
  ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
  ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> sliderNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> sleepTimerNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> minimizedNotifier = ValueNotifier<bool>(true);
  ValueNotifier<bool> listNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> repeatNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> shuffleNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> searchNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> finishedRetrievingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<LyricsReaderModel> lyricModelNotifier = ValueNotifier<LyricsReaderModel>(LyricsReaderModel());
  ValueNotifier<LyricUI> lyricUINotifier = ValueNotifier<LyricUI>(UINetease());
  ValueNotifier<String> plainLyricNotifier = ValueNotifier<String>('');
  ValueNotifier<List<MetadataType>> found = ValueNotifier<List<MetadataType>>([]);
  ValueNotifier<Color> colorNotifier = ValueNotifier<Color>(Colors.deepPurpleAccent.shade400); // Light color, for lyrics and sliders
  ValueNotifier<Color> colorNotifier2 = ValueNotifier<Color>(Colors.blueAccent.shade400); // Dark color, for background of player and window bar
  ValueNotifier<Uint8List> imageNotifier = ValueNotifier<Uint8List>(File("./assets/bg.png").readAsBytesSync());

  int currentPosition = 0;
  bool changed = false;

  void updateContext(BuildContext context){
    this.context = context;
    lyricModelReset();
  }

  Future<void> searchLyrics() async {
    plainLyricNotifier.value = 'Searching for lyrics...';
    final Map<String, String> cookies = {'arl': '8436641c809f643da885ce7eb45e39e6a9514f882b1541a05282a33485f6f96fc56ddb724424ec3518e25bbaa08de4e7521e5f289a14c512dd65dc2ec0ad10b83138e5d02c1531a5bf5766ecfd492d0157815bafa5f08b90dcfe51a1eba1bbbf'};
    final Map<String, String> params = {'jo': 'p', 'rto': 'c', 'i': 'c'};
    const String loginUrl = 'https://auth.deezer.com/login/arl';
    const String deezerApiUrl = 'https://pipe.deezer.com/api';
    String title = playingSongs[indexNotifier.value].title;
    String artist = playingSongs[indexNotifier.value].artists;
    String path = playingSongs[indexNotifier.value].path;
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
      playingSongs[indexNotifier.value].lyricsPath = lyrFile.path;
    }
    else if (plainLyric != 'No lyrics found'){
      var lyrPath = path.replaceAll(".mp3", ".lrc")
          .replaceAll(
          ".flac", ".lrc").replaceAll(".wav", ".lrc")
          .replaceAll(
          ".m4a", ".lrc");
      File lyrFile = File(lyrPath);
      lyrFile.writeAsStringSync(plainLyric);
      playingSongs[indexNotifier.value].lyricsPath = lyrFile.path;
    }

  }

  void lyricModelReset() {
    lyricUINotifier.value = UINetease(
        defaultSize : MediaQuery.of(context!).size.height * 0.023,
        defaultExtSize : MediaQuery.of(context!).size.height * 0.02,
        otherMainSize : MediaQuery.of(context!).size.height * 0.02,
        bias : 0.5,
        lineGap : 5,
        inlineGap : 5,
        highlightColor: colorNotifier.value,
        lyricAlign : LyricAlign.CENTER,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    //print(playingSongs[indexNotifier.value].lyricsPath);
    if (playingSongs[indexNotifier.value].lyricsPath.contains(".lrc")) {
      File lyrFile = File(playingSongs[indexNotifier.value].lyricsPath);
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

  Future<void> indexChange(int newIndex) async {
    changed = true;
    indexNotifier.value = newIndex;
    var file = File("assets/settings.json");
    settings.lastPlayingIndex = newIndex;
    file.writeAsStringSync(jsonEncode(settings.toJson()));
    await imageRetrieve(playingSongs[newIndex].path, true);
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

  void playSong() async {
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer()..play(DeviceFileSource(playingSongs[indexNotifier.value].path), volume: volumeNotifier.value);
    }
    else{
      if(changed){
        audioPlayer = AudioPlayer()..play(DeviceFileSource(playingSongs[indexNotifier.value].path), volume: volumeNotifier.value, position: const Duration(milliseconds: 0));
        playingNotifier.value = true;
        changed = false;
      }
      else{
        if (playingNotifier.value){
          audioPlayer?.pause();
          playingNotifier.value = false;
        }
        else{
          audioPlayer?.resume();
          playingNotifier.value = true;
        }
      }
    }
    audioPlayer?.onPositionChanged.listen((Duration event){
      //print(playingSongs[indexNotifier.value].duration);
      int duration = playingSongs[indexNotifier.value].duration;
      //print(event.inMilliseconds.toInt() ~/ 1000);
      if(event.inMilliseconds.toInt() ~/ 1000 == duration){
        if(repeatNotifier.value){
          print("repeat");
          audioPlayer?.stop();
          sliderNotifier.value = 0;
          playingNotifier.value = false;
          changed = true;
          playSong();
        }
        else {
          print("next");
          nextSong();
        }
      }
      else
      {
        sliderNotifier.value = event.inMilliseconds;
      }
    });

    audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      playingNotifier.value = state == PlayerState.playing;
    });
  }

  Future<void> previousSong() async {
    if(sliderNotifier.value > 5000){
      seekAudio(const Duration(milliseconds: 0));
    }
    else {
      int newIndex;
      if (indexNotifier.value == 0) {
        newIndex = playingSongs.length - 1;
      } else {
        newIndex = indexNotifier.value - 1;
      }
      audioPlayer?.stop();
      sliderNotifier.value = 0;
      playingNotifier.value = false;
      await indexChange(newIndex);
      playSong();
    }
  }

  Future<void> nextSong() async {
    int newIndex;
    if (indexNotifier.value == playingSongs.length - 1) {
      newIndex = 0;
    } else {
      newIndex = indexNotifier.value + 1;
    }
    audioPlayer?.stop();
    sliderNotifier.value = 0;
    playingNotifier.value = false;
    await indexChange(newIndex);
    playSong();
  }

  Future<void> retrieveSongs() async {
    var file = File("assets/songs.json");
    List<dynamic> toWrite = [];
    List<MetadataType> songs = [];
    List<String> paths = [];
    if (!settings.firstTime){
      String response = file.readAsStringSync();
      var data = jsonDecode(response);
      int length = data.length;
      for(int i = 0; i < length; i++){
        MetadataType song = MetadataType.fromJson(data[i]);
        paths.add(song.path);
        songs.add(song);
      }
    }
    
    List<FileSystemEntity> allEntities = [];
    final dir = Directory(settings.directory);
    allEntities = await dir.list().toList();
    for(int i = 0; i < allEntities.length; i++){
      if(allEntities[i] is Directory){
        allEntities.addAll(await Directory(allEntities[i].path).list().toList());
      }
    }
    for(int i = 0; i < allEntities.length; i++){
      if(allEntities[i] is File){
        String path = allEntities[i].path.replaceAll("\\", "/");
        //print(path);
        if (path.endsWith(".flac") || path.endsWith(".mp3") || path.endsWith(".wav") || path.endsWith(".m4a")) {
          if(paths.contains(path)){
            repo.songs.value.add(songs[paths.indexOf(path)]);
          }
          else{
            //print(path);
            paths.add(allEntities[i].path);
            repo.songs.value.add(await retrieveSong(allEntities[i].path, allEntities));
          }
          if (i % 25 == 0){
            repo.songs.value = List.from(repo.songs.value)..sort((a, b) => a.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
          }
          toWrite.add(repo.songs.value.last.toJson());
        }
      }
      progressNotifier.value = i / allEntities.length;

    }
    file.writeAsStringSync(jsonEncode(toWrite));
    repo.songs.value = List.from(repo.songs.value)..sort((a, b) => a.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
    makeAlbumsArtists();
    getPlaylists();
    await imageRetrieve(playingSongs[indexNotifier.value].path, true);
    DominantColors extractor = DominantColors(bytes: imageNotifier.value, dominantColorsCount: 2);
    var colors = extractor.extractDominantColors();
    colorNotifier.value = colors.first;
    colorNotifier2.value = colors.last;
    lyricModelReset();
    finishedRetrievingNotifier.value = true;
  }

  Future<MetadataType> retrieveSong(String path, List<FileSystemEntity> allEntities) async {
    MetadataType metadataVariable = MetadataType();

    metadataVariable.artists = '';

    var metadataVar = await AudioTags.read(path);
    if( metadataVar == null || metadataVar.pictures.isEmpty == true){
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
            metadataVariable.artists += metadate2.substring(8);
            metadataVariable.artists += "; ";
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
        String durationFromTag = tags.duration?.inMilliseconds.toString() ?? "0";
        metadataVariable.duration = int.parse(durationFromTag);
      }
    }
    else {
      metadataVariable.title = metadataVar.title ?? "Unknown Song";
      metadataVariable.album = metadataVar.album ?? "Unknown Album";
      metadataVariable.duration = metadataVar.duration ?? 0;
      metadataVariable.trackNumber = metadataVar.trackNumber ?? 0;
      metadataVariable.artists = metadataVar.trackArtist ?? "Unknown Artist";
      metadataVariable.discNumber = metadataVar.discNumber ?? 0;
    }
    var lyrPath = path.replaceAll(".mp3", ".lrc")
        .replaceAll(
        ".flac", ".lrc").replaceAll(".wav", ".lrc")
        .replaceAll(
        ".m4a", ".lrc");
    bool exists = false;
    for (FileSystemEntity entity in allEntities) {
      if (entity.path == lyrPath) {
        metadataVariable.lyricsPath = lyrPath;
        exists = true;
        break;
      }
    }
    if (!exists) {
      //print("lyrics not found");
      bool lyricsFound = false;
      if(path.endsWith(".flac")) {
        //print("flac");
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        String metadata = metadatas[2].toString();
        metadata = metadata.substring(1, metadata.length - 1);
        //print(metadata);
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
    metadataVariable.path = path;

    // if(path.endsWith(".flac")) {
    //   //print(path);
    //   var flac = FlacInfo(File(path));
    //   var metadatas = await flac.readMetadatas();
    //   String metadata = metadatas[2].toString();
    //   metadata = metadata.substring(1, metadata.length - 1);
    //   List<String> metadata2 = metadata.split(', *1234a678::876a4321*,');
    //
    //   //print(metadata2);
    //   for (var metadate2 in metadata2) {
    //     if(metadate2.contains("discNumber=")){
    //       metadataVariable.discNumber = int.parse(metadate2.substring(12));
    //       //print(metadataVariable.discNumber);
    //     }
    //   }
    // }
    // else if(path.endsWith(".mp3")){
    //   //print(path);
    //   var parser = ID3TagReader.path(path);
    //   var tags = parser.readTagSync();
    //   metadataVariable.discNumber = int.parse(tags.trackNumber ?? "0");
    // }


    if(metadataVariable.duration == 0){
      //print("duration is 0");
      var metadataVar2 = await AudioTags.read(path);
      if (metadataVar2?.duration != null) {
        metadataVariable.duration = metadataVar2!.duration!;
      }


    }
    //print(metadataVariable.duration);
    //print (metadataVariable.durationString);
    //print("song: ${metadataVariable.title} discNumber: ${metadataVariable.discNumber}");

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

  void makeAlbumsArtists() {
    for(int i = 0; i < repo.songs.value.length; i++){
      if (settings.firstTime){
        settings.lastPlaying.add(repo.songs.value[i].path);
      }
      bool albumExists = false;
      for(AlbumType album1 in repo.albums){
        if(album1.name == repo.songs.value[i].album){
          album1.songs.add(repo.songs.value[i]);
          List<String> songArtists = repo.songs.value[i].artists.split("; ");

          for(int j = 0; j < songArtists.length; j++)
          {
            bool artistInAlbum = false;
            for(int k = 0; k < album1.featuredartists.length; k++)
            {
              if(songArtists[j].replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase() == album1.featuredartists[k].name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase())
              {
                artistInAlbum = true;
                album1.featuredartists[k].appearances++;
                break;
              }
            }
            if(!artistInAlbum){
              album1.featuredartists.add(FeaturedArtistType());
              album1.featuredartists[album1.featuredartists.length - 1].name = songArtists[j];
              album1.featuredartists[album1.featuredartists.length - 1].appearances++;
            }
          }
          albumExists = true;
          break;
        }
      }
      if(!albumExists){
        repo.albums.add(AlbumType());
        repo.albums[repo.albums.length - 1].name = repo.songs.value[i].album;
        repo.albums[repo.albums.length - 1].songs.add(repo.songs.value[i]);
        List<String> songArtists = repo.songs.value[i].artists.split("; ");

        for(int j = 0; j < songArtists.length; j++)
        {
          repo.albums[repo.albums.length - 1].featuredartists.add(FeaturedArtistType());
          repo.albums[repo.albums.length - 1].featuredartists[repo.albums[repo.albums.length - 1].featuredartists.length - 1].name = songArtists[j];
          repo.albums[repo.albums.length - 1].featuredartists[repo.albums[repo.albums.length - 1].featuredartists.length - 1].appearances++;
        }
      }

      if(repo.songs.value[i].artists.endsWith("; ")){
        repo.songs.value[i].artists = repo.songs.value[i].artists.substring(0, repo.songs.value[i].artists.length - 2);
      }
      List<String> songArtists = repo.songs.value[i].artists.split("; ");

      for(String artist2 in songArtists){
        bool artistExists = false;
        for(ArtistType artist1 in repo.artists){
          if(artist1.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase() == artist2.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()){
            artist1.songs.add(repo.songs.value[i]);
            artistExists = true;
            break;
          }
        }
        if(!artistExists){
          repo.artists.add(ArtistType());
          repo.artists[repo.artists.length - 1].name = artist2.replaceAll("\"", "");
          repo.artists[repo.artists.length - 1].songs.add(repo.songs.value[i]);
        }
      }
    }

    repo.albums.sort((a, b) => a.name.compareTo(b.name));
    for(int j = 0; j < repo.artists.length; j++){
      repo.artists[j].songs.sort((a, b) => a.album.compareTo(b.album));
    }
    for(int j = 0; j < repo.albums.length; j++){
      int albumDuration = 0;
      for(int k = 0; k < repo.albums[j].songs.length; k++) {
        albumDuration += repo.albums[j].songs[k].duration;
      }
      //"${widget.controller.playingSongs[index].duration ~/ 60}:${(widget.controller.playingSongs[index].duration % 60).toString().padLeft(2, '0')}",
      // duration string but in hours, minutes, seconds
      repo.albums[j].duration = "${albumDuration ~/ 3600} hours, ${(albumDuration % 3600 ~/ 60)} minutes and ${(albumDuration % 60)} seconds";
      repo.albums[j].duration = repo.albums[j].duration.replaceAll("0 hours, ", "");
      repo.albums[j].duration = repo.albums[j].duration.replaceAll("0 minutes and ", "");



      repo.albums[j].songs.sort((a, b){
        int disc = a.discNumber.compareTo(b.discNumber);
        if(disc == 0){
          return a.trackNumber.compareTo(b.trackNumber);
        }
        else{
          return disc;
        }
      });
      repo.albums[j].featuredartists.sort((a, b) => a.appearances.compareTo(b.appearances));
    }
    repo.artists.sort((a, b) => a.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
    repo.albums.sort((a, b) => a.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
  }

  void getPlaylists(){
    for (int i = 0; i < settings.lastPlaying.length; i++) {
      for (int j = 0; j < repo.songs.value.length; j++) {
        if (settings.lastPlaying[i].toString().replaceAll("\\", "/") == repo.songs.value[j].path.toString()) {
          playingSongs.add(MetadataType());
          playingSongs[playingSongs.length - 1] = repo.songs.value[j];
          // print("Added");
        }
      }
    }



    if(playingSongs.isEmpty){
      playingSongsUnShuffled.clear();
      playingSongs.clear();
      for (int i = 0; i < repo.songs.value.length; i++) {
        playingSongs.add(MetadataType());
        playingSongs[playingSongs.length - 1] = repo.songs.value[i];
      }
    }

    playingSongsUnShuffled.clear();
    playingSongsUnShuffled.addAll(playingSongs);
    var file = File("assets/playlists.json");
    String response = file.readAsStringSync();
    var data = jsonDecode(response);
    int length = data.length;
    for(int i = 0; i < length; i++){
      List<MetadataType> songs = [];
      List<FeaturedArtistType> featuredArtists = [];
      List<String> paths = [];
      for(int j = 0; j < data[i]["paths"].length; j++){
        String rePath = data[i]["paths"][j];
        for (var element in repo.songs.value) {
          if(element.path.replaceAll("/", "\\") == rePath.replaceAll("/", "\\")){
            songs.add(element);
          }
        }

        paths.add(data[i]["paths"][j]);
      }
      //print(paths);
      for(int j = 0; j < data[i]["featuredArtists"].length; j++){
        featuredArtists.add(FeaturedArtistType());
        featuredArtists[j].name = data[i]["featuredArtists"][j]["name"];
        featuredArtists[j].appearances = data[i]["featuredArtists"][j]["appearances"];
      }
      repo.playlists.add(PlaylistType());
      repo.playlists[repo.playlists.length - 1].name = data[i]["name"];
      repo.playlists[repo.playlists.length - 1].songs.addAll(songs);
      repo.playlists[repo.playlists.length - 1].duration = data[i]["duration"];
      repo.playlists[repo.playlists.length - 1].featuredArtists.addAll(featuredArtists);
      repo.playlists[repo.playlists.length - 1].paths.addAll(paths);
    }

    if (settings.firstTime == true){
      var file = File("assets/settings.json");
      settings.firstTime = false;
      file.writeAsStringSync(jsonEncode(settings.toJson()));
    }

  }

  void filter(String enteredKeyword) {
    List<MetadataType> results = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = repo.songs.value;
    } else {
      results = repo.songs.value.where((song) => song.title.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      results.addAll(repo.songs.value.where((song) => song.artists.toLowerCase().contains(enteredKeyword.toLowerCase())).toList());
      results.addAll(repo.songs.value.where((song) => song.album.toLowerCase().contains(enteredKeyword.toLowerCase())).toList());
      results = results.toSet().toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    found.value = results;
  }

  void setSpeed(double speed){
    audioPlayer?.setPlaybackRate(speed);
  }

  void setVolume(double volume){
    audioPlayer?.setVolume(volume);
  }

  void seekAudio(Duration duration){
    audioPlayer?.seek(duration);
  }
}
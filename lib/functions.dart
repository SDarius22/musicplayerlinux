import 'package:musicplayer/palette_generator/palette_generator.dart';
import '../types/album_type.dart';
import '../types/artist_type.dart';
import '../types/featured_artist_type.dart';
import '../types/metadata_type.dart';
import '../types/playlist_type.dart';
import '../types/settings_type.dart';
import '../flac_metadata/flacstream.dart';
import '../id3tag/id3tag.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:audioplayers/audioplayers.dart';
import '../lyric_reader/lyrics_reader.dart';

class functions with ChangeNotifier{
  settings settings1 = settings.fromJson(jsonDecode(File("./assets/settings.json").readAsStringSync()));
  List<metadata_type> playingsongs = [];
  List<metadata_type> playingsongs_unshuffled = [];
  List<metadata_type> allmetadata = <metadata_type>[];
  List<album_type> allalbums = <album_type>[];
  List<artist_type> allartists = <artist_type>[];
  List<playlist> allplaylists = <playlist>[];
  List<FileSystemEntity> entities = [];
  List<FileSystemEntity> entitiesbig = [];

  double progressvalue = 0, volume = 0.5, speed = 1;
  bool retrieving = false, finished_retrieving = false, loading = false;
  bool repeat = false, playing = false, shuffle = false;
  int index = 0;
  int currentpos = 0, sliderProgress = 0, playProgress = 0, sleeptimer = 0;
  int max_value = 0;

  String currentpostlabel = "00:00";
  AudioPlayer? audioPlayer;
  Color color = Colors.grey;

  late PaletteGenerator generator;
  late var lyricModel;
  late var lyricUI;
  late List<metadata_type> found;

  void lyricModelReset() {
    lyricModel = LyricsModelBuilder.create().bindLyricToMain(playingsongs[index].lyrics).getModel();
  }

  void filter(String enteredKeyword) {
    List<metadata_type> results = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = allmetadata;
    } else {
      results = allmetadata.where((song) => song.title.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      results.addAll(allmetadata.where((song) => song.artists.toLowerCase().contains(enteredKeyword.toLowerCase())).toList());
      results.addAll(allmetadata.where((song) => song.album.toLowerCase().contains(enteredKeyword.toLowerCase())).toList());
      results = results.toSet().toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    found = results;
    notifyListeners();
  }

  Future<void> playSong() async {
    generator = await PaletteGenerator.fromImageProvider(Image.memory(playingsongs[index].image).image);
    color = generator.vibrantColor?.color ?? Colors.grey.shade400;
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer()
        ..play(DeviceFileSource(playingsongs[index].path));
    }
    else{
      audioPlayer?.play(
          DeviceFileSource(playingsongs[index].path));
    }
    playing = true;
    setVolume(volume);
    setSpeed(speed);
    lyricUI =  UINetease(
        defaultSize : 24,
        defaultExtSize : 22,
        otherMainSize : 22,
        bias : 0.5,
        lineGap : 10,
        inlineGap : 10,
        highlightColor: color,
        lyricAlign : LyricAlign.LEFT,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    lyricModel = LyricsModelBuilder.create().bindLyricToMain(playingsongs[index].lyrics).getModel();
    audioPlayer?.onDurationChanged.listen((Duration event) {
        max_value = event.inMilliseconds;
    });
    audioPlayer?.onPositionChanged.listen((Duration event) async {
      currentpos = event.inMilliseconds;
      //print(playingsongs[index].duration);
      int tduration = playingsongs[index].duration.toInt();
      tduration = tduration~/1000*1000;
      //print(tduration);
      if(currentpos.toInt() == tduration){
        if(repeat){
          print("repeat");
          playSong();
        }
        else {
          print("next");
          if (index == playingsongs.length - 1)
            index = 0;
          else
            index++;
          playSong();
        }
      }else
      {
        //generating the duration label
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rminutes = sminutes;
        int rseconds = sseconds - (sminutes * 60);
        if (rminutes < 10 && rseconds < 10) {
          currentpostlabel = "0$rminutes:0$rseconds";
        }
        else {
          if (rminutes < 10) {
            currentpostlabel = "0$rminutes:$rseconds";
          }
          else {
            if (rseconds < 10) {
              currentpostlabel = "$rminutes:0$rseconds";
            }
            else {
              currentpostlabel = "$rminutes:$rseconds";
            }
          }
        }
        sliderProgress = event.inMilliseconds;
        playProgress = event.inMilliseconds;
        notifyListeners();
      }
    });

    audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
        playing = state == PlayerState.playing;
        notifyListeners();
    });
    notifyListeners();
  }

  void setSpeed(double speed){
    audioPlayer?.setPlaybackRate(speed);
    notifyListeners();
  }

  void setVolume(double volume){
    audioPlayer?.setVolume(volume);
    notifyListeners();
  }

  void resetAudio(){
    audioPlayer = null;
    notifyListeners();
  }

  void seekAudio(Duration duration){
    audioPlayer?.seek(duration);
    notifyListeners();
  }

  Future<void> songretrieve(bool welcome) async {
    if(welcome) {
      retrieving = true;
      notifyListeners();
    }
    var file = File("./assets/songs.json");
    List<dynamic> towrite = [];
    List<metadata_type> songs = [];
    List<String> paths = [];
    if (!welcome){
      String response = file.readAsStringSync();
      var data = jsonDecode(response);
      int length = data.length;
      for(int i = 0; i < length; i++){
        metadata_type song = metadata_type();
        song.title = data[i]["title"];
        song.artists = data[i]["artists"];
        song.album = data[i]["album"];
        song.durationString = data[i]["durationString"];
        song.duration = data[i]["duration"];
        song.path = data[i]["path"].replaceAll("\\", "/");
        paths.add(song.path);
        song.lyrics = data[i]["lyrics"];
        song.tracknumber = data[i]["tracknumber"];
        song.discnumber = data[i]["discnumber"];
        songs.add(song);
      }
    }

    final dir = Directory(settings1.directory);
    entitiesbig = await dir.list().toList();
    for(int i = 0; i < entitiesbig.length; i++){
      if(entitiesbig[i] is Directory){
        entitiesbig.addAll(await Directory(entitiesbig[i].path).list().toList());
      }
    }
    for(int i = 0; i < entitiesbig.length; i++){
      if(entitiesbig[i] is File){
        String path = entitiesbig[i].path.replaceAll("\\", "/");
        if (path.endsWith(".flac") || path.endsWith(".mp3") || path.endsWith(".wav") || path.endsWith(".m4a")) {
          //print(path);
          entities.add(entitiesbig[i]);
          if(paths.contains(path)){
            allmetadata.add(songs[paths.indexOf(path)]);
            //allmetadata.last.image = await imageretrieve(path);
          }
          else{
            allmetadata.add(await retrievesong(entitiesbig[i].path));
            paths.add(entitiesbig[i].path);
            //towrite.add(allmetadata.last.toJson2());
          }

          towrite.add(allmetadata.last.toJson2());
          //allmetadata.add(await retrievesong(entitiesbig[i].path));
        }
      }
      if(welcome) {
          progressvalue = i / entitiesbig.length;
          notifyListeners();
      }

    }
    file.writeAsStringSync(jsonEncode(towrite));
    allmetadata.sort((a, b) => a.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
    makealbumsnartist(welcome);
    getplaylists();

    await imageretrieve(playingsongs[index].path);

    generator = await PaletteGenerator.fromImageProvider(Image.memory(playingsongs[index].image).image);
    color = generator.vibrantColor?.color ?? Colors.grey.shade400;
    lyricUI =  UINetease(
        defaultSize : 24,
        defaultExtSize : 22,
        otherMainSize : 22,
        bias : 0.5,
        lineGap : 10,
        inlineGap : 10,
        highlightColor: color,
        lyricAlign : LyricAlign.LEFT,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    lyricModelReset();

    retrieving = false;
    finished_retrieving = true;
    notifyListeners();

  }

  Future<metadata_type> retrievesong(String path) async {
    var metadatavar;
    metadata_type metadatavariable = metadata_type();

    metadatavariable.artists = '';
    metadatavariable.durationString = '';
    int sminutes = 0;
    int sseconds = 0;

    metadatavar = await MetadataRetriever.fromFile(File(path));
    if(metadatavar.albumArt == null){
      if(path.endsWith(".flac")) {
        //print(path);
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        String metadata = metadatas[2].toString();
        List<String> imagebytes = metadatas[3].toString().substring(
            1, metadatas[3]
            .toString()
            .length - 1).split(", ");
        Uint8List image = Uint8List.fromList(
            imagebytes.map(int.parse).toList());
        metadatavariable.image = image;
        metadata = metadata.substring(1, metadata.length - 1);
        List<String> metadata2 = metadata.split(', *1234a678::876a4321*,');

        //print(metadata2);
        for (var metadate2 in metadata2) {
          if (metadate2.contains("TITLE=")) {
            metadatavariable.title = metadate2.substring(6);
          }
          if (metadate2.contains("ARTIST=") &&
              !metadate2.contains("ALBUMARTIST=")) {
            metadatavariable.artists += metadate2.substring(8);
            metadatavariable.artists += "; ";
          }
          if (metadate2.contains("TRACKNUMBER=")) {
            metadatavariable.tracknumber = int.parse(metadate2.substring(13));
          }
          if(metadate2.contains("DISCNUMBER=")){
            metadatavariable.discnumber = int.parse(metadate2.substring(12));
            //print(metadatavariable.discnumber);
          }
          if (metadate2.contains("ALBUM=")) {
            metadatavariable.album = metadate2.substring(7);
          }
          if (metadate2.contains("LENGTH=")) {
            metadatavariable.duration = int.parse(metadate2.substring(8));
            sminutes = Duration(milliseconds: metadatavariable.duration)
                .inMinutes;
            sseconds = Duration(milliseconds: metadatavariable.duration)
                .inSeconds;

            int rminutes = sminutes;
            int rseconds = sseconds - (sminutes * 60);
            if (rminutes < 10 && rseconds < 10) {
              metadatavariable.durationString = "0$rminutes:0$rseconds";
            }
            else {
              if (rminutes < 10) {
                metadatavariable.durationString = "0$rminutes:$rseconds";
              }
              else {
                if (rseconds < 10) {
                  metadatavariable.durationString = "$rminutes:0$rseconds";
                }
                else {
                  metadatavariable.durationString = "$rminutes:$rseconds";
                }
              }
            }
          }
        }
      }
      else if(path.endsWith(".mp3")){
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        metadatavariable.title = tags.title ?? path.replaceAll("\\", "/").split("/").last;
        metadatavariable.artists = tags.artist ?? "Unknown Artist";
        metadatavariable.album = tags.album ?? 'Unknown Album';
        metadatavariable.discnumber = int.parse(tags.trackNumber ?? "0");
        metadatavariable.tracknumber = int.parse(tags.track ?? "0");
        String durationfromtag = tags.duration?.inMilliseconds.toString() ?? "0";
        metadatavariable.duration = int.parse(durationfromtag);
        sminutes = Duration(milliseconds: metadatavariable.duration)
            .inMinutes;
        sseconds = Duration(milliseconds: metadatavariable.duration)
            .inSeconds;

        int rminutes = sminutes;
        int rseconds = sseconds - (sminutes * 60);
        if (rminutes < 10 && rseconds < 10) {
          metadatavariable.durationString = "0$rminutes:0$rseconds";
        }
        else {
          if (rminutes < 10) {
            metadatavariable.durationString = "0$rminutes:$rseconds";
          }
          else {
            if (rseconds < 10) {
              metadatavariable.durationString = "$rminutes:0$rseconds";
            }
            else {
              metadatavariable.durationString = "$rminutes:$rseconds";
            }
          }
        }
        List<String> imagebytes = tags.pictures.isEmpty ? [] : tags.pictures[0].toString().substring(21, tags.pictures.first.toString().length - 3).split(", ");
        Uint8List image = imagebytes.isEmpty? File("./assets/bg.png").readAsBytesSync() : Uint8List.fromList(imagebytes.map(int.parse).toList());
        metadatavariable.image = image;
      }
    }
    else {
      metadatavariable.title = metadatavar.trackName ?? "Unknown Song";
      metadatavariable.album = metadatavar.albumName ?? "Unknown Album";
      metadatavariable.duration = metadatavar.trackDuration ?? 0;
      metadatavariable.tracknumber = metadatavar.trackNumber ?? 0;
      metadatavariable.image = metadatavar.albumArt ?? File(
          "./assets/bg.png").readAsBytesSync();
      if (metadatavar.trackArtistNames.length > 0) {
        metadatavariable.artists = '';
        if (metadatavar.trackArtistNames.length == 1) {
          metadatavariable.artists = metadatavar.trackArtistNames[0];
        } else {
          for (String artist in metadatavar.trackArtistNames) {
            metadatavariable.artists = metadatavariable.artists + artist + "; ";
          }
          metadatavariable.artists.replaceAll(" ; ", "; ");
          if(metadatavariable.artists.endsWith("; ")) {
            metadatavariable.artists = metadatavariable.artists.substring(
                0, metadatavariable.artists.length - 2);
          }
        }
      }
      else {
        metadatavariable.artists = "Unknown Artist";
      }

      if (metadatavar.trackDuration != null) {
        sminutes = Duration(milliseconds: metadatavar.trackDuration)
            .inMinutes;
        sseconds = Duration(milliseconds: metadatavar.trackDuration)
            .inSeconds;
      }
      int rminutes = sminutes;
      int rseconds = sseconds - (sminutes * 60);
      if (rminutes < 10 && rseconds < 10) {
        metadatavariable.durationString = "0$rminutes:0$rseconds";
      }
      else {
        if (rminutes < 10) {
          metadatavariable.durationString = "0$rminutes:$rseconds";
        }
        else {
          if (rseconds < 10) {
            metadatavariable.durationString = "$rminutes:0$rseconds";
          }
          else {
            metadatavariable.durationString = "$rminutes:$rseconds";
          }
        }
      }
    }
    var lyrpath = path.replaceAll(".mp3", ".lrc")
        .replaceAll(
        ".flac", ".lrc").replaceAll(".wav", ".lrc")
        .replaceAll(
        ".m4a", ".lrc");
    bool exists = false;
    for (FileSystemEntity entity in entitiesbig) {
      if (entity.path == lyrpath && lyrpath.endsWith(".lrc")) {
        //print(lyrpath);
        File lyricfile = File(lyrpath);
        metadatavariable.lyrics = await lyricfile.readAsString();
        exists = true;
        break;
      }
    }
    if (!exists) {
      metadatavariable.lyrics = "No Lyrics";
    }
    metadatavariable.path = path;

    if(path.endsWith(".flac")) {
      //print(path);
      var flac = FlacInfo(File(path));
      var metadatas = await flac.readMetadatas();
      String metadata = metadatas[2].toString();
      metadata = metadata.substring(1, metadata.length - 1);
      List<String> metadata2 = metadata.split(', *1234a678::876a4321*,');

      //print(metadata2);
      for (var metadate2 in metadata2) {
        if(metadate2.contains("DISCNUMBER=")){
          metadatavariable.discnumber = int.parse(metadate2.substring(12));
          //print(metadatavariable.discnumber);
        }
      }
    }
    else if(path.endsWith(".mp3")){
      //print(path);
      var parser = ID3TagReader.path(path);
      var tags = parser.readTagSync();
      metadatavariable.discnumber = int.parse(tags.trackNumber ?? "0");
    }


    if(metadatavariable.duration == 0){
      var metadatavar2;
      metadatavar2 = await MetadataRetriever.fromFile(File(metadatavariable.path));
      if (metadatavar2.trackDuration != null) {
        metadatavariable.duration = metadatavar2.trackDuration;
        sminutes = Duration(milliseconds: metadatavar.trackDuration)
            .inMinutes;
        sseconds = Duration(milliseconds: metadatavar.trackDuration)
            .inSeconds;
        int rminutes = sminutes;
        int rseconds = sseconds - (sminutes * 60);
        if (rminutes < 10 && rseconds < 10) {
          metadatavariable.durationString = "0$rminutes:0$rseconds";
        }
        else {
          if (rminutes < 10) {
            metadatavariable.durationString = "0$rminutes:$rseconds";
          }
          else {
            if (rseconds < 10) {
              metadatavariable.durationString = "$rminutes:0$rseconds";
            }
            else {
              metadatavariable.durationString = "$rminutes:$rseconds";
            }
          }
        }
      }


    }

    //print("song: ${metadatavariable.title} discnumber: ${metadatavariable.discnumber}");

    return metadatavariable;
  }

  Future<Uint8List> imageretrieve(String path) async{
    loading = true;
    int pathindex = -1;
    bool _found = false;
    for(int i = 0; i < allmetadata.length && _found == false; i++){
      if(allmetadata[i].path == path){
        //print("found");
        pathindex = i;
        allmetadata[i].imageloaded = true;
        if(playingsongs.contains(allmetadata[i])){
          // print("${path} found in playingsongs");
          playingsongs[playingsongs.indexOf(allmetadata[i])].imageloaded = true;
        }
        _found = true;
      }
    }
    if(_found == false)
      print("how?");
    Uint8List image = File("./assets//bg.png").readAsBytesSync();
    var metadatavar = await MetadataRetriever.fromFile(File(path));
    if(metadatavar.albumArt == null){
      if(path.endsWith(".flac")) {
        var flac = FlacInfo(File(path));
        var metadatas = await flac.readMetadatas();
        List<String> imagebytes = metadatas[3].toString().substring(
            1, metadatas[3]
            .toString()
            .length - 1).split(", ");
        image = Uint8List.fromList(
            imagebytes.map(int.parse).toList());
      }
      else if(path.endsWith(".mp3")) {
        //print(path);
        var parser = ID3TagReader.path(path);
        var tags = parser.readTagSync();
        List<String> imagebytes = tags.pictures.isEmpty ? [] : tags.pictures[0].toString().substring(21, tags.pictures.first.toString().length - 3).split(", ");
        image = imagebytes.isEmpty? File("./assets//bg.png").readAsBytesSync() : Uint8List.fromList(imagebytes.map(int.parse).toList());
      }
    }
    else{
      image = metadatavar.albumArt ?? File(
          "./assets//bg.png").readAsBytesSync();
    }

    allmetadata[pathindex].image = image;
    if(playingsongs.contains(allmetadata[pathindex])){
      playingsongs[playingsongs.indexOf(allmetadata[pathindex])].image = image;
    }

    if(found.contains(allmetadata[pathindex])){
      found[found.indexOf(allmetadata[pathindex])].image = image;
    }

    loading = false;
    notifyListeners();
    return image;
  }

  void makealbumsnartist(bool welcome) {

    for(int i = 0; i < allmetadata.length; i++){
      if (welcome){
        settings1.lastplaying.add(allmetadata[i].path);
      }
      bool albumexists = false;
      for(album_type album1 in allalbums){
        if(album1.name == allmetadata[i].album){
          album1.songs.add(allmetadata[i]);
          List<String> songartists = allmetadata[i].artists.split("; ");

          for(int j = 0; j < songartists.length; j++)
          {
            bool artistinalbum = false;
            for(int k = 0; k < album1.featuredartists.length; k++)
            {
              if(songartists[j].replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase() == album1.featuredartists[k].name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase())
              {
                artistinalbum = true;
                album1.featuredartists[k].appearances++;
                break;
              }
            }
            if(!artistinalbum){
              album1.featuredartists.add(featured_artist_type());
              album1.featuredartists[album1.featuredartists.length - 1].name = songartists[j];
              album1.featuredartists[album1.featuredartists.length - 1].appearances++;
            }
          }
          //album1.featuredartists.addAll(allmetadata[i].artists.split("; "));
          albumexists = true;
          break;
        }
      }
      if(!albumexists){
        allalbums.add(album_type());
        allalbums[allalbums.length - 1].name = allmetadata[i].album;
        allalbums[allalbums.length - 1].songs.add(allmetadata[i]);
        allalbums[allalbums.length - 1].image = allmetadata[i].image;
        List<String> songartists = allmetadata[i].artists.split("; ");

        for(int j = 0; j < songartists.length; j++)
        {
          allalbums[allalbums.length - 1].featuredartists.add(featured_artist_type());
          allalbums[allalbums.length - 1].featuredartists[allalbums[allalbums.length - 1].featuredartists.length - 1].name = songartists[j];
          allalbums[allalbums.length - 1].featuredartists[allalbums[allalbums.length - 1].featuredartists.length - 1].appearances++;
        }
        //allalbums[allalbums.length - 1].featuredartists.addAll(allmetadata[i].artists.split("; "));
      }

      if(allmetadata[i].artists.endsWith("; ")){
        allmetadata[i].artists = allmetadata[i].artists.substring(0, allmetadata[i].artists.length - 2);
      }
      List<String> songartists = allmetadata[i].artists.split("; ");

      for(String artist2 in songartists){
        bool artistexists = false;
        for(artist_type artist1 in allartists){
          if(artist1.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase() == artist2.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()){
            artist1.songs.add(allmetadata[i]);
            artistexists = true;
            break;
          }
        }
        if(!artistexists){
          allartists.add(artist_type());
          allartists[allartists.length - 1].name = artist2.replaceAll("\"", "");
          allartists[allartists.length - 1].songs.add(allmetadata[i]);
        }
      }
    }

    allalbums.sort((a, b) => a.name.compareTo(b.name));
    for(int j = 0; j < allartists.length; j++){
      allartists[j].songs.sort((a, b) => a.album.compareTo(b.album));
      allartists[j].image = allartists[j].songs[0].image;
    }
    for(int j = 0; j < allalbums.length; j++){
      int albumduration = 0;
      for(int k = 0; k < allalbums[j].songs.length; k++) {
        albumduration += allalbums[j].songs[k].duration;
      }
      //print(albumduration);
      //print(allalbums[j].name);
      // print("\n");
      int shours = Duration(milliseconds: albumduration).inHours;
      int sminutes = Duration(milliseconds: albumduration).inMinutes;
      //print(sminutes);
      int sseconds = Duration(milliseconds: albumduration).inSeconds;
      int rhours = shours;
      int rminutes = sminutes - (shours * 60);
      //print(rminutes);
      int rseconds = sseconds - (sminutes * 60);

      if(rhours == 0){
        if(rminutes == 0){
          allalbums[j].duration = "$rseconds seconds";
        }
        else if(rseconds == 0){
          allalbums[j].duration = "$rminutes minutes";
        }
        else{
          allalbums[j].duration = "$rminutes minutes and $rseconds seconds";
        }
      }
      else{
        if(rhours != 1) {
          if (rminutes == 0) {
            allalbums[j].duration = "$rhours hours and $rseconds seconds";
          }
          else if (rseconds == 0) {
            allalbums[j].duration = "$rhours hours and $rminutes minutes";
          }
          else {
            allalbums[j].duration =
            "$rhours hours, $rminutes minutes and $rseconds seconds";
          }
        }
        else{
          if (rminutes == 0) {
            allalbums[j].duration = "$rhours hour and $rseconds seconds";
          }
          else if (rseconds == 0) {
            allalbums[j].duration = "$rhours hour and $rminutes minutes";
          }
          else {
            allalbums[j].duration =
            "$rhours hour, $rminutes minutes and $rseconds seconds";
          }
        }
      }




      allalbums[j].songs.sort((a, b){
        int disc = a.discnumber.compareTo(b.discnumber);
        if(disc == 0){
          return a.tracknumber.compareTo(b.tracknumber);
        }
        else{
          return disc;
        }
      });
      allalbums[j].featuredartists.sort((a, b) => a.appearances.compareTo(b.appearances));
    }
    allartists.sort((a, b) => a.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
    allalbums.sort((a, b) => a.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.name.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));

    if (settings1.firsttime == true){
      playingsongs_unshuffled.clear();
      playingsongs.clear();

      playingsongs.addAll(allmetadata);
      playingsongs_unshuffled.addAll(allmetadata);

      var file = File("assets/settings.json");
      settings1.firsttime = false;
      file.writeAsStringSync(jsonEncode(settings1.toJson()));
    }

  }

  void getplaylists(){
    for (int i = 0; i < settings1.lastplaying.length; i++) {
      for (int j = 0; j < allmetadata.length; j++) {
        if (settings1.lastplaying[i].toString().replaceAll("\\", "/") == allmetadata[j].path.toString()) {
          playingsongs.add(allmetadata[j]);
         // print("Added");
        }
      }
    }
    if(playingsongs.isEmpty){
      playingsongs.add(allmetadata[0]);
    }
    // playingsongs[index].image = await imageretrieve(playingsongs[index].path);
    // allmetadata[allmetadata.indexOf(playingsongs[index])].image = playingsongs[index].image;
    // allmetadata[allmetadata.indexOf(playingsongs[index])].imageloaded = true;

    playingsongs_unshuffled.clear();
    playingsongs_unshuffled.addAll(playingsongs);
    var file = File("assets/playlists.json");
    String response = file.readAsStringSync();
    var data = jsonDecode(response);
    int length = data.length;
    for(int i = 0; i < length; i++){
      List<metadata_type> songs = [];
      List<featured_artist_type> featuredartists = [];
      List<String> paths = [];
      for(int j = 0; j < data[i]["paths"].length; j++){
        String repath = data[i]["paths"][j];
        allmetadata.forEach((element) {
          if(element.path.replaceAll("/", "\\") == repath.replaceAll("/", "\\")){
            songs.add(element);
          }
        });

        paths.add(data[i]["paths"][j]);
      }
      //print(paths);
      for(int j = 0; j < data[i]["featuredartists"].length; j++){
        featuredartists.add(featured_artist_type());
        featuredartists[j].name = data[i]["featuredartists"][j]["name"];
        featuredartists[j].appearances = data[i]["featuredartists"][j]["appearances"];
      }
      allplaylists.add(playlist());
      allplaylists[allplaylists.length - 1].name = data[i]["name"];
      allplaylists[allplaylists.length - 1].songs.addAll(songs);
      allplaylists[allplaylists.length - 1].duration = data[i]["duration"];
      allplaylists[allplaylists.length - 1].featuredartists.addAll(featuredartists);
      allplaylists[allplaylists.length - 1].image = allplaylists[allplaylists.length - 1].songs[0].image;
      allplaylists[allplaylists.length - 1].paths.addAll(paths);

    }

  }

}


import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/domain/album_type.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';
import '../controller/controller.dart';
import '../domain/metadata_type.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/progress_bar/audio_video_progress_bar.dart';
import 'settings.dart';

class AlbumWidget extends StatefulWidget {
  final Controller controller;
  final AlbumType album;
  const AlbumWidget({super.key, required this.controller, required this.album});

  @override
  _AlbumWidget createState() => _AlbumWidget();
}

class _AlbumWidget extends State<AlbumWidget> {
  bool _volume = true, search = false;
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  FocusNode searchNode = FocusNode();


  @override
  void initState() {
    super.initState();
  }

  // Column(
  // children:[
  // Row(
  // children:[
  // Container(
  // width: 25,
  // height: 250,
  // alignment: Alignment.topCenter,
  // child:
  // Column(
  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  // crossAxisAlignment: CrossAxisAlignment.center,
  // children: [
  // IconButton(
  // onPressed: (){
  // setState(() {
  // _inalbum = false;
  // create = false;
  // playlistname = "New playlist";
  // artistsforalbum = "";
  // _hovereditem = -1;
  // _newplaylistsongs = [];
  // });
  // },
  // icon: Icon(FluentIcons.arrow_left_16_filled, color: Colors.white,),
  // ),
  // IconButton(onPressed: (){
  // print("Add ${displayedalbum}");
  // for(metadata1 song in allalbums[displayedalbum].songs) {
  // _songstoadd.add(song);
  // }
  // setState(() {
  // addelement = true;
  // });
  // }, icon: Icon(FluentIcons.add_12_filled, color: Colors.white, size: 25,),),
  // IconButton(onPressed: (){
  // playingsongs.clear();
  // playingsongs_unshuffled.clear();
  //
  // playingsongs.addAll(allalbums[displayedalbum].songs);
  // playingsongs_unshuffled.addAll(allalbums[displayedalbum].songs);
  //
  // if(shuffle == true)
  // playingsongs.shuffle();
  //
  // var file = File("assets/settings.json");
  // settings1.lastplaying.clear();
  //
  // for(int i = 0; i < playingsongs.length; i++){
  // settings1.lastplaying.add(playingsongs[i].path);
  // }
  // settings1.lastplayingindex = playingsongs.indexOf(playingsongs_unshuffled[0]);
  // file.writeAsStringSync(jsonEncode(settings1.toJson()));
  //
  // index = settings1.lastplayingindex;
  // playsong();
  // }, icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 25,),),
  // ]
  // ),
  //
  // ),
  // Container(
  // height: 250,
  // width: 300,
  // padding: EdgeInsets.only(left: 50),
  // child: DecoratedBox(
  // decoration: BoxDecoration(
  // borderRadius: BorderRadius.circular(10),
  // image: DecorationImage(
  // image: Image.memory(allalbums[displayedalbum].songs.first.image).image,
  // fit: BoxFit.cover,
  // ),
  // ),
  // ),
  // ),
  // Container(
  // width: 50,
  // ),
  // Column(
  // mainAxisAlignment: MainAxisAlignment.center,
  // crossAxisAlignment: CrossAxisAlignment.start,
  // children: [
  // Text(
  // "Album name:",
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 22,
  // fontWeight: FontWeight.normal,
  // ),
  // ),
  // Container(
  // height: 5,
  // ),
  // Text(
  // allalbums[displayedalbum].name,
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 24,
  // fontWeight: FontWeight.bold,
  // ),
  // textAlign: TextAlign.center,
  // ),
  // Container(
  // height: 10,
  // ),
  // Text(
  // "Featured artists:",
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 22,
  // fontWeight: FontWeight.normal,
  // ),
  // ),
  // Container(
  // height: 5,
  // ),
  // Text(
  // artistsforalbum,
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 20,
  // fontWeight: FontWeight.bold,
  // ),
  // textAlign: TextAlign.center,
  // ),
  // Container(
  // height: 10,
  // ),
  // Text(
  // "Album duration:",
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 22,
  // fontWeight: FontWeight.normal,
  // ),
  // ),
  // Container(
  // height: 5,
  // ),
  // Text(
  // allalbums[displayedalbum].duration,
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 20,
  // fontWeight: FontWeight.bold,
  // ),
  // textAlign: TextAlign.center,
  // ),
  // ],
  // ),
  // ],
  //
  // ),
  // Container(
  // height: 25,
  // ),
  // Container(
  // height: 425,
  // child: ListView.builder(
  // itemCount: allalbums[displayedalbum].songs.length + 3,
  // itemBuilder: (context, int _aindex) {
  // return _aindex < allalbums[displayedalbum].songs.length ?
  // Container(
  // height: 110,
  // child: ElevatedButton(
  // style: ElevatedButton.styleFrom(
  // backgroundColor: Color(0xFF0E0E0E),
  // ),
  // onPressed: () {
  // playingsongs.clear();
  // playingsongs_unshuffled.clear();
  //
  // playingsongs.addAll(allalbums[displayedalbum].songs);
  // playingsongs_unshuffled.addAll(allalbums[displayedalbum].songs);
  //
  // if(shuffle == true)
  // playingsongs.shuffle();
  //
  // var file = File("assets/settings.json");
  // settings1.lastplaying.clear();
  //
  // for(int i = 0; i < playingsongs.length; i++){
  // settings1.lastplaying.add(playingsongs[i].path);
  // }
  // settings1.lastplayingindex = playingsongs.indexOf(playingsongs_unshuffled[_aindex]);
  // file.writeAsStringSync(jsonEncode(settings1.toJson()));
  //
  // index = playingsongs.indexOf(playingsongs_unshuffled[_aindex]);
  // print(index.toString() + "\n\n\n");
  // playsong();
  // },
  // child: Row(
  // children: [
  // Container(
  // height: 100,
  // width: 110,
  // padding: EdgeInsets.only(left: 10),
  // child: DecoratedBox(
  // decoration: BoxDecoration(
  // borderRadius: BorderRadius.circular(10),
  // image: DecorationImage(
  // image: Image.memory(allalbums[displayedalbum].songs.first.image).image,
  // fit: BoxFit.cover,
  // ),
  // ),
  // child: ClipRRect(
  // // Clip it cleanly.
  // child: BackdropFilter(
  // filter: ImageFilter.blur(
  // sigmaX: 1, sigmaY: 1),
  // child: Container(
  // color: Colors.black.withOpacity(0.3),
  // alignment: Alignment.center,
  // child: Text(
  // allalbums[displayedalbum].songs[_aindex].tracknumber.toString(),
  // style: TextStyle(
  // color: Colors.white,
  // fontSize: 35,
  // fontWeight: FontWeight.normal,
  // ),
  // textAlign: TextAlign.center,
  // ),
  // ),
  // ),
  // ),
  // ),
  // ),
  // Container(
  // width: 20,
  // ),
  // Column(
  // mainAxisAlignment: MainAxisAlignment.center,
  // crossAxisAlignment: CrossAxisAlignment.start,
  // children: [
  // Text(
  // allalbums[displayedalbum].songs[_aindex].title.toString(),
  // style: allalbums[displayedalbum].songs[_aindex] == playingsongs[index] && allalbums[displayedalbum].name == playingsongs[index].album ? TextStyle(
  // color: Colors.blue,
  // fontSize: 20,
  // ) : TextStyle(
  // color: Colors.white,
  // fontSize: 20,
  // ),
  // ),
  // Container(
  // height: 5,
  // ),
  // Text(allalbums[displayedalbum].songs[_aindex].artists.toString(),
  // style: allalbums[displayedalbum].songs[_aindex] == playingsongs[index]? TextStyle(
  // color: Colors.blue,
  // fontSize: 18,
  // ) : TextStyle(
  // color: Colors.white,
  // fontSize: 18,
  // ),
  // ),
  // ]
  // ),
  // Spacer(),
  // Text(
  // allalbums[displayedalbum].songs[_aindex].durationString,
  // style: allalbums[displayedalbum].songs[_aindex] == playingsongs[index]? TextStyle(
  // color: Colors.blue,
  // fontSize: 18,
  // ) : TextStyle(
  // color: Colors.white,
  // fontSize: 18,
  // ),
  // ),
  // Container(
  // width: 20,
  // ),
  // ],
  // ),
  // ),
  //
  // ) :
  // Container(
  // height: 50,
  // );
  // },
  // ),
  // ),
  // ]
  // )


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          Container(
              padding: const EdgeInsets.only(right: 25),
              child: ValueListenableBuilder(
                valueListenable: _visible,
                builder: (context, value, child) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: _visible.value,
                          child: SizedBox(
                              height: height * 0.05,
                              width: width * 0.1,
                              child:
                              MouseRegion(
                                onEnter: (event) {
                                  _visible.value = true;
                                },
                                onExit: (event) {
                                  _visible.value = false;
                                },
                                child: Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  value: widget.controller.volumeNotifier.value,
                                  activeColor: widget.controller.colorNotifier.value,
                                  thumbColor: Colors.white,
                                  inactiveColor: Colors.white,
                                  onChanged: (double value) {
                                    setState(() {
                                      widget.controller.volumeNotifier.value = value;
                                      widget.controller.setVolume(widget.controller.volumeNotifier.value);
                                    });
                                  },
                                ),
                              )
                          ),
                        ),
                        MouseRegion(
                          onEnter: (event) {
                            _visible.value = true;
                          },
                          onExit: (event) {
                            _visible.value = false;
                          },
                          child: IconButton(
                            icon: _volume ? const Icon(FluentIcons.speaker_2_16_filled) : const Icon(FluentIcons.speaker_mute_16_filled),
                            onPressed: () {
                              if(_volume) {
                                widget.controller.volumeNotifier.value = 0;
                              }
                              else {
                                widget.controller.volumeNotifier.value = 0.1;
                              }
                              _volume = !_volume;
                              setState(() {
                                widget.controller.setVolume(widget.controller.volumeNotifier.value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(onPressed: (){
                          print("Search");
                          setState(() {
                            search = !search;
                          });
                          searchNode.requestFocus();
                        }, icon: const Icon(FluentIcons.search_16_filled)),
                        Container(
                          width: 20,
                        ),
                        IconButton(onPressed: (){
                          print("Tapped settings");
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                            return Settings(controller: widget.controller,);
                          }));
                        }, icon: const Icon(FluentIcons.settings_16_filled))//Icon(Icons.more_vert)),
                      ],
                    ),
              ))
        ],
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(height * 0.01),
          child: Column(
            children: [
              Row(
                children: [
                  FutureBuilder(
                      future: widget.controller.imageRetrieve(widget.album.songs.first.path, false),
                      builder: (context, snapshot){
                        if(snapshot.hasData) {
                          return Container(
                            height: height * 0.25,
                            width: width * 0.3,
                            padding: EdgeInsets.only(left: 50),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: Image.memory(snapshot.data!).image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      }
                  ),
                  Container(
                    width: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Album name:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(
                        widget.album.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        "Featured artists:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(
                        widget.album.featuredartists[0].name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        "Album duration:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(
                        widget.album.duration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        height: 450,
                        width: 300,
                        child: ListView.builder(
                            itemCount: widget.album.songs.length + 3,
                            itemBuilder: (context, index){
                              return index < widget.album.songs.length ?
                                  Container(
                                    height: 50,
                                    width: 300,
                                    child: Text (
                                      widget.album.songs[index].title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                  )

                              ) :
                              Container(
                                height: 50,
                              );
                            }
                        ),
                      ),

                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
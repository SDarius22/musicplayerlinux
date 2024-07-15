import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import '../controller/controller.dart';
import 'settings.dart';

class PlaylistWidget extends StatefulWidget {
  final Controller controller;
  final PlaylistType playlist;
  const PlaylistWidget({super.key, required this.controller, required this.playlist});

  @override
  _PlaylistWidget createState() => _PlaylistWidget();
}

class _PlaylistWidget extends State<PlaylistWidget> {
  bool _volume = true, search = false;
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  FocusNode searchNode = FocusNode();

  String featuredArtists = "";


  @override
  void initState() {
    for(int i = 0; i < widget.playlist.featuredartists.length; i++) {
      featuredArtists += widget.playlist.featuredartists[i].name;
      if(i != widget.playlist.featuredartists.length - 1) {
        featuredArtists += ", ";
      }
    }
    super.initState();
  }


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
                              child: MouseRegion(
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
                          //print("Search");
                          setState(() {
                            search = !search;
                          });
                          searchNode.requestFocus();
                        }, icon: const Icon(FluentIcons.search_16_filled)),
                        Container(
                          width: 20,
                        ),
                        IconButton(onPressed: (){
                          //print("Tapped settings");
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                            return Settings(controller: widget.controller,);
                          }));
                        }, icon: const Icon(FluentIcons.settings_16_filled))//Icon(Icons.more_vert)),
                      ],
                    ),
              )
          )
        ],
      ),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: width,
          height: height,
          padding: EdgeInsets.only(
            top: height * 0.025,
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.025
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: height * 0.5,
                      padding: EdgeInsets.only(
                        bottom: height * 0.01,
                      ),
                      //color: Colors.red,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FutureBuilder(
                            future: widget.controller.imageRetrieve(widget.playlist.songs.first.path, false),
                            builder: (context, snapshot){
                              if(snapshot.hasData) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(width * 0.025),
                                    image: DecorationImage(
                                      image: Image.memory(snapshot.data!).image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }
                              else{
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }
                            }
                        ),
                      ),
                    ),
                    Text(
                      "Playlist name:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      widget.playlist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: boldSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(
                      "Featured artists:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      featuredArtists,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: boldSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(
                      "Playlist duration:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      widget.playlist.duration,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: boldSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: (){
                              //print("Playing ${widget.controller.indexNotifier.value}");
                              widget.controller.playingSongs.clear();
                              widget.controller.playingSongsUnShuffled.clear();

                              widget.controller.playingSongs.addAll(widget.playlist.songs);
                              widget.controller.playingSongsUnShuffled.addAll(widget.playlist.songs);

                              if(widget.controller.shuffleNotifier.value == true) {
                                widget.controller.playingSongs.shuffle();
                              }

                              var file = File("assets/settings.json");
                              widget.controller.settings.lastPlaying.clear();

                              for(int i = 0; i < widget.controller.playingSongs.length; i++){
                                widget.controller.settings.lastPlaying.add(widget.controller.playingSongs[i].path);
                              }
                              widget.controller.settings.lastPlayingIndex = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[0]);
                              file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                              widget.controller.indexChange(widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[0]));
                              widget.controller.playSong();
                            },
                            icon: Icon(
                              FluentIcons.play_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              print("Add ${widget.playlist.name}");
                              // for(metadata1 song in allPlaylists[displayedPlaylist].songs) {
                              //   _songstoadd.add(song);
                              // }
                              // setState(() {
                              //   addelement = true;
                              // });
                            },
                            icon: Icon(
                              FluentIcons.add_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                        ]
                    ),
                  ]
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.45,
                padding: EdgeInsets.only(
                  left: width * 0.02,
                  top: height * 0.05,
                  bottom: height * 0.05,
                ),
                child: ListView.builder(
                  itemCount: widget.playlist.songs.length,
                  itemBuilder: (context, int index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: height * 0.125,
                      padding: EdgeInsets.only(
                        right: width * 0.01,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              //print(widget.controller.playingSongsUnShuffled[index].title);
                              widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[index]);
                              widget.controller.indexChange(widget.controller.indexNotifier.value);
                              widget.controller.playSong();
                            },
                            child: FutureBuilder(
                                future: widget.controller.imageRetrieve(widget.playlist.songs[index].path, false),
                                builder: (context, snapshot){
                                  return HoverWidget(
                                    hoverChild: Container(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0075,
                                        right: width * 0.0075,
                                        top: height * 0.005,
                                        bottom: height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(height * 0.02),
                                        color: const Color(0xFF242424),
                                      ),
                                      child: Row(
                                        children: [
                                          if(snapshot.hasData)
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.02),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            SizedBox(
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: Center(
                                                child: Text(
                                                  '${snapshot.error} occurred',
                                                  style: TextStyle(fontSize: normalSize),
                                                ),
                                              ),
                                            )
                                          else
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                      )
                                                  ),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.playlist.songs[index].title.toString().length > 60 ? "${widget.playlist.songs[index].title.toString().substring(0, 60)}..." : widget.playlist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.playlist.songs[index].artists.toString().length > 60 ? "${widget.playlist.songs[index].artists.toString().substring(0, 60)}..." : widget.playlist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.playlist.songs[index].duration ~/ 60}:${(widget.playlist.songs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                    onHover: (event){
                                      return;
                                      //print("Hovering");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0075,
                                        right: width * 0.0075,
                                        top: height * 0.005,
                                        bottom: height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(height * 0.01),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          if(snapshot.hasData)
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                  aspectRatio: 1.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(height * 0.02),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Image.memory(snapshot.data!).image,
                                                        )
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            SizedBox(
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: Center(
                                                child: Text(
                                                  '${snapshot.error} occurred',
                                                  style: TextStyle(fontSize: normalSize),
                                                ),
                                              ),
                                            )
                                          else
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(height * 0.02),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.playlist.songs[index].title.toString().length > 60 ? "${widget.playlist.songs[index].title.toString().substring(0, 60)}..." : widget.playlist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.playlist.songs[index].artists.toString().length > 60 ? "${widget.playlist.songs[index].artists.toString().substring(0, 60)}..." : widget.playlist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.playlist.songs[index].duration ~/ 60}:${(widget.playlist.songs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            )
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/domain/album_type.dart';
import 'package:window_manager/window_manager.dart';
import '../controller/controller.dart';
import 'settings.dart';

class AlbumWidget extends StatefulWidget {
  final Controller controller;
  final AlbumType album;
  const AlbumWidget({super.key, required this.controller, required this.album});

  @override
  _AlbumWidget createState() => _AlbumWidget();
}

class _AlbumWidget extends State<AlbumWidget> {
  bool volume = true, search = false;
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  FocusNode searchNode = FocusNode();

  String featuredArtists = "";


  @override
  void initState() {
    for(int i = 0; i < widget.album.featuredartists.length; i++) {
      featuredArtists += widget.album.featuredartists[i].name;
      if(i != widget.album.featuredartists.length - 1) {
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
      appBar: PreferredSize(
        preferredSize: Size(
          double.maxFinite,
          height * 0.04,
        ),
        child: DragToMoveArea(
          child: ValueListenableBuilder(
              valueListenable: widget.controller.colorNotifier2,
              builder: (context, value, child){
                return AppBar(
                  title: Text(
                    'Music Player',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                    ),
                  ),
                  backgroundColor: widget.controller.colorNotifier2.value,
                  leading: IconButton(
                    onPressed: () {
                      print("Back");
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      FluentIcons.arrow_left_16_filled,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    Container(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: _visible,
                          builder: (context, value, child) =>
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        child: ValueListenableBuilder(
                                            valueListenable: widget.controller.volumeNotifier,
                                            builder: (context, value, child){
                                              return SliderTheme(
                                                data: SliderThemeData(
                                                  trackHeight: 2,
                                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                                ),
                                                child: Slider(
                                                  min: 0.0,
                                                  max: 1.0,
                                                  mouseCursor: SystemMouseCursors.click,
                                                  value: value,
                                                  activeColor: widget.controller.colorNotifier.value,
                                                  thumbColor: Colors.white,
                                                  inactiveColor: Colors.white,
                                                  onChanged: (double value) {
                                                    widget.controller.volumeNotifier.value = value;
                                                    widget.controller.setVolume(widget.controller.volumeNotifier.value);
                                                  },
                                                ),
                                              );
                                            }
                                        ),
                                      ),
                                    ),
                                  ),
                                  MouseRegion(
                                    onEnter: (event) {
                                      _visible.value = true;
                                    },
                                    onExit: (event) {
                                      _visible.value = false;
                                    },
                                    child: ValueListenableBuilder(
                                        valueListenable: widget.controller.volumeNotifier,
                                        builder: (context, value, child) {
                                          return IconButton(
                                            icon: volume ? Icon(
                                              FluentIcons.speaker_2_16_filled,
                                              size: height * 0.02,
                                              color: Colors.white,
                                            ) :
                                            Icon(
                                              FluentIcons.speaker_mute_16_filled,
                                              size: height * 0.02,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              if(volume) {
                                                widget.controller.volumeNotifier.value = 0;
                                              }
                                              else {
                                                widget.controller.volumeNotifier.value = 0.1;
                                              }
                                              volume = !volume;
                                              widget.controller.setVolume(widget.controller.volumeNotifier.value);
                                            },
                                          );
                                        }
                                    ),
                                  ),
                                  IconButton(onPressed: (){
                                    print("Search");
                                    setState(() {
                                      search = !search;
                                    });
                                    searchNode.requestFocus();
                                  }, icon: Icon(
                                    FluentIcons.search_16_filled,
                                    size: height * 0.02,
                                    color: Colors.white,
                                  )
                                  ),
                                  IconButton(onPressed: (){
                                    print("Tapped settings");
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                      return Settings(controller: widget.controller,);
                                    }));
                                  }, icon: Icon(
                                    FluentIcons.settings_16_filled,
                                    size: height * 0.02,
                                    color: Colors.white,
                                  )
                                  )//Icon(Icons.more_vert)),
                                ],
                              ),
                        )),
                    Icon(
                      FluentIcons.divider_tall_16_regular,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () => windowManager.minimize(),
                      icon: Icon(
                        FluentIcons.spacebar_20_filled,
                        size: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await windowManager.isMaximized()) {
                          //print("Restoring");
                          await windowManager.unmaximize();
                          //await windowManager.setSize(Size(width * 0.6, height * 0.6));
                        } else {
                          await windowManager.maximize();
                        }

                      },
                      icon: Icon(
                        FluentIcons.maximize_16_regular,
                        size: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => windowManager.close(),
                      icon: Icon(
                        Icons.close_outlined,
                        size: height * 0.02,
                        color: Colors.white,

                      ),
                    ),
                  ],
                );
              }
          ),

        ),
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
                          future: widget.controller.imageRetrieve(widget.album.songs.first.path, false),
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
                      "Album name:",
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
                      widget.album.name,
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
                      "Album duration:",
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
                      widget.album.duration,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: (){
                            //print("Playing ${widget.controller.indexNotifier.value}");
                            widget.controller.audioPlayer?.stop();
                            widget.controller.playingSongs.clear();
                            widget.controller.playingSongsUnShuffled.clear();

                            widget.controller.playingSongs.addAll(widget.album.songs);
                            widget.controller.playingSongsUnShuffled.addAll(widget.album.songs);

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
                          print("Add ${widget.album.name}");
                          // for(metadata1 song in allalbums[displayedalbum].songs) {
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
                  itemCount: widget.album.songs.length,
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
                            widget.controller.audioPlayer?.stop();
                            widget.controller.playingSongs.clear();
                            widget.controller.playingSongsUnShuffled.clear();

                            widget.controller.playingSongs.addAll(widget.album.songs);
                            widget.controller.playingSongsUnShuffled.addAll(widget.album.songs);

                            if(widget.controller.shuffleNotifier.value == true) {
                              widget.controller.playingSongs.shuffle();
                            }

                            var file = File("assets/settings.json");
                            widget.controller.settings.lastPlaying.clear();

                            for(int i = 0; i < widget.controller.playingSongs.length; i++){
                              widget.controller.settings.lastPlaying.add(widget.controller.playingSongs[i].path);
                            }
                            file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));

                            widget.controller.indexChange(widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[index]));
                            widget.controller.playSong();
                          },
                          child: FutureBuilder(
                            future: widget.controller.imageRetrieve(widget.album.songs[index].path, false),
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
                                              child: ClipRRect(
                                                // Clip it cleanly.
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 1, sigmaY: 1
                                                  ),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(height * 0.02),
                                                    ),
                                                    child: Text(
                                                      widget.album.songs[index].trackNumber.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: boldSize,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
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
                                            widget.album.songs[index].title.toString().length > 60 ? "${widget.album.songs[index].title.toString().substring(0, 60)}..." : widget.album.songs[index].title.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: normalSize,
                                            )
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Text(
                                            widget.album.songs[index].artists.toString().length > 60 ? "${widget.album.songs[index].artists.toString().substring(0, 60)}..." : widget.album.songs[index].artists.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: smallSize,
                                            )
                                          ),
                                        ]
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${widget.album.songs[index].duration ~/ 60}:${(widget.album.songs[index].duration % 60).toString().padLeft(2, '0')}",
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
                                              child: ClipRRect(
                                                // Clip it cleanly.
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 1, sigmaY: 1
                                                  ),
                                                  child: Container(
                                                    color: Colors.black.withOpacity(0.3),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      widget.album.songs[index].trackNumber.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: boldSize,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                            ),
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
                                            widget.album.songs[index].title.toString().length > 60 ? "${widget.album.songs[index].title.toString().substring(0, 60)}..." : widget.album.songs[index].title.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: normalSize,
                                            )
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Text(
                                            widget.album.songs[index].artists.toString().length > 60 ? "${widget.album.songs[index].artists.toString().substring(0, 60)}..." : widget.album.songs[index].artists.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: smallSize,
                                            )
                                          ),
                                        ]
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${widget.album.songs[index].duration ~/ 60}:${(widget.album.songs[index].duration % 60).toString().padLeft(2, '0')}",
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
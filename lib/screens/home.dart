import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../types/featured_artist_type.dart';
import '../types/metadata_type.dart';
import '../types/playlist_type.dart';
import '../functions.dart';
import 'albums.dart';
import 'artists.dart';
import 'tracks.dart';
import 'settings.dart';
import 'playlists.dart';
import '../lyric_reader/lyrics_reader.dart';
import '../progress_bar/audio_video_progress_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  functions functions1 = functions();

  bool isTap = false, isTapped = false;
  bool _volume = true, _list = false, _minimized = false;
  bool _down = false;
  bool create = false, search = false, addelement = false;
  bool _queueinatp = false, loading = false, retrieve_loading = true;

  int _hovereditem3 = -1;
  int displayedalbum = -1, currentPage = 3;
  int _hovereditem = -1, _hovereditem2 = -1;

  String  artistsforalbum = "", playlistname = "New playlist";
  String _usermessage = "No message";

  FocusNode myFocusNode = FocusNode();
  FocusNode searchNode = FocusNode();

  ValueNotifier<bool> _visible = ValueNotifier(false);

  ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  metadata_type songtoadd = metadata_type();

  List<playlist> addtoplaylists = [];
  List<metadata_type> _songstoadd = [];


  late Timer timer1;
  late PageController _pageController;
  late ScrollController itemScrollController;

  @override
  void initState(){
    print(functions1.settings1.firsttime);
    if (functions1.settings1.firsttime == false) {
      functions1.songretrieve(false);
    }
    functions1.addListener(() {
      setState(() {});
    });
    functions1.found = functions1.allmetadata;
    functions1.index = functions1.settings1.lastplayingindex;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchNode.addListener(() {
        if(searchNode.hasFocus == false){
          Future.delayed(const Duration(seconds: 2)).then((value) {
            setState(() {
              if(searchNode.hasFocus == false)
                search = false;
            });
          });
        }
      });
      _pageController = PageController(
        initialPage: 4,
      );
      itemScrollController = ScrollController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.1,
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
                                value: functions1.volume,
                                activeColor: functions1.color,
                                thumbColor: Colors.white,
                                inactiveColor: Colors.white,
                                onChanged: (double value) {
                                  setState(() {
                                    functions1.volume = value;
                                    functions1.setVolume(functions1.volume);
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
                              functions1.volume = 0;
                            }
                            else {
                              functions1.volume = 0.1;
                            }
                            _volume = !_volume;
                            setState(() {
                              functions1.setVolume(functions1.volume);
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
                          return Settings();
                        }));
                      }, icon: const Icon(FluentIcons.settings_16_filled))//Icon(Icons.more_vert)),
                    ],
                  ),
                ))
          ],
        ),
      body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: !functions1.finished_retrieving?
              Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ) :
              !_minimized?
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width * 0.075,
                        right: MediaQuery.of(context).size.width * 0.075,
                        top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Song Artwork and Details
                        Row(
                          children: [
                            _list == true ?
                            Container(
                              padding: EdgeInsets.only(left: 50, right: 50, top: 50),
                              height: 450.0,
                              width: 1000,
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: itemScrollController,
                                itemCount: functions1.playingsongs_unshuffled.length,
                                itemBuilder: (context, int index) {
                                  return Container(
                                      padding: EdgeInsets.only(right: 20),
                                      height: 110,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (event){
                                          setState(() {
                                            _hovereditem2 = index;
                                          });
                                        },
                                        onExit: (event){
                                          setState(() {
                                            _hovereditem2 = -1;
                                          });
                                        },
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){
                                            print(functions1.playingsongs_unshuffled[index].title);
                                            functions1.index = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[index]);
                                            var file = File(
                                                "assets/settings.json");
                                            functions1.settings1.lastplayingindex =
                                                functions1.index;
                                            file.writeAsStringSync(
                                                jsonEncode(functions1.settings1
                                                    .toJson()));
                                            functions1.playSong();
                                          },
                                          child:
                                          Container(
                                            color: _hovereditem2 == index ? Color(0xFF242424) : Colors.transparent,
                                            child: Row(
                                              children: [
                                                functions1.allmetadata[functions1.allmetadata.indexOf(functions1.playingsongs_unshuffled[index])].imageloaded?
                                                Container(
                                                  height: 100,
                                                  width: 100,
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(10),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(functions1.allmetadata[functions1.allmetadata.indexOf(functions1.playingsongs_unshuffled[index])].image).image,
                                                      )
                                                  ),
                                                ) : loading == true?
                                                Container(
                                                  height: 100,
                                                  width: 100,
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(10),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(functions1.allmetadata[functions1.allmetadata.indexOf(functions1.playingsongs_unshuffled[index])].image).image,
                                                      )
                                                  ),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ) : FutureBuilder(
                                                  future: functions1.imageretrieve(functions1.playingsongs_unshuffled[index].path),
                                                  builder: (ctx, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return
                                                        Container(
                                                          height: 100,
                                                          width: 100,
                                                          padding: EdgeInsets.only(left: 10),
                                                          decoration: BoxDecoration(
                                                              color: Colors.black,
                                                              borderRadius: BorderRadius.circular(10),
                                                              image: DecorationImage(
                                                                fit: BoxFit.cover,
                                                                image: Image.memory(snapshot.data!).image,
                                                              )
                                                          ),
                                                        );
                                                    }
                                                    else if (snapshot.hasError) {
                                                      return Center(
                                                        child: Text(
                                                          '${snapshot.error} occurred',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      );
                                                    } else{
                                                      return Container(
                                                        height: 100,
                                                        width: 100,
                                                        padding: EdgeInsets.only(left: 10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                            )
                                                        ),
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                Container(
                                                  width: 20,
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        functions1.playingsongs_unshuffled[index].title.toString().length > 60 ? functions1.playingsongs_unshuffled[index].title.toString().substring(0, 60) + "..." : functions1.playingsongs_unshuffled[index].title.toString(),
                                                        style: functions1.playingsongs_unshuffled[index] != functions1.playingsongs[functions1.index] ? TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ) : TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 5,
                                                      ),
                                                      Text(functions1.playingsongs_unshuffled[index].artists.toString().length > 60 ? functions1.playingsongs_unshuffled[index].artists.toString().substring(0, 60) + "..." : functions1.playingsongs_unshuffled[index].artists.toString(),
                                                        style:  functions1.playingsongs_unshuffled[index] != functions1.playingsongs[functions1.index]  ? TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                        ) : TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                                const Spacer(),
                                                Text(
                                                  functions1.playingsongs_unshuffled[index].durationString,
                                                  style:  functions1.playingsongs_unshuffled[index] != functions1.playingsongs[functions1.index]  ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ) : TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                    width: 10
                                                ),
                                                _hovereditem2 == index?
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: (){
                                                          print("add to playlist song ${functions1.playingsongs_unshuffled[index]}");
                                                          // _songstoadd.add(functions1.playingsongs_unshuffled[_index]);
                                                          // if(addelement == false)
                                                          //   setState(() {
                                                          //     addelement = true;
                                                          //   });
                                                        },
                                                        child: Icon(FluentIcons.add_12_filled, color: functions1.playingsongs_unshuffled[index] != functions1.playingsongs[functions1.index] ? Colors.white : Colors.blue, size: 25,)
                                                    ),

                                                    Container(
                                                      height: 10,
                                                    ),

                                                    GestureDetector(
                                                        onTap: (){
                                                          //print("remove from queue song ${functions1.playingsongs_unshuffled[_index].title}");
                                                          setState(() {
                                                            if(functions1.playingsongs_unshuffled.length == 1){

                                                              _usermessage = "You must have at least 1 song in queue";
                                                              Future.delayed(const Duration(seconds: 5)).then((value) {
                                                                setState(() {
                                                                  _usermessage = "No message";
                                                                });
                                                              });


                                                            }else {
                                                              metadata_type playingsong = functions1.playingsongs[functions1.index];
                                                              metadata_type playingsong2 = functions1.playingsongs_unshuffled[index];
                                                              // print(playingsong.title);
                                                              functions1.playingsongs.removeAt(functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[index]));
                                                              functions1.playingsongs_unshuffled.removeAt(index);

                                                              if (playingsong2 == playingsong){

                                                                setState(() {
                                                                  functions1.index = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[0]);
                                                                  functions1.lyricModelReset();
                                                                  functions1.sliderProgress = 0;
                                                                  functions1.playProgress = 0;
                                                                  functions1.currentpostlabel = "00:00";
                                                                });
                                                                if(functions1.playing == true) {
                                                                  functions1.playSong();
                                                                }
                                                                else{
                                                                  functions1.resetAudio();
                                                                }
                                                              }
                                                              else {
                                                                functions1.index = functions1.playingsongs.indexOf(playingsong);
                                                              }
                                                              setState(() {

                                                              });
                                                            }
                                                            var file = File(
                                                                "assets/settings.json");
                                                            functions1.settings1.lastplayingindex =
                                                                functions1.index;
                                                            functions1.settings1.lastplaying.clear();
                                                            for(int i = 0; i < functions1.playingsongs_unshuffled.length; i++){
                                                              functions1.settings1.lastplaying.add(functions1.playingsongs_unshuffled[i].path);
                                                            }
                                                            file.writeAsStringSync(
                                                                jsonEncode(functions1.settings1
                                                                    .toJson()));
                                                          });
                                                        },
                                                        child: Icon(FluentIcons.subtract_12_filled, color: functions1.playingsongs_unshuffled[index] != functions1.playingsongs[functions1.index] ? Colors.white : Colors.blue, size: 25,)
                                                    ),
                                                  ],
                                                ):
                                                Container(width: 25,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                  );
                                },
                              ),
                            ):
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.015,
                                      right: MediaQuery.of(context).size.width * 0.015,
                                      top: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                  width: MediaQuery.of(context).size.width * 0.26,
                                  color: Colors.transparent,
                                  child: functions1.playingsongs[functions1.index].imageloaded || loading ?
                                  AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.all(Radius.circular(
                                              MediaQuery.of(context).size.width * 0.015,
                                            )),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image.memory(functions1.playingsongs[functions1.index].image).image,
                                            )
                                        ),
                                      )

                                  ):
                                  FutureBuilder(
                                    builder: (ctx, snapshot) {
                                      if (snapshot.hasData) {
                                        return
                                          AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.015),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: Image.memory(snapshot.data!).image,
                                                )
                                            ),
                                          ),
                                        );
                                      }
                                      else if (snapshot.hasError) {
                                        return Center(
                                          child: Text(
                                            '${snapshot.error} occurred',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        );
                                      } else{
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                    future: functions1.imageretrieve(functions1.playingsongs[functions1.index].path),
                                  ),

                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.02,
                                      right: MediaQuery.of(context).size.width * 0.02,
                                      top: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                  width: MediaQuery.of(context).size.width * 0.275,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Track:",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Text(
                                        functions1.playingsongs[functions1.index].title.toString().length > 60 ? functions1.playingsongs[functions1.index].title.toString().substring(0, 60) + "..." : functions1.playingsongs[functions1.index].title.toString(),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold
                                          ,
                                        ),
                                      ),
                                      Container(
                                        height: 25,
                                      ),
                                      Text(
                                        "Artists:",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Text(
                                        functions1.playingsongs[functions1.index].artists.toString().length > 60 ? functions1.playingsongs[functions1.index].artists.toString().substring(0, 60) + "..." : functions1.playingsongs[functions1.index].artists.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        height: 25,
                                      ),
                                      Text(
                                        "Album:",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Text(
                                        functions1.playingsongs[functions1.index].album.toString().length > 60 ? functions1.playingsongs[functions1.index].album.toString().substring(0, 60) + "..." : functions1.playingsongs[functions1.index].album.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: (){
                                        setState(() {
                                          _minimized = !_minimized;
                                        });
                                      }, icon: Icon(
                                      FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                                      size: MediaQuery.of(context).size.width * 0.017,
                                    )
                                  ),
                                  LyricsReader(
                                    padding: EdgeInsets.only(
                                        right: MediaQuery.of(context).size.width * 0.02,
                                        left: MediaQuery.of(context).size.width * 0.02,
                                    ),
                                    model: functions1.lyricModel,
                                    position: functions1.sliderProgress,
                                    lyricUi: functions1.lyricUI,
                                    playing: functions1.playing,
                                    size: Size(
                                        MediaQuery.of(context).size.width * 0.3,
                                        MediaQuery.of(context).size.height * 0.4
                                    ),
                                    selectLineBuilder: (progress, confirm) {
                                      return Row(
                                        children: [
                                          Icon(FluentIcons.play_12_filled, color: functions1.color,),
                                          Expanded(
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  confirm.call();
                                                  setState(() {
                                                    functions1.seekAudio(Duration(milliseconds: progress));
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Text(
                                            //progress.toString(),
                                            "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                                            style: TextStyle(color: functions1.color),
                                          )
                                        ],
                                      );
                                    },
                                    emptyBuilder: () => const Center(
                                      child: Text(
                                        "No lyrics",
                                        style: TextStyle(color: Colors.white, fontFamily: 'Bahnscrift', fontSize: 20),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.05
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {
                              setState(() {
                                if(functions1.shuffle == false) {
                                  functions1.shuffle = true;
                                  metadata_type song = functions1.playingsongs[functions1.index];
                                  functions1.playingsongs.shuffle();
                                  setState(() {
                                    functions1.index = functions1.playingsongs.indexOf(song);
                                  });
                                }
                                else{
                                  functions1.shuffle = false;
                                  metadata_type song = functions1.playingsongs[functions1.index];
                                  functions1.playingsongs.clear();
                                  functions1.playingsongs.addAll(functions1.playingsongs_unshuffled);
                                  setState(() {
                                    functions1.index = functions1.playingsongs_unshuffled.indexOf(song);

                                  });
                                }
                              });
                            },
                                icon: functions1.shuffle == false ?
                                  Icon(FluentIcons.arrow_shuffle_off_16_filled, size: MediaQuery.of(context).size.height * 0.024) :
                                  Icon(FluentIcons.arrow_shuffle_16_filled, size: MediaQuery.of(context).size.height * 0.024)),
                            IconButton(onPressed: () {
                              setState(() {
                                if(_list == false) {
                                  _list = true;
                                }
                                else{
                                  _list = false;
                                }
                              });
                              if(_list == true){
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if(itemScrollController.hasClients) {
                                    itemScrollController.animateTo(
                                      functions1.index * 110,
                                      duration: const Duration(milliseconds: 250), curve: Curves.easeInOut,
                                    );
                                  }
                                });
                              }
                            },
                                icon: Icon(FluentIcons.list_20_filled, size: MediaQuery.of(context).size.height * 0.024)),
                            IconButton(onPressed: () {
                              if(functions1.repeat == false) {
                                functions1.repeat = true;
                              } else {
                                functions1.repeat = false;
                              }
                              setState(() {});
                            },
                                icon: functions1.repeat == false ?
                                Icon(FluentIcons.arrow_repeat_all_16_filled, size: MediaQuery.of(context).size.height * 0.024,) :
                                Icon(FluentIcons.arrow_repeat_1_16_filled, size: MediaQuery.of(context).size.height * 0.024)
                            ),

                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Column(
                          children: buildPlayControl(),
                        ),
                      ],
                    ),

                  ),
                  addelement == true ?
                  ClipRect(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 100, top: 25, left: 100, right: 100),
                          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 500,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 20),
                                child: Text("Choose playlist:", style: TextStyle(color: Colors.white, fontSize: 24),),
                              ),
                              Container(
                                height: 10,
                              ),
                              Container(
                                  width: 1000,
                                  height: 620,
                                  child: GridView.builder(
                                    padding: EdgeInsets.only(right: 20),
                                    itemCount: functions1.allplaylists.length + 1,
                                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                        childAspectRatio: 0.8 ,
                                        maxCrossAxisExtent: 250,
                                        crossAxisSpacing: 25,
                                        mainAxisSpacing: 10),
                                    itemBuilder: (BuildContext context, int sindex) {
                                      return sindex == 0 ?
                                      Container(
                                        child : MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onEnter: (event){
                                            setState(() {
                                              _hovereditem = -2;
                                            });
                                          },
                                          onExit: (event){
                                            setState(() {
                                              _hovereditem = -1;
                                            });
                                          },
                                          child: GestureDetector(
                                            onTap: (){
                                              print("tapped on queue");
                                              if(_queueinatp)
                                              {
                                                setState(() {
                                                  _queueinatp = false;
                                                });
                                              }
                                              else
                                              {
                                                setState(() {
                                                  _queueinatp = true;
                                                });
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                    height: 200,
                                                    width: 200,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          height: 250,
                                                          width: 250,
                                                          child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Icon(FluentIcons.text_bullet_list_add_20_filled, size: 100, color: Colors.white,),
                                                          ),
                                                        ),
                                                        ClipRRect(
                                                          // Clip it cleanly.
                                                          child: BackdropFilter(
                                                            filter: _queueinatp || _hovereditem == -2 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                            child: Container(
                                                              color: _queueinatp ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                                              alignment: Alignment.center,
                                                              child: _queueinatp ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    )
                                                ),

                                                Container(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "Current queue",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),

                                        ),
                                      ) :
                                      Container(
                                        child:
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onEnter: (event){
                                            setState(() {
                                              _hovereditem = sindex-1;
                                            });
                                          },
                                          onExit: (event){
                                            setState(() {
                                              _hovereditem = -1;
                                            });
                                          },
                                          child: GestureDetector(
                                            onTap: (){
                                              print("tapped on ${functions1.allplaylists[sindex-1].name}");
                                              if(addtoplaylists.contains(functions1.allplaylists[sindex-1])){
                                                addtoplaylists.remove(functions1.allplaylists[sindex-1]);
                                              }
                                              else{
                                                addtoplaylists.add(functions1.allplaylists[sindex-1]);
                                              }
                                              setState(() {

                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                    height: 200,
                                                    width: 200,
                                                    child: Stack(
                                                      children: [
                                                        functions1.allplaylists[sindex-1].songs.first.imageloaded?
                                                        Container(
                                                            height: 200,
                                                            width: 200,
                                                            child: DecoratedBox(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.black,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                    image: Image.memory(functions1.allplaylists[sindex-1].songs.first.image).image,
                                                                  )
                                                              ),
                                                            )
                                                        ):
                                                        loading?
                                                        Container(
                                                            height: 200,
                                                            width: 200,
                                                            child: DecoratedBox(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.black,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                    image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                                  )
                                                              ),
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            )
                                                        ):
                                                        FutureBuilder(
                                                          builder: (ctx, snapshot) {
                                                            if (snapshot.hasData) {
                                                              return
                                                                Container(
                                                                    height: 200,
                                                                    width: 200,
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.black,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          image: DecorationImage(
                                                                            fit: BoxFit.cover,
                                                                            image: Image.memory(snapshot.data!).image,
                                                                          )
                                                                      ),
                                                                    )
                                                                );
                                                            }
                                                            else if (snapshot.hasError) {
                                                              return Center(
                                                                child: Text(
                                                                  '${snapshot.error} occurred',
                                                                  style: TextStyle(fontSize: 18),
                                                                ),
                                                              );
                                                            } else{
                                                              return
                                                                Container(
                                                                    height: 200,
                                                                    width: 200,
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.black,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          image: DecorationImage(
                                                                            fit: BoxFit.cover,
                                                                            image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                                          )
                                                                      ),
                                                                      child: Center(
                                                                        child: CircularProgressIndicator(
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    )
                                                                );
                                                            }
                                                          },
                                                          future: functions1.imageretrieve(functions1.allplaylists[sindex-1].songs.first.path),
                                                        ),
                                                        ClipRRect(
                                                          // Clip it cleanly.
                                                          child: BackdropFilter(
                                                            filter: addtoplaylists.contains(functions1.allplaylists[sindex-1]) || _hovereditem == sindex-1 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                            child: Container(
                                                              color: addtoplaylists.contains(functions1.allplaylists[sindex-1]) ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                                              alignment: Alignment.center,
                                                              child: addtoplaylists.contains(functions1.allplaylists[sindex-1]) ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    )
                                                ),

                                                Container(
                                                  height: 10,
                                                ),
                                                Text(
                                                  functions1.allplaylists[sindex-1].name.length > 45 ? functions1.allplaylists[sindex-1].name.substring(0, 45) + "..." : functions1.allplaylists[sindex-1].name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),

                                        ),
                                      );

                                    },
                                  )
                              ),
                              Container(
                                height: 2,
                                color: Colors.white,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 150,
                                    padding: EdgeInsets.only(right: 20),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                      ),
                                      onPressed: (){

                                        setState(() {
                                          addtoplaylists.clear();
                                          _queueinatp = false;
                                          addelement = false;
                                          _songstoadd.clear();
                                        });
                                      },
                                      child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 22),),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 50,
                                    width: 70,
                                    padding: EdgeInsets.only(right: 20),
                                    alignment: Alignment.center,
                                    child: MouseRegion(
                                      cursor: addtoplaylists.isEmpty && _queueinatp == false? SystemMouseCursors.basic : SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap:(){
                                          print("looooook to add: ${_songstoadd[0].title}");
                                          if(addtoplaylists.isEmpty && _queueinatp == false){
                                            //_usermessage = "Please select at least 1 playlist";
                                          }
                                          else{
                                            if(_queueinatp){
                                              setState(() {
                                                functions1.playingsongs_unshuffled.addAll(_songstoadd);
                                                functions1.playingsongs.addAll(_songstoadd);
                                              });
                                              var file = File("assets/settings.json");
                                              functions1.settings1.lastplaying.add(_songstoadd[0].path);
                                              file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));
                                            }

                                            for(int i = 0; i < addtoplaylists.length; i++) {
                                              for (int j = 0; j < _songstoadd.length; j++) {
                                                if (functions1.allplaylists[functions1.allplaylists.indexOf(addtoplaylists[i])].paths.contains(_songstoadd[j].path) == false) {
                                                  functions1.allplaylists[functions1.allplaylists.indexOf(
                                                      addtoplaylists[i])].songs.add(
                                                      _songstoadd[j]);
                                                  functions1.allplaylists[functions1.allplaylists.indexOf(
                                                      addtoplaylists[i])].paths.add(
                                                      _songstoadd[j].path);
                                                  int playlistduration = 0;
                                                  for (int k = 0; k <
                                                      functions1.allplaylists[functions1.allplaylists
                                                          .indexOf(addtoplaylists[i])]
                                                          .songs.length; k++) {
                                                    playlistduration +=
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .indexOf(
                                                            addtoplaylists[i])]
                                                            .songs[k].duration;
                                                  }
                                                  int shours = Duration(
                                                      milliseconds: playlistduration)
                                                      .inHours;
                                                  int sminutes = Duration(
                                                      milliseconds: playlistduration)
                                                      .inMinutes;
                                                  int sseconds = Duration(
                                                      milliseconds: playlistduration)
                                                      .inSeconds;
                                                  int rhours = shours;
                                                  int rminutes = sminutes -
                                                      (shours * 60);
                                                  int rseconds = sseconds -
                                                      (sminutes * 60);

                                                  if (rhours == 0) {
                                                    if (rminutes == 0) {
                                                      functions1.allplaylists[functions1.allplaylists
                                                          .indexOf(addtoplaylists[i])]
                                                          .duration =
                                                      "$rseconds seconds";
                                                    }
                                                    else if (rseconds == 0) {
                                                      functions1.allplaylists[functions1.allplaylists
                                                          .indexOf(addtoplaylists[i])]
                                                          .duration =
                                                      "$rminutes minutes";
                                                    }
                                                    else {
                                                      functions1.allplaylists[functions1.allplaylists
                                                          .indexOf(addtoplaylists[i])]
                                                          .duration =
                                                      "$rminutes minutes and $rseconds seconds";
                                                    }
                                                  }
                                                  else {
                                                    if (rhours != 1) {
                                                      if (rminutes == 0) {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hours and $rseconds seconds";
                                                      }
                                                      else if (rseconds == 0) {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hours and $rminutes minutes";
                                                      }
                                                      else {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hours, $rminutes minutes and $rseconds seconds";
                                                      }
                                                    }
                                                    else {
                                                      if (rminutes == 0) {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hour and $rseconds seconds";
                                                      }
                                                      else if (rseconds == 0) {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hour and $rminutes minutes";
                                                      }
                                                      else {
                                                        functions1.allplaylists[functions1.allplaylists
                                                            .length - 1].duration =
                                                        "$rhours hour, $rminutes minutes and $rseconds seconds";
                                                      }
                                                    }
                                                  }

                                                  List<featured_artist_type> playlistfeatured = [
                                                  ];
                                                  for (int k = 0; k <
                                                      functions1.allplaylists[functions1.allplaylists
                                                          .indexOf(addtoplaylists[i])]
                                                          .songs.length; k++) {
                                                    List artists = functions1.allplaylists[functions1.allplaylists
                                                        .indexOf(addtoplaylists[i])]
                                                        .songs[k].artists.split("; ");
                                                    for (int l = 0; l <
                                                        artists.length; l++) {
                                                      bool artistsexists = false;
                                                      for (int m = 0; m <
                                                          playlistfeatured
                                                              .length; m++) {
                                                        if (playlistfeatured[m]
                                                            .name == artists[l]) {
                                                          artistsexists = true;
                                                          playlistfeatured[m]
                                                              .appearances++;
                                                          break;
                                                        }
                                                      }
                                                      if (artistsexists == false) {
                                                        featured_artist_type newartist =featured_artist_type();
                                                        newartist.name = artists[l];
                                                        newartist.appearances = 1;
                                                        playlistfeatured.add(
                                                            newartist);
                                                      }
                                                    }
                                                    functions1.allplaylists[functions1.allplaylists.indexOf(
                                                        addtoplaylists[i])]
                                                        .featuredartists.clear();
                                                    functions1.allplaylists[functions1.allplaylists.indexOf(
                                                        addtoplaylists[i])]
                                                        .featuredartists.addAll(
                                                        playlistfeatured);
                                                  }
                                                }
                                              }


                                              var file = File(
                                                  "assets/playlists.json");
                                              List<dynamic> towrite2 = [];
                                              for (int j = 0; j <
                                                  functions1.allplaylists.length; j++) {
                                                towrite2.add(
                                                    functions1.allplaylists[j].toJson());
                                              }
                                              file.writeAsStringSync(
                                                  jsonEncode(towrite2));

                                            }
                                            _usermessage = "";
                                            print(_queueinatp);
                                            if (_songstoadd.length == 1) {
                                              if (addtoplaylists.length == 1) {
                                                _usermessage =
                                                "Song added to playlist";
                                              }
                                              else {
                                                _usermessage =
                                                "Song added to playlists";
                                              }
                                            }
                                            else {
                                              if (addtoplaylists.length == 1) {
                                                _usermessage =
                                                "Songs added to playlist";
                                              }
                                              else {
                                                _usermessage =
                                                "Songs added to playlists";
                                              }
                                            }

                                            Future.delayed(
                                                Duration(seconds: 5), () {
                                              setState(() {
                                                _usermessage = "No message";
                                              });
                                            });
                                          }
                                          setState(() {
                                            addtoplaylists.clear();
                                            addelement = false;
                                            _songstoadd.clear();
                                            _queueinatp = false;
                                          });
                                        },
                                        child: Text("Add", style: TextStyle(color: addtoplaylists.isEmpty && !_queueinatp ? Colors.grey :Colors.white, fontSize: 22),),
                                      ),
                                    ),

                                  )
                                ],
                              ),

                            ],
                          ),
                        )
                    ),
                  ):
                  search == true ?
                  Container(
                    width: 400,
                    height: 500,
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Colors.black,
                    child:  Column(
                      children: [
                        TextFormField(
                          focusNode: searchNode,
                          onChanged: (value) => functions1.filter(value),
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                              labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white,)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: functions1.found.isNotEmpty ?
                          ListView.builder(
                            itemCount: functions1.found.length+1,
                            itemBuilder: (context, int _index) {
                              return _index < functions1.found.length ?
                              Container(
                                height: 85,
                                padding: EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0E0E0E),
                                  ),
                                  onPressed: () {
                                    search = false;
                                    functions1.playingsongs.clear();
                                    functions1.playingsongs_unshuffled.clear();
                                    functions1.playingsongs.addAll(functions1.found);
                                    functions1.playingsongs_unshuffled.addAll(functions1.found);

                                    if(functions1.shuffle == true)
                                      functions1.playingsongs.shuffle();

                                    var file = File("assets/settings.json");
                                    functions1.settings1.lastplaying.clear();

                                    for(int i = 0; i < functions1.playingsongs.length; i++){
                                      functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                                    }
                                    functions1.settings1.lastplayingindex = _index;
                                    file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                                    functions1.index = _index;
                                    functions1.playSong();
                                  },
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          functions1.found[_index].imageloaded ?
                                          Container(
                                            height: 75,
                                            width: 75,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: Image.memory(functions1.found[_index].image).image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ) :
                                          loading?
                                          Container(
                                            height: 75,
                                            width: 75,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child:
                                              Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                              : FutureBuilder(
                                            future: functions1.imageretrieve(functions1.found[_index].path),
                                            builder: (ctx, snapshot) {
                                              if (snapshot.hasData) {
                                                return
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    padding: EdgeInsets.only(left: 10),
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
                                              else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    '${snapshot.error} occurred',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                );
                                              } else{
                                                return
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        image: DecorationImage(
                                                          image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      child:
                                                      Center(
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                              }
                                            },
                                          ),
                                          ClipRRect(
                                            // Clip it cleanly.
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                              child: Container(
                                                width: 75,
                                                height: 75,
                                                color: Colors.black.withOpacity(0.3),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                      width: 25,
                                                      height: 100,
                                                      child: IconButton(
                                                        padding: EdgeInsets.all(0),
                                                        onPressed: () {
                                                          setState(() {
                                                            _songstoadd.add(functions1.found[_index]);
                                                            addelement = true;
                                                          });
                                                        },
                                                        icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: 30,),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                      height: 100,
                                                      width: 15,
                                                      child: IconButton(
                                                        padding: EdgeInsets.all(0),
                                                        onPressed: () {
                                                          functions1.playingsongs.clear();
                                                          functions1.playingsongs_unshuffled.clear();

                                                          functions1.playingsongs.addAll(functions1.found);
                                                          functions1.playingsongs_unshuffled.addAll(functions1.found);

                                                          if(functions1.shuffle == true)
                                                            functions1.playingsongs.shuffle();

                                                          var file = File("assets/settings.json");
                                                          functions1.settings1.lastplaying.clear();

                                                          for(int i = 0; i < functions1.playingsongs.length; i++){
                                                            functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                                                          }
                                                          functions1.settings1.lastplayingindex = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[_index]);
                                                          file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                                                          functions1.index = functions1.settings1.lastplayingindex;
                                                          functions1.playSong();
                                                        },
                                                        icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 30,),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 15,
                                      ),
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                functions1.found[_index].title.toString().length > 25 ? functions1.found[_index].title.toString().substring(0, 25) + "..." : functions1.found[_index].title.toString(),
                                                style: functions1.found[_index] != functions1.playingsongs[functions1.index] ? TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ) : TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                )
                                            ),
                                            Container(
                                              height: 5,
                                            ),
                                            Text(
                                                functions1.found[_index].artists.toString().length > 30 ? functions1.found[_index].artists.toString().substring(0, 30) + "..." : functions1.found[_index].artists.toString(),
                                                style: functions1.found[_index] != functions1.playingsongs[functions1.index] ? TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ) : TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                )
                                            ),
                                          ]
                                      ),
                                    ],
                                  ),
                                ),

                              ) :
                              Container(
                                height:100,
                              );
                            },
                          )

                              : const Text(
                            'No results found',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ):
                  Container(),
                ],
              ) :
              Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                    child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                      child: Container(
                                          height: 50,
                                          child: ElevatedButton(onPressed: (){
                                            print("Artists");
                                            _pageController.animateToPage(0,
                                                duration: Duration(milliseconds: 500),
                                                curve: Curves.easeIn
                                            );
                                            setState(() {
                                              create = false;
                                              playlistname = "New playlist";
                                              artistsforalbum = "";
                                              if(_scrollController.positions.isNotEmpty) {
                                                _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                              }
                                            });
                                          },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF0E0E0E),
                                              ),
                                              child: Text(
                                                  "Artists",
                                                  style: currentPage != 0 ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ) : TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                              )
                                          )
                                      )
                                  ),
                                  Expanded(
                                      child: Container(
                                          height: 50,
                                          child: ElevatedButton(onPressed: (){
                                            _pageController.animateToPage(1,
                                                duration: Duration(milliseconds: 500),
                                                curve: Curves.easeIn
                                            );
                                            setState(() {
                                              create = false;
                                              playlistname = "New playlist";
                                              artistsforalbum = "";
                                              if(_scrollController.positions.isNotEmpty) {
                                                _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                              }

                                            });
                                          },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF0E0E0E),
                                              ),
                                              child: Text(
                                                  "Albums",
                                                  style: currentPage != 1 ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ) : TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                              )
                                          )
                                      )
                                  ),
                                  Expanded(
                                      child: Container(
                                          height: 50,
                                          child: ElevatedButton(onPressed: (){
                                            print("Playlists");
                                            _pageController.animateToPage(2,
                                                duration: Duration(milliseconds: 500),
                                                curve: Curves.easeIn
                                            );
                                            setState(() {
                                              create = false;
                                              playlistname = "New playlist";
                                              artistsforalbum = "";
                                              if(_scrollController.positions.isNotEmpty) {
                                                _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                              }

                                            });
                                          },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF0E0E0E),
                                              ),
                                              child: Text(
                                                  "Playlists",
                                                  style: currentPage != 2 ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ) : TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                              )
                                          )
                                      )
                                  ),
                                  Expanded(
                                      child: Container(
                                          height: 50,
                                          child: ElevatedButton(onPressed: (){
                                            print("Tracks");
                                            _pageController.animateToPage(3,
                                                duration: Duration(milliseconds: 500),
                                                curve: Curves.easeIn
                                            );
                                            setState(() {
                                              functions1.allmetadata.sort((a, b) => a.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase().compareTo(b.title.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()));
                                              create = false;
                                              playlistname = "New playlist";
                                              artistsforalbum = "";
                                              if(_scrollController.positions.isNotEmpty) {
                                                _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                              }
                                            });
                                          },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF0E0E0E),
                                              ),
                                              child: Text(
                                                  "Tracks",
                                                  style: currentPage != 3 ? TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ) : TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                              )
                                          )
                                      )
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015, right: MediaQuery.of(context).size.width * 0.015),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.75,
                                child: PageView(
                                  onPageChanged: (int index){
                                    setState(() {
                                      currentPage = index;
                                    });
                                  },
                                  controller: _pageController,
                                  scrollDirection: Axis.horizontal,
                                  scrollBehavior: ScrollConfiguration.of(context).copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                    },
                                  ),
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    Artists(functions1: functions1),
                                    Albums(functions1: functions1),
                                    Playlists(functions1: functions1),
                                    Tracks(functions1: functions1),
                                  ],

                                ),
                              ),
                            ],),
                          Container(
                            height: _down == false ? 225 : 150,
                            child: Column(
                              children: [
                                _usermessage != "No message" ?
                                Container(
                                  height: 40,
                                  width: _usermessage.length * 20.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),

                                  ),
                                  child: Text(
                                    _usermessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ) : Container(
                                  height: 40,
                                ),
                                Container(
                                  height: 20,
                                ),
                                Container(
                                  height: _down == false ? 150 : 45,
                                  padding: EdgeInsets.only(left: 5),
                                  color: Color(0xFF0E0E0E),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _down == false ? Container(
                                        height: 140,
                                        width: 140,
                                        child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.black,
                                              image: DecorationImage(
                                                image: Image.memory(functions1.playingsongs[functions1.index].image).image,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                        ),
                                      ) :
                                      Container(
                                        width: 140,
                                      ),
                                      _down == false ? Container(
                                        padding: EdgeInsets.only(left: 40),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 410,
                                              child: Text(
                                                functions1.playingsongs[functions1.index].title.length > 45 ? functions1.playingsongs[functions1.index].title.substring(0, 45) + "..." : functions1.playingsongs[functions1.index].title,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Container(
                                              width: 410,
                                              child: Text(
                                                functions1.playingsongs[functions1.index].artists.length > 75 ? functions1.playingsongs[functions1.index].artists.substring(0, 75) + "..." : functions1.playingsongs[functions1.index].artists,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ) :
                                      Container(
                                          width: 410
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: 1025,
                                            height: 45,
                                            child:
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(onPressed: (){
                                                    setState(() {
                                                      _down = !_down;
                                                    });
                                                  }, icon: _down == false ? Icon(FluentIcons.chevron_down_16_filled) : Icon(FluentIcons.chevron_up_16_filled)),
                                                  Container(
                                                    width: 10,
                                                  ),
                                                  IconButton(onPressed: (){
                                                    setState(() {
                                                      _minimized = !_minimized;
                                                    });
                                                  }, icon: Icon(FluentIcons.arrow_maximize_16_filled)),

                                                ]
                                            ),
                                          ),
                                          Container(
                                            height: _down == false ? 15 : 0,
                                          ),
                                          _down == false ? Container(
                                            padding: EdgeInsets.only(left: 25),
                                            child:
                                            Row(
                                              children: [
                                                Container(
                                                  width: 750,
                                                  child: buildPlayControl()[0],
                                                ),
                                                Container(
                                                  width: 25,
                                                ),
                                                buildPlayControl()[2],
                                                Container(
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                          ) : Container(),
                                        ],
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          addelement == true ?
                          ClipRect(
                            child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 100, top: 25, left: 100, right: 100),
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 500,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text("Choose playlist:", style: TextStyle(color: Colors.white, fontSize: 24),),
                                      ),
                                      Container(
                                        height: 10,
                                      ),
                                      Container(
                                          width: 1000,
                                          height: 620,
                                          child: GridView.builder(
                                            padding: EdgeInsets.only(right: 20),
                                            itemCount: functions1.allplaylists.length + 1,
                                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                                childAspectRatio: 0.8 ,
                                                maxCrossAxisExtent: 250,
                                                crossAxisSpacing: 25,
                                                mainAxisSpacing: 10),
                                            itemBuilder: (BuildContext context, int sindex) {
                                              return sindex == 0 ?
                                              Container(
                                                child : MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  onEnter: (event){
                                                    setState(() {
                                                      _hovereditem3 = -2;
                                                    });
                                                  },
                                                  onExit: _incrementExit3,
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      print("tapped on queue");
                                                      if(_queueinatp)
                                                      {
                                                        setState(() {
                                                          _queueinatp = false;
                                                        });
                                                      }
                                                      else
                                                      {
                                                        setState(() {
                                                          _queueinatp = true;
                                                        });
                                                      }
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            height: 200,
                                                            width: 200,
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  height: 250,
                                                                  width: 250,
                                                                  child: DecoratedBox(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    child: Icon(FluentIcons.text_bullet_list_add_20_filled, size: 100, color: Colors.white,),
                                                                  ),
                                                                ),
                                                                ClipRRect(
                                                                  // Clip it cleanly.
                                                                  child: BackdropFilter(
                                                                    filter: _queueinatp || _hovereditem3 == -2 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                                    child: Container(
                                                                      color: _queueinatp ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                                                      alignment: Alignment.center,
                                                                      child: _queueinatp ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            )
                                                        ),

                                                        Container(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          "Current queue",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ),
                                              ) :
                                              Container(
                                                child:
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  onEnter: (event){
                                                    setState(() {
                                                      _hovereditem3 = sindex-1;
                                                    });
                                                  },
                                                  onExit: _incrementExit3,
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      print("tapped on ${functions1.allplaylists[sindex-1].name}");
                                                      if(addtoplaylists.contains(functions1.allplaylists[sindex-1])){
                                                        addtoplaylists.remove(functions1.allplaylists[sindex-1]);
                                                      }
                                                      else{
                                                        addtoplaylists.add(functions1.allplaylists[sindex-1]);
                                                      }
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            height: 200,
                                                            width: 200,
                                                            child: Stack(
                                                              children: [
                                                                functions1.allplaylists[sindex-1].songs.first.imageloaded?
                                                                Container(
                                                                    height: 200,
                                                                    width: 200,
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.black,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          image: DecorationImage(
                                                                            fit: BoxFit.cover,
                                                                            image: Image.memory(functions1.allplaylists[sindex-1].songs.first.image).image,
                                                                          )
                                                                      ),
                                                                    )
                                                                ):
                                                                loading?
                                                                Container(
                                                                    height: 200,
                                                                    width: 200,
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.black,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          image: DecorationImage(
                                                                            fit: BoxFit.cover,
                                                                            image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                                          )
                                                                      ),
                                                                      child: Center(
                                                                        child: CircularProgressIndicator(
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    )
                                                                ):
                                                                FutureBuilder(
                                                                  builder: (ctx, snapshot) {
                                                                    if (snapshot.hasData) {
                                                                      return
                                                                        Container(
                                                                            height: 200,
                                                                            width: 200,
                                                                            child: DecoratedBox(
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.black,
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                  image: DecorationImage(
                                                                                    fit: BoxFit.cover,
                                                                                    image: Image.memory(snapshot.data!).image,
                                                                                  )
                                                                              ),
                                                                            )
                                                                        );
                                                                    }
                                                                    else if (snapshot.hasError) {
                                                                      return Center(
                                                                        child: Text(
                                                                          '${snapshot.error} occurred',
                                                                          style: TextStyle(fontSize: 18),
                                                                        ),
                                                                      );
                                                                    } else{
                                                                      return
                                                                        Container(
                                                                            height: 200,
                                                                            width: 200,
                                                                            child: DecoratedBox(
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.black,
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                  image: DecorationImage(
                                                                                    fit: BoxFit.cover,
                                                                                    image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                                                  )
                                                                              ),
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            )
                                                                        );
                                                                    }
                                                                  },
                                                                  future: functions1.imageretrieve(functions1.allplaylists[sindex-1].songs.first.path),
                                                                ),
                                                                ClipRRect(
                                                                  // Clip it cleanly.
                                                                  child: BackdropFilter(
                                                                    filter: addtoplaylists.contains(functions1.allplaylists[sindex-1]) || _hovereditem3 == sindex-1 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                                    child: Container(
                                                                      color: addtoplaylists.contains(functions1.allplaylists[sindex-1]) ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                                                      alignment: Alignment.center,
                                                                      child: addtoplaylists.contains(functions1.allplaylists[sindex-1]) ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            )
                                                        ),

                                                        Container(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          functions1.allplaylists[sindex-1].name.length > 45 ? functions1.allplaylists[sindex-1].name.substring(0, 45) + "..." : functions1.allplaylists[sindex-1].name,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ),
                                              );

                                            },
                                          )
                                      ),
                                      Container(
                                        height: 2,
                                        color: Colors.white,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 150,
                                            padding: EdgeInsets.only(right: 20),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                              ),
                                              onPressed: (){

                                                setState(() {
                                                  addtoplaylists.clear();
                                                  _queueinatp = false;
                                                  addelement = false;
                                                  _songstoadd.clear();
                                                });
                                              },
                                              child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 22),),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 50,
                                            width: 70,
                                            padding: EdgeInsets.only(right: 20),
                                            alignment: Alignment.center,
                                            child: MouseRegion(
                                              cursor: addtoplaylists.isEmpty && _queueinatp == false? SystemMouseCursors.basic : SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap:(){
                                                  print("looooook to add: ${_songstoadd[0].title}");
                                                  if(addtoplaylists.isEmpty && _queueinatp == false){
                                                    //_usermessage = "Please select at least 1 playlist";
                                                  }
                                                  else{
                                                    if(_queueinatp){
                                                      setState(() {
                                                        functions1.playingsongs_unshuffled.addAll(_songstoadd);
                                                        functions1.playingsongs.addAll(_songstoadd);
                                                      });
                                                      var file = File("assets/settings.json");
                                                      functions1.settings1.lastplaying.add(_songstoadd[0].path);
                                                      file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));
                                                    }

                                                    for(int i = 0; i < addtoplaylists.length; i++) {
                                                      for (int j = 0; j < _songstoadd.length; j++) {
                                                        if (functions1.allplaylists[functions1.allplaylists.indexOf(addtoplaylists[i])].paths.contains(_songstoadd[j].path) == false) {
                                                          functions1.allplaylists[functions1.allplaylists.indexOf(
                                                              addtoplaylists[i])].songs.add(
                                                              _songstoadd[j]);
                                                          functions1.allplaylists[functions1.allplaylists.indexOf(
                                                              addtoplaylists[i])].paths.add(
                                                              _songstoadd[j].path);
                                                          int playlistduration = 0;
                                                          for (int k = 0; k <
                                                              functions1.allplaylists[functions1.allplaylists
                                                                  .indexOf(addtoplaylists[i])]
                                                                  .songs.length; k++) {
                                                            playlistduration +=
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .indexOf(
                                                                    addtoplaylists[i])]
                                                                    .songs[k].duration;
                                                          }
                                                          int shours = Duration(
                                                              milliseconds: playlistduration)
                                                              .inHours;
                                                          int sminutes = Duration(
                                                              milliseconds: playlistduration)
                                                              .inMinutes;
                                                          int sseconds = Duration(
                                                              milliseconds: playlistduration)
                                                              .inSeconds;
                                                          int rhours = shours;
                                                          int rminutes = sminutes -
                                                              (shours * 60);
                                                          int rseconds = sseconds -
                                                              (sminutes * 60);

                                                          if (rhours == 0) {
                                                            if (rminutes == 0) {
                                                              functions1.allplaylists[functions1.allplaylists
                                                                  .indexOf(addtoplaylists[i])]
                                                                  .duration =
                                                              "$rseconds seconds";
                                                            }
                                                            else if (rseconds == 0) {
                                                              functions1.allplaylists[functions1.allplaylists
                                                                  .indexOf(addtoplaylists[i])]
                                                                  .duration =
                                                              "$rminutes minutes";
                                                            }
                                                            else {
                                                              functions1.allplaylists[functions1.allplaylists
                                                                  .indexOf(addtoplaylists[i])]
                                                                  .duration =
                                                              "$rminutes minutes and $rseconds seconds";
                                                            }
                                                          }
                                                          else {
                                                            if (rhours != 1) {
                                                              if (rminutes == 0) {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hours and $rseconds seconds";
                                                              }
                                                              else if (rseconds == 0) {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hours and $rminutes minutes";
                                                              }
                                                              else {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hours, $rminutes minutes and $rseconds seconds";
                                                              }
                                                            }
                                                            else {
                                                              if (rminutes == 0) {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hour and $rseconds seconds";
                                                              }
                                                              else if (rseconds == 0) {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hour and $rminutes minutes";
                                                              }
                                                              else {
                                                                functions1.allplaylists[functions1.allplaylists
                                                                    .length - 1].duration =
                                                                "$rhours hour, $rminutes minutes and $rseconds seconds";
                                                              }
                                                            }
                                                          }

                                                          List<
                                                              featured_artist_type> playlistfeatured = [
                                                          ];
                                                          for (int k = 0; k <
                                                              functions1.allplaylists[functions1.allplaylists
                                                                  .indexOf(addtoplaylists[i])]
                                                                  .songs.length; k++) {
                                                            List artists = functions1.allplaylists[functions1.allplaylists
                                                                .indexOf(addtoplaylists[i])]
                                                                .songs[k].artists.split("; ");
                                                            for (int l = 0; l <
                                                                artists.length; l++) {
                                                              bool artistsexists = false;
                                                              for (int m = 0; m <
                                                                  playlistfeatured
                                                                      .length; m++) {
                                                                if (playlistfeatured[m]
                                                                    .name == artists[l]) {
                                                                  artistsexists = true;
                                                                  playlistfeatured[m]
                                                                      .appearances++;
                                                                  break;
                                                                }
                                                              }
                                                              if (artistsexists == false) {
                                                                featured_artist_type newartist =featured_artist_type();
                                                                newartist.name = artists[l];
                                                                newartist.appearances = 1;
                                                                playlistfeatured.add(
                                                                    newartist);
                                                              }
                                                            }
                                                            functions1.allplaylists[functions1.allplaylists.indexOf(
                                                                addtoplaylists[i])]
                                                                .featuredartists.clear();
                                                            functions1.allplaylists[functions1.allplaylists.indexOf(
                                                                addtoplaylists[i])]
                                                                .featuredartists.addAll(
                                                                playlistfeatured);
                                                          }
                                                        }
                                                      }


                                                      var file = File(
                                                          "assets/playlists.json");
                                                      List<dynamic> towrite2 = [];
                                                      for (int j = 0; j <
                                                          functions1.allplaylists.length; j++) {
                                                        towrite2.add(
                                                            functions1.allplaylists[j].toJson());
                                                      }
                                                      file.writeAsStringSync(
                                                          jsonEncode(towrite2));

                                                    }
                                                    _usermessage = "";
                                                    print(_queueinatp);
                                                    if (_songstoadd.length == 1) {
                                                      if (addtoplaylists.length == 1) {
                                                        _usermessage =
                                                        "Song added to playlist";
                                                      }
                                                      else {
                                                        _usermessage =
                                                        "Song added to playlists";
                                                      }
                                                    }
                                                    else {
                                                      if (addtoplaylists.length == 1) {
                                                        _usermessage =
                                                        "Songs added to playlist";
                                                      }
                                                      else {
                                                        _usermessage =
                                                        "Songs added to playlists";
                                                      }
                                                    }

                                                    Future.delayed(
                                                        Duration(seconds: 5), () {
                                                      setState(() {
                                                        _usermessage = "No message";
                                                      });
                                                    });
                                                  }
                                                  setState(() {
                                                    addtoplaylists.clear();
                                                    addelement = false;
                                                    _songstoadd.clear();
                                                    _queueinatp = false;
                                                  });
                                                },
                                                child: Text("Add", style: TextStyle(color: addtoplaylists.isEmpty && !_queueinatp ? Colors.grey :Colors.white, fontSize: 22),),
                                              ),
                                            ),

                                          )
                                        ],
                                      ),

                                    ],
                                  ),
                                )
                            ),
                          )
                              :
                          Container(),
                        ]
                    )
                ),
                Visibility(
                  visible: search,
                  child: Container(
                    width: 400,
                    height: 500,
                    color: Colors.black,
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child:  Column(
                      children: [
                        TextFormField(
                          focusNode: searchNode,
                          onChanged: (value) => functions1.filter(value),
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                              labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white,)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: functions1.found.isNotEmpty ?
                          ListView.builder(
                            itemCount: functions1.found.length+1,
                            itemBuilder: (context, int _index) {
                              return _index < functions1.found.length ?
                              Container(
                                height: 85,
                                padding: EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0E0E0E),
                                  ),
                                  onPressed: () {
                                    functions1.playingsongs.clear();
                                    functions1.playingsongs_unshuffled.clear();

                                    functions1.playingsongs.addAll(functions1.found);
                                    functions1.playingsongs_unshuffled.addAll(functions1.found);

                                    if(functions1.shuffle == true)
                                      functions1.playingsongs.shuffle();

                                    var file = File("assets/settings.json");
                                    functions1.settings1.lastplaying.clear();

                                    for(int i = 0; i < functions1.playingsongs.length; i++){
                                      functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                                    }
                                    functions1.settings1.lastplayingindex = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[_index]);
                                    file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                                    functions1.index = functions1.settings1.lastplayingindex;
                                    functions1.playSong();
                                  },
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          functions1.found[_index].imageloaded ?
                                          Container(
                                            height: 75,
                                            width: 75,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: Image.memory(functions1.found[_index].image).image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ) :
                                          loading?
                                          Container(
                                            height: 75,
                                            width: 75,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child:
                                              Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                              : FutureBuilder(
                                            future: functions1.imageretrieve(functions1.found[_index].path),
                                            builder: (ctx, snapshot) {
                                              if (snapshot.hasData) {
                                                return
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    padding: EdgeInsets.only(left: 10),
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
                                              else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    '${snapshot.error} occurred',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                );
                                              } else{
                                                return
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        image: DecorationImage(
                                                          image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      child:
                                                      Center(
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                              }
                                            },
                                          ),
                                          ClipRRect(
                                            // Clip it cleanly.
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                              child: Container(
                                                width: 75,
                                                height: 75,
                                                color: Colors.black.withOpacity(0.3),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                      width: 25,
                                                      height: 100,
                                                      child: IconButton(
                                                        padding: EdgeInsets.all(0),
                                                        onPressed: () {
                                                          setState(() {
                                                            if(_songstoadd.contains(functions1.found[_index])){
                                                              _songstoadd.remove(functions1.found[_index]);
                                                            }
                                                            else{
                                                              _songstoadd.add(functions1.found[_index]);
                                                            }
                                                            addelement = true;
                                                          });
                                                        },
                                                        icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: 30,),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                      height: 100,
                                                      width: 15,
                                                      child: IconButton(
                                                        padding: EdgeInsets.all(0),
                                                        onPressed: () {
                                                          functions1.playingsongs.clear();
                                                          functions1.playingsongs_unshuffled.clear();

                                                          functions1.playingsongs.addAll(functions1.found);
                                                          functions1.playingsongs_unshuffled.addAll(functions1.found);

                                                          if(functions1.shuffle == true)
                                                            functions1.playingsongs.shuffle();

                                                          var file = File("assets/settings.json");
                                                          functions1.settings1.lastplaying.clear();

                                                          for(int i = 0; i < functions1.playingsongs.length; i++){
                                                            functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                                                          }
                                                          functions1.settings1.lastplayingindex = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[_index]);
                                                          file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                                                          functions1.index = functions1.settings1.lastplayingindex;
                                                          functions1.playSong();
                                                        },
                                                        icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 30,),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Container(
                                        width: 15,
                                      ),
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                functions1.found[_index].title.toString().length > 25 ? functions1.found[_index].title.toString().substring(0, 25) + "..." : functions1.found[_index].title.toString(),
                                                style: functions1.found[_index] != functions1.playingsongs[functions1.index] ? TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ) : TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                )
                                            ),
                                            Container(
                                              height: 5,
                                            ),
                                            Text(
                                                functions1.found[_index].artists.toString().length > 30 ? functions1.found[_index].artists.toString().substring(0, 30) + "..." : functions1.found[_index].artists.toString(),
                                                style: functions1.found[_index] != functions1.playingsongs[functions1.index] ? TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ) : TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                )
                                            ),
                                          ]
                                      ),
                                    ],
                                  ),
                                ),

                              ) :
                              Container(
                                height:100,
                              );
                            },
                          )

                              : const Text(
                            'No results found',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }

  void _incrementExit3(PointerEvent details) {
    setState(() {
      _hovereditem3 = -1;
    });
  }

  List<Widget> buildPlayControl() {
    //print("duration: ${functions1.playingsongs[functions1.index].duration}");
    return [
      ProgressBar(
        progress: Duration(seconds: functions1.sliderProgress),
        total: Duration(seconds: functions1.playingsongs[functions1.index].duration),
        progressBarColor: functions1.color,
        baseBarColor: Colors.white.withOpacity(0.24),
        bufferedBarColor: Colors.white.withOpacity(0.24),
        thumbColor: Colors.white,
        barHeight: 4.0,
        thumbRadius: 7.0,
        timeLabelLocation: _minimized == true ? TimeLabelLocation.sides : TimeLabelLocation.below,
        timeLabelTextStyle: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.02,
          fontFamily: 'Bahnschrift',
          fontWeight: FontWeight.normal,
        ),
        timeLabelPadding: 10,
        onSeek: (duration) {
          functions1.seekAudio(duration);
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () async{
            print("previous");
            if(functions1.sliderProgress > 5000){
              functions1.seekAudio(const Duration(milliseconds: 0));
            }
            else {
              if (functions1.index == 0) {
                functions1.index = functions1.playingsongs.length - 1;
              } else {
                functions1.index--;
              }
              functions1.playSong();
            }
          },
              icon: Icon(
                FluentIcons.previous_16_filled,
                color: Colors.white,
                size: MediaQuery.of(context).size.height * 0.022,
              ),
          ),
          Container(
            width: _minimized == false ? 100 : 20,
          ),
          IconButton(
            onPressed: () async {
              print("pressed");
              if(functions1.playing) {
                functions1.audioPlayer?.pause();
                functions1.playing = false;
              }
              else {
                if (functions1.audioPlayer != null){
                  functions1.audioPlayer?.resume();
                  functions1.playing = true;
                }
                else{
                  functions1.playSong();
                }
              }
            },
            icon: functions1.playing ?
            Icon(FluentIcons.pause_16_filled, color: Colors.white, size: MediaQuery.of(context).size.height * 0.023,) :
            Icon(FluentIcons.play_16_filled, color: Colors.white, size: MediaQuery.of(context).size.height * 0.023,),
          ),
          Container(
            width: _minimized == false ? 100 : 20,
          ),
          IconButton(onPressed: () async {
            print("next");

            if(functions1.index == functions1.playingsongs.length - 1) {
              functions1.index = 0;
            } else {
              functions1.index++;
            }
            functions1.playSong();
          },
            icon: Icon(FluentIcons.next_16_filled, color: Colors.white, size: MediaQuery.of(context).size.height * 0.022, ),
          ),

        ],
      ),
      Container(
        height: 10,
      ),
      _usermessage != "No message" ?
      Container(
        height: 40,
        width: _usermessage.length * 20.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),

        ),
        child: Text(
          _usermessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ) : Container(
        height: 40,
      ),

    ];
  }


}



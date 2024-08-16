import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audiotags/audiotags.dart';
import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import 'package:musicplayer/utils/hover_widget/stack_hover_widget.dart';
import '../controller/controller.dart';
import '../utils/objectbox.g.dart';
import 'add_screen.dart';
import 'image_widget.dart';

class SearchWidget extends StatefulWidget {
  final Controller controller;
  final bool download;
  const SearchWidget({super.key, required this.controller, required this.download});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  FocusNode searchNode = FocusNode();
  String searchValue = '';

  @override
  void initState() {
    super.initState();
    widget.controller.found.value = widget.controller.songBox.query().order(MetadataType_.title).build().find();
    searchNode.requestFocus();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(
        left: width * 0.7,
        bottom: height * 0.2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.01),
        color: const Color(0xFF0E0E0E),
      ),
      child: Column(
        children: [
          TextFormField(
            initialValue: searchValue,
            focusNode: searchNode,
            onChanged: (value) async{
              if(widget.download){
                setState(() {
                  searchValue = value;
                });
              }
              else{
                await widget.controller.filter(value, true);
              }
            },
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
              fontSize: normalSize,
            ),
            decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: smallSize,
                ),
                labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white, size: height * 0.02,)),
          ),
          SizedBox(
            height: height * 0.02,
          ),
          Expanded(
            child: widget.download?
              FutureBuilder(
                future: widget.controller.searchDeezer(searchValue),
                builder: (context, snapshot){
                  if (snapshot.hasData){
                    List<dynamic> songs = snapshot.data;
                    if(songs.isNotEmpty) {
                      print(songs.first);
                    }
                    return songs.isNotEmpty?
                    ListView.builder(
                      itemCount: songs.length,
                      padding: EdgeInsets.only(
                        right: width * 0.01,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var song = songs[index];
                        ValueNotifier<double> progress = ValueNotifier<double>(0.0);
                        return SizedBox(
                          height: height * 0.1,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                print("Downloading ${song['id']}");
                                final stream = await widget.controller.instance.getSong(song['id'].toString(),
                                onProgress: (received, total) {
                                  //print("received: $received, total: $total");
                                  progress.value = received/total;
                                },
                                );
                                File file = File("${widget.controller.settings.directory}/${song['artist']['name'].toString()} - ${song['title'].toString()}.mp3");
                                if (stream != null) {
                                  await file.writeAsBytes(stream.data);
                                  widget.controller.showNotification("Song downloaded successfully.", 3500);
                                } else {
                                  widget.controller.showNotification("Something went wrong.", 3500);
                                }
                                http.Response response = await http.get(
                                  Uri.parse(song['album']['cover_big']),
                                );

                                await AudioTags.write(file.path,
                                  Tag(
                                      title: song['title'].toString(),
                                      trackArtist: song['artist']['name'],
                                      album: song['album']['title'],
                                      albumArtist: song['artist']['name'],
                                      duration: song['duration'],
                                      pictures: [
                                        Picture(
                                            bytes: Uint8List.fromList(response.bodyBytes),
                                            mimeType: null,
                                            pictureType: PictureType.other
                                        )
                                      ]
                                  ),
                                );
                                var songRetrieved = await widget.controller.retrieveSong(file.path, []);
                                widget.controller.songBox.put(songRetrieved);
                                widget.controller.retrievingChangedNotifier.value = !widget.controller.retrievingChangedNotifier.value;
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: HoverContainer(
                                  normalColor: const Color(0xFF0E0E0E),
                                  hoverColor: const Color(0xFF2E2E2E),
                                  padding: EdgeInsets.all(width * 0.005),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(width * 0.01),
                                        child: ImageWidget(
                                          controller: widget.controller,
                                          url: song['album']['cover_medium'],
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.005,
                                      ),
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                song['title'].toString().length > 30 ? "${song['title'].toString().substring(0, 30)}..." : song['title'].toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: normalSize,
                                                )
                                            ),
                                            SizedBox(
                                              height: height * 0.001,
                                            ),
                                            Text(song['artist']['name'].toString().length > 30 ? "${song['artist']['name'].toString().substring(0, 30)}..." : song['artist']['name'].toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: smallSize,
                                                )
                                            ),
                                          ]
                                      ),
                                      const Spacer(),
                                      ValueListenableBuilder(
                                        valueListenable: progress,
                                        builder: (context, value, child){
                                          return value == 0.0 ?
                                          Icon(
                                            FluentIcons.arrow_download_16_filled
                                          ) :
                                          value == 1.0 ?
                                          Icon(
                                            FluentIcons.checkmark_12_filled,
                                          ) :
                                          CircularProgressIndicator(
                                            value: value,
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ) :
                    Text(
                      'No results found',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize
                      ),
                    );

                  }
                  else if(snapshot.hasError){
                    return Center(
                      child: Text(
                        "Error occured. Try again later.",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: normalSize,
                        ),
                      ),
                    );
                  }
                  else{
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                }
              ) :
              ValueListenableBuilder(
                valueListenable: widget.controller.found,
                builder: (context, value, child) {
                  return widget.controller.found.value.isNotEmpty ?
                  ListView.builder(
                    padding: EdgeInsets.only(
                      right: width * 0.01,
                    ),
                    itemCount: widget.controller.found.value.length,
                    itemBuilder: (context, int index) {
                      return SizedBox(
                        height: height * 0.1,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              var songPaths = widget.controller.found.value.map((e) => e.path).toList();
                              if(widget.controller.settings.playingSongs.equals(songPaths) == false){
                                widget.controller.updatePlaying(songPaths, index);
                              }
                              widget.controller.indexChange(widget.controller.settings.playingSongsUnShuffled[index]);
                              await widget.controller.playSong();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(width * 0.01),
                              child: HoverContainer(
                                normalColor: const Color(0xFF0E0E0E),
                                hoverColor: const Color(0xFF2E2E2E),
                                padding: EdgeInsets.all(width * 0.005),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(width * 0.01),
                                        child: FutureBuilder(
                                            future: widget.controller.imageRetrieve(widget.controller.found.value[index].path, false),
                                            builder: (context, snapshot) {
                                              return AspectRatio(
                                                aspectRatio: 1.0,
                                                child: snapshot.hasData?
                                                StackHoverWidget(
                                                  topWidget: ClipRRect(
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                      child: Container(
                                                        color: Colors.black.withOpacity(0.3),
                                                        alignment: Alignment.center,
                                                        child:  IconButton(
                                                          icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: height * 0.03,),
                                                          onPressed: () {
                                                            print("Add");
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => AddScreen(controller: widget.controller, songs: [widget.controller.found.value[index]])
                                                                )
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  bottomWidget: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Image.memory(snapshot.data!).image,
                                                        )
                                                    ),
                                                  ),
                                                )
                                                    :
                                                snapshot.hasError?
                                                Center(
                                                  child: Text(
                                                    '${snapshot.error} occurred',
                                                    style: const TextStyle(fontSize: 18),
                                                  ),
                                                ) :
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.asset("assets/bg.png").image,
                                                      )
                                                  ),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                        )
                                    ),
                                    SizedBox(
                                      width: width * 0.005,
                                    ),
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              widget.controller.found.value[index].title.toString().length > 30 ? "${widget.controller.found.value[index].title.toString().substring(0, 30)}..." : widget.controller.found.value[index].title.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              )
                                          ),
                                          SizedBox(
                                            height: height * 0.001,
                                          ),
                                          Text(widget.controller.found.value[index].artists.toString().length > 30 ? "${widget.controller.found.value[index].artists.toString().substring(0, 30)}..." : widget.controller.found.value[index].artists.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: smallSize,
                                              )
                                          ),
                                        ]
                                    ),
                                    const Spacer(),
                                    Text(
                                        "${widget.controller.found.value[index].duration ~/ 60}:${(widget.controller.found.value[index].duration % 60).toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: normalSize,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ) :
                  Text(
                    'No results found',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}

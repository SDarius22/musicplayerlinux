import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import 'package:musicplayer/utils/hover_widget/stack_hover_widget.dart';
import '../controller/controller.dart';
import '../utils/objectbox.g.dart';
import 'add_screen.dart';

class SearchWidget extends StatefulWidget {
  final Controller controller;
  const SearchWidget({super.key, required this.controller});

  @override
  _SearchWidget createState() => _SearchWidget();
}

class _SearchWidget extends State<SearchWidget> {
  FocusNode searchNode = FocusNode();

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
            focusNode: searchNode,
            onChanged: (value) async => await widget.controller.filter(value, true),
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
            child: ValueListenableBuilder(
                valueListenable: widget.controller.found,
                builder: (context, value, child) {
                  return widget.controller.found.value.isNotEmpty ?
                  ListView.builder(
                    padding: EdgeInsets.only(
                      right: width * 0.01,
                    ),
                    itemCount: widget.controller.found.value.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        height: height * 0.1,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              if(widget.controller.settings.playingSongs.equals(widget.controller.found.value) == false){
                                widget.controller.updatePlaying(widget.controller.found.value);
                              }
                              await widget.controller.indexChange(widget.controller.settings.playingSongsUnShuffled[index]);
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
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (context, animation1, animation2) => AddScreen(controller: widget.controller, songs: [widget.controller.found.value[index]]),
                                                                    transitionDuration: const Duration(milliseconds: 500),
                                                                    reverseTransitionDuration: const Duration(milliseconds: 500),
                                                                    transitionsBuilder: (context, animation1, animation2, child) {
                                                                      animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                                                                      return ScaleTransition(
                                                                        alignment: Alignment.center,
                                                                        scale: animation1,
                                                                        child: child,
                                                                      );
                                                                    },
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

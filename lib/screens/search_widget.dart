import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../utils/hover_widget/hover_widget.dart';
import '../controller/controller.dart';

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
    searchNode.requestFocus();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: width,
      height: height,
      margin: EdgeInsets.only(
        left: width * 0.7,
        bottom: height * 0.3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.02),
        color: const Color(0xFF0E0E0E),
      ),
      child:  Column(
        children: [
          TextFormField(
            focusNode: searchNode,
            onChanged: (value) => widget.controller.filter(value, true),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.only(
              top: height * 0.02,
            ),
            height: height * 0.575,
            child: ValueListenableBuilder(
              valueListenable: widget.controller.found,
              builder: (context, value, child) {
                return widget.controller.found.value.isNotEmpty ?
                ListView.builder(
                  itemCount: widget.controller.found.value.length,
                  itemBuilder: (context, int index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: height * 0.075,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            ///TODO: Redo this
                            // widget.controller.settings.playingSongs.clear();
                            // widget.controller.settings.playingSongsUnShuffled.clear();
                            // widget.controller.settings.playingSongs.addAll(widget.controller.found.value);
                            // widget.controller.settings.playingSongsUnShuffled.addAll(widget.controller.found.value);
                            // if (widget.controller.shuffleNotifier.value) {
                            //   widget.controller.settings.playingSongs.shuffle();
                            // }
                            // widget.controller.settingsBox.put(widget.controller.settings);
                            // widget.controller.indexChange(widget.controller.settings.playingSongs.indexOf(widget.controller.found.value[index]));
                            // widget.controller.playSong();
                          },
                          child: FutureBuilder(
                            future: widget.controller.imageRetrieve(widget.controller.found.value[index].path, false),
                            builder: (context, snapshot){
                              return HoverWidget(
                                hoverChild: Container(
                                  padding: EdgeInsets.all(width * 0.005),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(height * 0.01),
                                    color: const Color(0xFF242424),
                                  ),
                                  child: Row(
                                    children: [
                                      HoverWidget(
                                          hoverChild: snapshot.hasData?
                                          AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.075,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.3),
                                                        ),
                                                        child: IconButton(
                                                          icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: height * 0.03,),
                                                          onPressed: () {
                                                            print("Add");
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )) :
                                          snapshot.hasError?
                                          SizedBox(
                                            height: height * 0.1,
                                            width: height * 0.1,
                                            child: Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            ),
                                          ) :
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: height * 0.075,
                                            child: AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          onHover: (event){
                                            return;
                                            //print("Hovering");
                                          },
                                          child: snapshot.hasData?
                                          AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.075,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              )) :
                                          snapshot.hasError?
                                          SizedBox(
                                            height: height * 0.1,
                                            width: height * 0.1,
                                            child: Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            ),
                                          ) :
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: height * 0.075,
                                            child: AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                    )
                                                ),
                                              ),
                                            ),
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
                                onHover: (event){
                                  return;
                                  //print("Hovering");
                                },
                                child: Container(
                                  padding: EdgeInsets.all(width * 0.005),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(height * 0.01),
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      HoverWidget(
                                          hoverChild: snapshot.hasData?
                                          AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.075,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.3),
                                                        ),
                                                        child: IconButton(
                                                          icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: height * 0.03,),
                                                          onPressed: () {
                                                            print("Add");
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )) :
                                          snapshot.hasError?
                                          SizedBox(
                                            height: height * 0.1,
                                            width: height * 0.1,
                                            child: Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            ),
                                          ) :
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: height * 0.075,
                                            child: AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          onHover: (event){
                                            return;
                                            //print("Hovering");
                                          },
                                          child: snapshot.hasData?
                                          AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.075,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              )) :
                                          snapshot.hasError?
                                          SizedBox(
                                            height: height * 0.1,
                                            width: height * 0.1,
                                            child: Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            ),
                                          ) :
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: height * 0.075,
                                            child: AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(height * 0.01),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                    )
                                                ),
                                              ),
                                            ),
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
                              );
                            }
                          )
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

import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/domain/metadata_type.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import '../controller/controller.dart';
import '../utils/hover_widget/hover_widget.dart';

class CreateScreen extends StatefulWidget {
  final Controller controller;
  const CreateScreen({super.key, required this.controller});

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  List<MetadataType> selected = [];
  String playlistName = "New playlist";
  FocusNode searchNode = FocusNode();
  FocusNode nameNode = FocusNode();

  @override
  void initState() {
    super.initState();
    nameNode.requestFocus();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(
              top: height * 0.02,
              left: width * 0.01,
              right: width * 0.01,
              bottom: height * 0.02
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: (){
                      print("Back");
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      FluentIcons.arrow_left_16_filled,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "New playlist",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: (){
                        print("Create new playlist");
                        PlaylistType newPlaylist = PlaylistType();
                        newPlaylist.name = playlistName;
                        newPlaylist.paths = selected.map((e) => e.path).toList();
                        widget.controller.playlistBox.put(newPlaylist);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: normalSize
                        ),
                      )
                  ),
                ],
              ),
              TextFormField(
                  maxLength: 50,
                  initialValue: playlistName,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    hintText: 'Playlist name',
                    counterText: "",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: smallSize,
                    ),
                  ),
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: normalSize,
                  ),
                  onChanged: (value) {
                    setState(() {
                      playlistName = value;
                    });
                  },
                ),
              SizedBox(
                height: height * 0.025,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(width * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  color: const Color(0xFF242424),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: searchNode,
                      onChanged: (value) => widget.controller.filter(value, false),
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: smallSize,
                          ),
                          labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white, size: height * 0.02,)
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    SizedBox(
                      height: height * 0.5,
                      child: ValueListenableBuilder(
                        valueListenable: widget.controller.found2,
                        builder: (context, value, child){
                          return widget.controller.found2.value.isNotEmpty ?
                          ListView.builder(
                            itemCount: widget.controller.found2.value.length,
                            itemBuilder: (context, int index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: height * 0.1,
                                padding: EdgeInsets.only(right: width * 0.01),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: (){
                                        print("Tapped on $index");
                                        setState(() {
                                          selected.contains(widget.controller.found2.value[index]) ? selected.remove(widget.controller.found2.value[index]) : selected.add(widget.controller.found2.value[index]);
                                        });
                                      },
                                      child: HoverWidget(
                                        hoverChild: Container(
                                          padding: EdgeInsets.all(width * 0.005),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(width * 0.01),
                                            color: const Color(0xFF2E2E2E),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(width * 0.01),
                                                child: FutureBuilder(
                                                  future: widget.controller.imageRetrieve(widget.controller.found2.value[index].path, false),
                                                  builder: (context, snapshot) {
                                                    return AspectRatio(
                                                      aspectRatio: 1.0,
                                                      child: snapshot.hasData?
                                                      Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors.black,
                                                                image: DecorationImage(
                                                                  fit: BoxFit.cover,
                                                                  image: Image.memory(snapshot.data!).image,
                                                                )
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            child: BackdropFilter(
                                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                              child: Container(
                                                                color: Colors.black.withOpacity(0.3),
                                                                alignment: Alignment.center,
                                                                child: IconButton(
                                                                  icon: Icon(selected.contains(widget.controller.found2.value[index]) ? FluentIcons.subtract_16_filled : FluentIcons.add_16_filled, color: Colors.white, size: height * 0.03,),
                                                                  onPressed: () {
                                                                    print("Add");
                                                                    setState(() {
                                                                      selected.contains(widget.controller.found2.value[index]) ? selected.remove(widget.controller.found2.value[index]) : selected.add(widget.controller.found2.value[index]);
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ) :
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
                                                              image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                            )
                                                        ),
                                                        child: const Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
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
                                                        widget.controller.found2.value[index].title.toString().length > 30 ? "${widget.controller.found2.value[index].title.toString().substring(0, 30)}..." : widget.controller.found2.value[index].title.toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: normalSize,
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: height * 0.001,
                                                    ),
                                                    Text(widget.controller.found2.value[index].artists.toString().length > 30 ? "${widget.controller.found2.value[index].artists.toString().substring(0, 30)}..." : widget.controller.found2.value[index].artists.toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: smallSize,
                                                        )
                                                    ),
                                                  ]
                                              ),
                                              const Spacer(),
                                              Text(
                                                  "${widget.controller.found2.value[index].duration ~/ 60}:${(widget.controller.found2.value[index].duration % 60).toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: normalSize,
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(width * 0.005),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(height * 0.01),
                                            color: const Color(0xFF0E0E0E),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                  borderRadius: BorderRadius.circular(width * 0.01),
                                                  child: FutureBuilder(
                                                    future: widget.controller.imageRetrieve(widget.controller.found2.value[index].path, false),
                                                    builder: (context, snapshot) {
                                                      return AspectRatio(
                                                        aspectRatio: 1.0,
                                                        child: snapshot.hasData?
                                                        Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.black,
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                    image: Image.memory(snapshot.data!).image,
                                                                  )
                                                              ),
                                                            ),
                                                            if(selected.contains(widget.controller.found2.value[index]))
                                                              BackdropFilter(
                                                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  child: Icon(
                                                                    FluentIcons.checkmark_16_filled,
                                                                    size: height * 0.03,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ) :
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
                                                                image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                              )
                                                          ),
                                                          child: const Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
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
                                                        widget.controller.found2.value[index].title.toString().length > 30 ? "${widget.controller.found2.value[index].title.toString().substring(0, 30)}..." : widget.controller.found2.value[index].title.toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: normalSize,
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: height * 0.001,
                                                    ),
                                                    Text(widget.controller.found2.value[index].artists.toString().length > 30 ? "${widget.controller.found2.value[index].artists.toString().substring(0, 30)}..." : widget.controller.found2.value[index].artists.toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: smallSize,
                                                        )
                                                    ),
                                                  ]
                                              ),
                                              const Spacer(),
                                              Text(
                                                  "${widget.controller.found2.value[index].duration ~/ 60}:${(widget.controller.found2.value[index].duration % 60).toString().padLeft(2, '0')}",
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
                        },
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }
}
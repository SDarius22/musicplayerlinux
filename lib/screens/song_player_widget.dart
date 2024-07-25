import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';
import '../controller/controller.dart';
import '../domain/metadata_type.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/progress_bar/audio_video_progress_bar.dart';

class SongPlayerWidget extends StatefulWidget {
  final Controller controller;
  const SongPlayerWidget(
      {super.key,
        required this.controller,
      });

  @override
  _SongPlayerWidget createState() => _SongPlayerWidget();
}

class _SongPlayerWidget extends State<SongPlayerWidget> {
  late ScrollController itemScrollController;
  var lyricUI = UINetease(
      defaultSize : 20,
      defaultExtSize : 20,
      otherMainSize : 20,
      bias : 0.5,
      lineGap : 5,
      inlineGap : 5,
      highlightColor: Colors.blue,
      lyricAlign : LyricAlign.CENTER,
      lyricBaseLine : LyricBaseLine.CENTER,
      highlight : false
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController = ScrollController();
    });
    widget.controller.colorNotifier.addListener(() {
      setState(() {
        lyricUI = UINetease(
            defaultSize : MediaQuery.of(context).size.height * 0.023,
            defaultExtSize : MediaQuery.of(context).size.height * 0.02,
            otherMainSize : MediaQuery.of(context).size.height * 0.02,
            bias : 0.5,
            lineGap : 5,
            inlineGap : 5,
            highlightColor: widget.controller.colorNotifier.value,
            lyricAlign : LyricAlign.CENTER,
            lyricBaseLine : LyricBaseLine.CENTER,
            highlight : false
        );
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    lyricUI = UINetease(
        defaultSize : MediaQuery.of(context).size.height * 0.023,
        defaultExtSize : MediaQuery.of(context).size.height * 0.02,
        otherMainSize : MediaQuery.of(context).size.height * 0.02,
        bias : 0.5,
        lineGap : 5,
        inlineGap : 5,
        highlightColor: widget.controller.colorNotifier.value,
        lyricAlign : LyricAlign.CENTER,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    return MultiValueListenableBuilder(
      valueListenables: [widget.controller.minimizedNotifier, widget.controller.indexNotifier, widget.controller.imageNotifier],
      builder: (context, values, child){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
          height: values[0] ? height * 0.15 : height,
          width: values[0] ? width * 0.9 : width,
          alignment: values[0] ? Alignment.centerLeft : Alignment.topCenter,
          padding: EdgeInsets.only(
            left: values[0] ? width * 0.002 : width * 0.01,
            right: values[0] ? width * 0.002 : width * 0.01,
            top: values[0] ? height * 0.001 : height * 0.15,
          ),
          decoration: BoxDecoration(
            color: values[0] ? widget.controller.colorNotifier2.value : const Color(0xFF0E0E0E),
            borderRadius: values[0] ? BorderRadius.circular(height * 0.1) : BorderRadius.circular(0),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: values[0] ? WrapCrossAlignment.center : WrapCrossAlignment.start,
            children: [
              if (widget.controller.listNotifier.value == true)
                SizedBox(
                  height: width * 0.275,
                  width: width * 0.275 * 2,
                  child: ListView.builder(
                    controller: itemScrollController,
                    itemCount: widget.controller.settings.playingSongsUnShuffled.length,
                    itemBuilder: (context, int index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: height * 0.125,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              //print(widget.controller.settings.playingSongsUnShuffled[index].title);
                              widget.controller.audioPlayer.stop();
                              widget.controller.indexNotifier.value = widget.controller.settings.playingSongs.indexOf(widget.controller.settings.playingSongsUnShuffled[index]);
                              widget.controller.indexChange(widget.controller.indexNotifier.value);
                              widget.controller.playSong();
                            },
                            child: FutureBuilder(
                              future: widget.controller.imageRetrieve(widget.controller.settings.playingSongsUnShuffled[index].path, false),
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
                                                    borderRadius: BorderRadius.circular(height * 0.01),
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
                                                  widget.controller.settings.playingSongsUnShuffled[index].title.toString().length > 60 ? "${widget.controller.settings.playingSongsUnShuffled[index].title.toString().substring(0, 60)}..." : widget.controller.settings.playingSongsUnShuffled[index].title.toString(),
                                                  style: TextStyle(
                                                    color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                    fontSize: normalSize,
                                                  )
                                              ),
                                              SizedBox(
                                                height: height * 0.005,
                                              ),
                                              Text(widget.controller.settings.playingSongsUnShuffled[index].artists.toString().length > 60 ? "${widget.controller.settings.playingSongsUnShuffled[index].artists.toString().substring(0, 60)}..." : widget.controller.settings.playingSongsUnShuffled[index].artists.toString(),
                                                  style: TextStyle(
                                                    color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                    fontSize: smallSize,
                                                  )
                                              ),
                                            ]
                                        ),
                                        const Spacer(),
                                        Text(
                                            "${widget.controller.settings.playingSongs[index].duration ~/ 60}:${(widget.controller.settings.playingSongs[index].duration % 60).toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                              color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                              fontSize: normalSize,
                                            )
                                        ),
                                        Container(
                                          width: 35,
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
                                                    borderRadius: BorderRadius.circular(height * 0.01),
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
                                                    borderRadius: BorderRadius.circular(height * 0.01),
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
                                                  widget.controller.settings.playingSongsUnShuffled[index].title.toString().length > 60 ? "${widget.controller.settings.playingSongsUnShuffled[index].title.toString().substring(0, 60)}..." : widget.controller.settings.playingSongsUnShuffled[index].title.toString(),
                                                  style: TextStyle(
                                                    color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                    fontSize: normalSize,
                                                  )
                                              ),
                                              SizedBox(
                                                height: height * 0.005,
                                              ),
                                              Text(widget.controller.settings.playingSongsUnShuffled[index].artists.toString().length > 60 ? "${widget.controller.settings.playingSongsUnShuffled[index].artists.toString().substring(0, 60)}..." : widget.controller.settings.playingSongsUnShuffled[index].artists.toString(),
                                                  style: TextStyle(
                                                    color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                    fontSize: smallSize,
                                                  )
                                              ),
                                            ]
                                        ),
                                        const Spacer(),
                                        Text(
                                            "${widget.controller.settings.playingSongs[index].duration ~/ 60}:${(widget.controller.settings.playingSongs[index].duration % 60).toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                              color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                              fontSize: normalSize,
                                            )
                                        ),
                                        Container(
                                          width: 35,
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
                  )
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: values[0]? width * 0.075 : width * 0.275,
                  width: values[0] ? width * 0.075 : width * 0.275,
                  padding: EdgeInsets.all(width * 0.01),
                  //color: Colors.red,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: values[0] ? BorderRadius.circular(width * 0.1) : BorderRadius.circular(width * 0.03),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.memory(widget.controller.imageNotifier.value).image,
                        )
                      ),
                    ),
                  ),
                ),
              if (!values[0] && !widget.controller.listNotifier.value)
              // Song Details
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: width * 0.275,
                  width: width * 0.275,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Track:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.005,
                      ),
                      Text(
                        widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].title.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: boldSize,
                          fontWeight: FontWeight.bold
                          ,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Text(
                        "Artists:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.005,
                      ),
                      Text(
                        widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].artists.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: boldSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Text(
                        "Album:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.005,
                      ),
                      Text(
                        widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].album.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: boldSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if(!values[0])
                MultiValueListenableBuilder(
                  valueListenables: [widget.controller.lyricModelNotifier, widget.controller.sliderNotifier, widget.controller.playingNotifier, widget.controller.colorNotifier, widget.controller.colorNotifier2],
                  builder: (context, value, child){
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: width * 0.275,
                      padding: EdgeInsets.symmetric(
                        vertical: width * 0.025,
                      ),
                      width: width * 0.275,
                      child: LyricsReader(
                        model: value[0],
                        position: value[1],
                        lyricUi: lyricUI,
                        playing: widget.controller.playingNotifier.value,
                        size: Size.infinite,
                        padding: EdgeInsets.only(
                          right: width * 0.02,
                          left: width * 0.02,
                        ),
                        selectLineBuilder: (progress, confirm) {
                          return Row(
                            children: [
                              Icon(FluentIcons.play_12_filled, color: widget.controller.colorNotifier.value),
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      confirm.call();
                                      setState(() {
                                        widget.controller.audioPlayer.seek(Duration(milliseconds: progress));
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                //progress.toString(),
                                "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                                style: TextStyle(color: widget.controller.colorNotifier.value),
                              )
                            ],
                          );
                        },
                        emptyBuilder: () => widget.controller.plainLyricNotifier.value.contains("No lyrics") || widget.controller.plainLyricNotifier.value.contains("Searching")?
                        Center(
                          child: Text(
                            widget.controller.plainLyricNotifier.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: normalSize,
                              fontFamily: 'Bahnschrift',
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ): ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  widget.controller.plainLyricNotifier.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: normalSize,
                                    fontFamily: 'Bahnschrift',
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                            ),
                          ),
                        ),

                      ),
                    );
                  }
                ),

              if(!values[0])
              Column(
                children: [
                  // Minimize/Maximize button
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: (){
                        widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
                        widget.controller.listNotifier.value = false;
                      }, icon: Icon(
                    widget.controller.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                    size: width * 0.01,
                  )
                  ),
                  if (!widget.controller.minimizedNotifier.value)
                    IconButton(
                        onPressed: () {
                          setState(() {
                            widget.controller.listNotifier.value = !widget.controller.listNotifier.value;
                          });
                          if (widget.controller.listNotifier.value == true) {
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (itemScrollController.hasClients) {
                                itemScrollController.animateTo(
                                  widget.controller.indexNotifier.value * height * 0.125,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                          }
                        },
                        padding: const EdgeInsets.all(0),
                        icon: Icon(FluentIcons.list_20_filled, size: width * 0.01)
                    ),
                  IconButton(
                      onPressed: () async {
                        await widget.controller.searchLyrics();
                      },
                      icon: Icon(FluentIcons.search_sparkle_24_filled, size: width * 0.01)
                  ),


                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(values[0])
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.01,
                    ),
                    child: Text(
                      // Song Title - Artist with maximum 65 characters
                      "${widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].title} - ${widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].artists}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontFamily: 'Bahnschrift',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  //ProgressBar
                  MultiValueListenableBuilder(
                      valueListenables: [widget.controller.sliderNotifier, widget.controller.colorNotifier],
                      builder: (context, values, child){
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: widget.controller.minimizedNotifier.value ? width * 0.775 : width * 0.9,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.01,
                            vertical: widget.controller.minimizedNotifier.value ? 0 : height * 0.03,
                          ),
                          child: ProgressBar(
                            progress: Duration(milliseconds: values[0]),
                            total: Duration(seconds: widget.controller.settings.playingSongs.isNotEmpty? widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].duration : 0),
                            progressBarColor: values[1],
                            baseBarColor: Colors.white.withOpacity(0.24),
                            bufferedBarColor: Colors.white.withOpacity(0.24),
                            thumbColor: Colors.white,
                            barHeight: 4.0,
                            thumbRadius: 7.0,
                            timeLabelLocation: widget.controller.minimizedNotifier.value ? TimeLabelLocation.sides : TimeLabelLocation.below,
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: height * 0.02,
                              fontFamily: 'Bahnschrift',
                              fontWeight: FontWeight.normal,
                            ),
                            onSeek: (duration) {
                              widget.controller.audioPlayer.seek(duration);
                            },
                          ),
                        );
                      }
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: width * 0.7,
                    height: height * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if(widget.controller.shuffleNotifier.value == false) {
                                  widget.controller.shuffleNotifier.value = true;
                                  // MetadataType song = widget.controller.settings.playingSongs[widget.controller.indexNotifier.value];
                                  // widget.controller.settings.playingSongs.shuffle();
                                  // setState(() {
                                  //   widget.controller.indexNotifier.value = widget.controller.settings.playingSongs.indexOf(song);
                                  // });
                                }
                                else{
                                  widget.controller.shuffleNotifier.value = false;
                                  // MetadataType song = widget.controller.settings.playingSongs[widget.controller.indexNotifier.value];
                                  // widget.controller.settings.playingSongs.clear();
                                  // widget.controller.settings.playingSongs.addAll(widget.controller.settings.playingSongsUnShuffled);
                                  // setState(() {
                                  //   widget.controller.indexNotifier.value = widget.controller.settings.playingSongsUnShuffled.indexOf(song);
                                  //
                                  // });
                                }
                              });
                            },
                            icon: widget.controller.shuffleNotifier.value == false ?
                            Icon(FluentIcons.arrow_shuffle_off_16_filled, size: height * 0.024) :
                            Icon(FluentIcons.arrow_shuffle_16_filled, size: height * 0.024)),
                        IconButton(
                          onPressed: () async {
                            //print("previous");
                            await widget.controller.previousSong();
                          },
                          icon: Icon(
                            FluentIcons.previous_16_filled,
                            color: Colors.white,
                            size: height * 0.022,
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: widget.controller.playingNotifier,
                            builder: (context, value, child){
                              return IconButton(
                                onPressed: () async {
                                  print("pressed pause play");
                                  widget.controller.playSong();
                                },
                                icon: widget.controller.playingNotifier.value ?
                                Icon(FluentIcons.pause_16_filled, color: Colors.white, size: height * 0.023,) :
                                Icon(FluentIcons.play_16_filled, color: Colors.white, size: height * 0.023,),
                              );
                            }
                        ),
                        IconButton(
                          onPressed: () async {
                            //print("next");
                            return await widget.controller.nextSong();
                          },
                          icon: Icon(FluentIcons.next_16_filled, color: Colors.white, size: height * 0.022, ),
                        ),
                        IconButton(
                            onPressed: () {
                              if(widget.controller.repeatNotifier.value == false) {
                                widget.controller.repeatNotifier.value = true;
                              } else {
                                widget.controller.repeatNotifier.value = false;
                              }
                              setState(() {});
                            },
                            icon: widget.controller.repeatNotifier.value == false ?
                            Icon(FluentIcons.arrow_repeat_all_16_filled, size: height * 0.024,) :
                            Icon(FluentIcons.arrow_repeat_1_16_filled, size: height * 0.024)
                        ),

                      ],
                    ),
                  ),
                  //Player Controls - Previous, Play/Pause, Next

                ],
              ),

              if(values[0])
                Column(
                  children: [
                    // Minimize/Maximize button
                    IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: (){
                          widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
                          widget.controller.listNotifier.value = false;
                        }, icon: Icon(
                      widget.controller.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                      size: width * 0.01,
                    )
                    ),
                  ],
                ),
            ],
          ),
        );
      }
    );
  }
}

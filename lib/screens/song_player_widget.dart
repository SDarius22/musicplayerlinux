import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';
import '../controller/controller.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/progress_bar/audio_video_progress_bar.dart';
import 'image_widget.dart';

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
  void dispose() {
    itemScrollController.dispose();
    widget.controller.colorNotifier.removeListener(() {});
    super.dispose();
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
        valueListenables: [widget.controller.minimizedNotifier, widget.controller.indexNotifier, widget.controller.imageNotifier, widget.controller.hiddenNotifier, widget.controller.listChangeNotifier],
        builder: (context, values, child){
          return Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                ignoring: values[3],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                  height: values[0] ? height * 0.15 : height,
                  width: values[0] ? width * 0.9 : width,
                  alignment: values[0] ? Alignment.centerLeft : Alignment.topCenter,
                  padding: EdgeInsets.only(
                    left: values[0] ? 0 : width * 0.01,
                    right: values[0] ? 0 : width * 0.01,
                    top: values[0] ? 0 : height * 0.15,
                  ),
                  margin: EdgeInsets.only(
                    bottom: values[0] ? height * 0.01 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: values[0] ? widget.controller.colorNotifier2.value.withOpacity(values[3] ? 0.0 : 1) : const Color(0xFF0E0E0E),
                    borderRadius: values[0] ? BorderRadius.circular(width * 0.1) : BorderRadius.circular(0),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: values[0] ? WrapCrossAlignment.center : WrapCrossAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: widget.controller.listNotifier.value == true?
                        SizedBox(
                            height: width * 0.275,
                            width: width * 0.275 * 2,
                            child: ListView.builder(
                              controller: itemScrollController,
                              itemCount: widget.controller.settings.playingSongsUnShuffled.length,
                              padding: EdgeInsets.only(
                                  right: width * 0.01
                              ),
                              itemBuilder: (context, int index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  height: height * 0.125,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () async {
                                          //print(widget.controller.settings.playingSongsUnShuffled[index].title);
                                          //widget.controller.audioPlayer.stop();
                                          widget.controller.indexChange(widget.controller.settings.playingSongsUnShuffled[index]);
                                          await widget.controller.playSong();
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(width * 0.01),
                                          child: HoverContainer(
                                            hoverColor: const Color(0xFF242424),
                                            normalColor: const Color(0xFF0E0E0E),
                                            padding: EdgeInsets.all(width * 0.005),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(width * 0.01),
                                                  child: ImageWidget(
                                                    controller: widget.controller,
                                                    path: widget.controller.settings.playingSongsUnShuffled[index].path,
                                                    buttons: IconButton(
                                                      onPressed: () async {
                                                        print("Delete song from queue");
                                                        await widget.controller.removeFromQueue(widget.controller.settings.playingSongsUnShuffled[index]);
                                                      },
                                                      icon: Icon(
                                                        FluentIcons.delete_16_filled,
                                                        color: Colors.white,
                                                        size: width * 0.01,
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
                                                    "${widget.controller.settings.playingSongsUnShuffled[index].duration ~/ 60}:${(widget.controller.settings.playingSongsUnShuffled[index].duration % 60).toString().padLeft(2, '0')}",
                                                    style: TextStyle(
                                                      color: widget.controller.settings.playingSongsUnShuffled[index] != widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                );

                              },
                            )
                        ) :
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: values[0]? width * 0.08 : width * 0.275,
                          width: values[0] ? width * 0.08 : width * 0.275,
                          padding: EdgeInsets.all(width * 0.01),
                          alignment: Alignment.center,
                          //color: Colors.red,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
                                  color: Colors.black.withOpacity(values[3] ? 0.3 : 1),
                                  borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
                                  image: DecorationImage(
                                    opacity: values[3] ? 0.5 : 1,
                                    fit: BoxFit.cover,
                                    image: Image.memory(widget.controller.imageNotifier.value).image,
                                  )
                              ),
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
                                "Artist:",
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
                                  widget.controller.hiddenNotifier.value = false;
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
                                            widget.controller.settings.playingSongsUnShuffled.indexOf(widget.controller.settings.playingSongs[widget.controller.indexNotifier.value]) * height * 0.125,
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
                                  color: Colors.white.withOpacity(values[3] ? 0.0 : 1),
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
                                    progressBarColor: values[1].withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0),
                                    baseBarColor: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 0.24),
                                    bufferedBarColor: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 0.24),
                                    thumbColor: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0),
                                    barHeight: 4.0,
                                    thumbRadius: 7.0,
                                    timeLabelLocation: widget.controller.minimizedNotifier.value ? TimeLabelLocation.sides : TimeLabelLocation.below,
                                    timeLabelTextStyle: TextStyle(
                                      color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0),
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
                                ValueListenableBuilder(
                                    valueListenable: widget.controller.shuffleNotifier,
                                    builder: (context, value, child){
                                      return IconButton(
                                          onPressed: () {
                                              widget.controller.setShuffle();
                                          },
                                          icon: value == false ?
                                          Icon(FluentIcons.arrow_shuffle_off_16_filled, size: height * 0.024, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1)) :
                                          Icon(FluentIcons.arrow_shuffle_16_filled, size: height * 0.024), color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1)
                                      );
                                    }
                                ),

                                IconButton(
                                  onPressed: () async {
                                    await widget.controller.previousSong();
                                  },
                                  icon: Icon(
                                    FluentIcons.previous_16_filled,
                                    color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0),
                                    size: height * 0.022,
                                  ),
                                ),
                                MultiValueListenableBuilder(
                                    valueListenables: [widget.controller.playingNotifier, widget.controller.loadingNotifier],
                                    builder: (context, value, child){
                                      return widget.controller.loadingNotifier.value? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                          : IconButton(
                                        onPressed: () async {
                                          //print("pressed pause play");
                                          await widget.controller.playSong();
                                        },
                                        icon: widget.controller.playingNotifier.value ?
                                        Icon(FluentIcons.pause_16_filled, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.023,) :
                                        Icon(FluentIcons.play_16_filled, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.023,),
                                      );
                                    }
                                ),
                                IconButton(
                                  onPressed: () async {
                                    //print("next");
                                    return await widget.controller.nextSong();
                                  },
                                  icon: Icon(FluentIcons.next_16_filled, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.022, ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: widget.controller.repeatNotifier,
                                  builder: (context, value, child){
                                    return IconButton(
                                        onPressed: () {
                                          widget.controller.setRepeat();
                                        },
                                        icon: value == false ?
                                        Icon(FluentIcons.arrow_repeat_all_16_filled, size: height * 0.024, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0)) :
                                        Icon(FluentIcons.arrow_repeat_1_16_filled, size: height * 0.024, color: Colors.white.withOpacity(widget.controller.hiddenNotifier.value ? 0.0 : 1.0))
                                    );
                                  }
                                ),


                              ],
                            ),
                          ),
                          //Player Controls - Previous, Play/Pause, Next

                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (values[0])
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                  height: values[0] ? height * 0.15 : height,
                  width: values[0] ? width * 0.9 : width,
                  alignment: values[0] ? Alignment.centerRight : Alignment.topCenter,
                  padding: EdgeInsets.only(
                    left: values[0] ? width * 0.002 : width * 0.01,
                    right: values[0] ? width * 0.02 : width * 0.01,
                    top: values[0] ? 0 : height * 0.15,
                  ),
                  margin: EdgeInsets.only(
                    bottom: values[0] ? height * 0.01 : 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minimize/Maximize button
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: (){
                            widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
                            widget.controller.listNotifier.value = false;
                            widget.controller.hiddenNotifier.value = false;
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(widget.controller.hiddenNotifier.value ? 0.5 : 0.0)),
                          ),
                          icon: Icon(
                            widget.controller.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                            size: width * 0.01,
                          )
                      ),
                      // Visibility Toggle
                      IconButton(
                        onPressed: (){
                          print("pressed hidden");
                          widget.controller.hiddenNotifier.value = !widget.controller.hiddenNotifier.value;
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(widget.controller.hiddenNotifier.value ? 0.5 : 0.0)),
                        ),
                        icon: Icon(
                          widget.controller.hiddenNotifier.value ? FluentIcons.eye_16_filled : FluentIcons.eye_off_16_filled,
                          color: Colors.white,
                          size: width * 0.01,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
    );

  }
}

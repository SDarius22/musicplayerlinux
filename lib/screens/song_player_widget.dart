import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../domain/song_type.dart';
import '../utils/lyric_reader/lyrics_reader_model.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';
import '../controller/controller.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/objectbox.g.dart';
import '../utils/progress_bar/audio_video_progress_bar.dart';
import 'image_widget.dart';
import 'package:flutter/foundation.dart';

class SongPlayerWidget extends StatefulWidget {
  final Controller controller;
  const SongPlayerWidget(
      {super.key,
        required this.controller,
      });

  @override
  _SongPlayerWidgetState createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  late ScrollController itemScrollController;
  late Future imageFuture;
  late Future songFuture;
  late Future lyricFuture;
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
  var lyricModel = LyricsReaderModel();
  String plainLyric = "No lyrics";
  ValueNotifier<bool> hiddenNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> minimizedNotifier = ValueNotifier<bool>(true);
  ValueNotifier<bool> listNotifier = ValueNotifier<bool>(false);


  @override
  void initState() {
    imageFuture = Future(() async {
      Uint8List image = await widget.controller.getImage(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
      widget.controller.updateColors(image);
      return image;
    });
    songFuture = widget.controller.getSong(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
    lyricFuture = widget.controller.getLyrics(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
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
    widget.controller.indexNotifier.addListener(() {
      setState(() {
        imageFuture = Future(() async {
          Uint8List image = await widget.controller.getImage(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
          widget.controller.updateColors(image);
          return image;
        });
        songFuture = widget.controller.getSong(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
        lyricFuture = widget.controller.getLyrics(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
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
    widget.controller.indexNotifier.removeListener(() {});
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return MultiValueListenableBuilder(
        valueListenables: [minimizedNotifier, hiddenNotifier],
        builder: (context, values, child){
          return FutureBuilder(
              future: songFuture,
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.error_circle_24_regular,
                          size: height * 0.1,
                          color: Colors.red,
                        ),
                        Text(
                          "Error loading song",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: smallSize,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              songFuture = widget.controller.getSong(widget.controller.controllerQueue[widget.controller.indexNotifier.value]);
                            });
                          },
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                SongType currentSong = snapshot.data ?? SongType();
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      ignoring: values[1],
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
                          color: values[0] ? widget.controller.colorNotifier2.value.withOpacity(values[1] ? 0.0 : 1) : const Color(0xFF0E0E0E),
                          //color: values[0] ? widget.controller.colorNotifier2.value.withOpacity(values[1] ? 0.0 : 1) : Colors.transparent,
                          borderRadius: values[0] ? BorderRadius.circular(width * 0.1) : BorderRadius.circular(0),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: values[0] ? WrapCrossAlignment.center : WrapCrossAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: listNotifier.value == true?
                              SizedBox(
                                  height: width * 0.275,
                                  width: width * 0.275 * 2,
                                  child: FutureBuilder(
                                    future: widget.controller.getQueue(),
                                    builder: (context, snapshot){
                                      if(snapshot.hasData){
                                        return ListView.builder(
                                          controller: itemScrollController,
                                          itemCount: snapshot.data!.length,
                                          padding: EdgeInsets.only(
                                              right: width * 0.01
                                          ),
                                          itemBuilder: (context, int index) {
                                            var song = snapshot.data![index];
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
                                                      widget.controller.indexChange(widget.controller.settings.queue[index]);
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
                                                                path: widget.controller.settings.queue[index],
                                                                buttons: IconButton(
                                                                  onPressed: () async {
                                                                    print("Delete song from queue");
                                                                    await widget.controller.removeFromQueue(widget.controller.settings.queue[index]);
                                                                    setState(() {});
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
                                                                      song.title.toString().length > 60 ? "${song.title.toString().substring(0, 60)}..." : song.title.toString(),
                                                                      style: TextStyle(
                                                                        color: widget.controller.settings.queue[index] != widget.controller.controllerQueue[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                                        fontSize: normalSize,
                                                                      )
                                                                  ),
                                                                  SizedBox(
                                                                    height: height * 0.005,
                                                                  ),
                                                                  Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                                                                      style: TextStyle(
                                                                        color: widget.controller.settings.queue[index] != widget.controller.controllerQueue[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                                        fontSize: smallSize,
                                                                      )
                                                                  ),
                                                                ]
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                                "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                                                                style: TextStyle(
                                                                  color: widget.controller.settings.queue[index] != widget.controller.controllerQueue[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
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
                                        );
                                      }
                                      else if(snapshot.hasError){
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FluentIcons.error_circle_24_regular,
                                                size: height * 0.1,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                "Error loading queue",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: smallSize,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: (){
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  "Retry",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: smallSize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      else{
                                        return const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        );
                                      }
                                    },
                                  ),
                              ) :
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: values[0]? width * 0.08 : width * 0.275,
                                width: values[0] ? width * 0.08 : width * 0.275,
                                padding: EdgeInsets.all(width * 0.01),
                                alignment: Alignment.center,
                                //color: Colors.red,
                                child: FutureBuilder(
                                    future: imageFuture,
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData) {
                                        return AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
                                                color: Colors.black.withOpacity(values[1] ? 0.3 : 1),
                                                borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
                                                image: DecorationImage(
                                                  opacity: values[1] ? 0.5 : 1,
                                                  fit: BoxFit.cover,
                                                  image: Image.memory(snapshot.data as Uint8List).image,
                                                )
                                            ),
                                          ),
                                        );
                                      }
                                      return const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      );
                                    }
                                ),
                              ),
                            ),

                            if (!values[0] && !listNotifier.value)
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
                                      currentSong.title.toString(),
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
                                      currentSong.artists.toString(),
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
                                      currentSong.album.toString(),
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
                              FutureBuilder(
                                future: lyricFuture,
                                builder: (context, snapshot){
                                  if(snapshot.hasData){
                                    plainLyric = snapshot.data as String;
                                    lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data as String).getModel();
                                    return MultiValueListenableBuilder(
                                        valueListenables: [widget.controller.sliderNotifier, widget.controller.playingNotifier],
                                        builder: (context, value, child){
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: width * 0.275,
                                            padding: EdgeInsets.symmetric(
                                              vertical: width * 0.025,
                                            ),
                                            width: width * 0.275,
                                            child: LyricsReader(
                                              model: lyricModel,
                                              position: value[0],
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
                                              emptyBuilder: () => plainLyric.contains("No lyrics") || plainLyric.contains("Searching")?
                                                Center(
                                                    child: Text(
                                                      plainLyric,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: normalSize,
                                                        fontFamily: 'Bahnschrift',
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    )
                                                ):
                                                ScrollConfiguration(
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
                                                          plainLyric,
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
                                    );
                                  }
                                  else if(snapshot.hasError){
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentIcons.error_circle_24_regular,
                                            size: height * 0.1,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            "Error loading lyrics",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: smallSize,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: (){
                                              setState(() {});
                                            },
                                            child: Text(
                                              "Retry",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: smallSize,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else {
                                    return const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    );
                                  }
                                }
                              ),

                            if(!values[0])
                              Column(
                                children: [
                                  // Minimize/Maximize button
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: (){
                                        minimizedNotifier.value = !minimizedNotifier.value;
                                        listNotifier.value = false;
                                        hiddenNotifier.value = false;
                                      }, icon: Icon(
                                    minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                                    size: width * 0.01,
                                  )
                                  ),
                                  if (!minimizedNotifier.value)
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            listNotifier.value = !listNotifier.value;
                                          });
                                          if (listNotifier.value == true) {
                                            Future.delayed(const Duration(milliseconds: 200), () {
                                              if (itemScrollController.hasClients) {
                                                itemScrollController.animateTo(
                                                  widget.controller.settings.queue.indexOf(widget.controller.controllerQueue[widget.controller.indexNotifier.value]) * height * 0.125,
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
                                        setState(() {
                                          plainLyric = "Searching for lyrics...";
                                        });
                                        List<String> foundLyrics = await widget.controller.searchLyrics();
                                        setState(() {
                                          plainLyric = foundLyrics[0];
                                          lyricModel = LyricsModelBuilder.create().bindLyricToMain(foundLyrics[1]).getModel();
                                        });

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
                                      "${currentSong.title} - ${currentSong.artists}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(values[1] ? 0.0 : 1),
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
                                        width: minimizedNotifier.value ? width * 0.775 : width * 0.9,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: minimizedNotifier.value ? 0 : height * 0.03,
                                        ),
                                        child: FutureBuilder(
                                          future: widget.controller.getDuration(currentSong),
                                          builder: (context, snapshot){
                                            return ProgressBar(
                                              progress: Duration(milliseconds: values[0]),
                                              total: snapshot.hasData ? snapshot.data as Duration : Duration.zero,
                                              progressBarColor: values[1].withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                              baseBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
                                              bufferedBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
                                              thumbColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                              barHeight: 4.0,
                                              thumbRadius: 7.0,
                                              timeLabelLocation: minimizedNotifier.value ? TimeLabelLocation.sides : TimeLabelLocation.below,
                                              timeLabelTextStyle: TextStyle(
                                                color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                                fontSize: height * 0.02,
                                                fontFamily: 'Bahnschrift',
                                                fontWeight: FontWeight.normal,
                                              ),
                                              onSeek: (duration) {
                                                widget.controller.audioPlayer.seek(duration);
                                              },
                                            );
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
                                                Icon(FluentIcons.arrow_shuffle_off_16_filled, size: height * 0.024, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)) :
                                                Icon(FluentIcons.arrow_shuffle_16_filled, size: height * 0.024), color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
                                            );
                                          }
                                      ),

                                      IconButton(
                                        onPressed: () async {
                                          await widget.controller.previousSong();
                                        },
                                        icon: Icon(
                                          FluentIcons.previous_16_filled,
                                          color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                          size: height * 0.022,
                                        ),
                                      ),
                                      if(snapshot.hasData)
                                      MultiValueListenableBuilder(
                                          valueListenables: [widget.controller.playingNotifier],
                                          builder: (context, value, child){
                                            return IconButton(
                                              onPressed: () async {
                                                //print("pressed pause play");
                                                await widget.controller.playSong();
                                              },
                                              icon: widget.controller.playingNotifier.value ?
                                              Icon(FluentIcons.pause_16_filled, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.023,) :
                                              Icon(FluentIcons.play_16_filled, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.023,),
                                            );
                                          }
                                      )
                                      else
                                        const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      IconButton(
                                        onPressed: () async {
                                          //print("next");
                                          return await widget.controller.nextSong();
                                        },
                                        icon: Icon(FluentIcons.next_16_filled, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.022, ),
                                      ),
                                      ValueListenableBuilder(
                                          valueListenable: widget.controller.repeatNotifier,
                                          builder: (context, value, child){
                                            return IconButton(
                                                onPressed: () {
                                                  widget.controller.setRepeat();
                                                },
                                                icon: value == false ?
                                                Icon(FluentIcons.arrow_repeat_all_16_filled, size: height * 0.024, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0)) :
                                                Icon(FluentIcons.arrow_repeat_1_16_filled, size: height * 0.024, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0))
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
                                  minimizedNotifier.value = !minimizedNotifier.value;
                                  listNotifier.value = false;
                                  hiddenNotifier.value = false;
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
                                ),
                                icon: Icon(
                                  minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                                  size: width * 0.01,
                                )
                            ),
                            // Visibility Toggle
                            IconButton(
                              onPressed: (){
                                print("pressed hidden");
                                hiddenNotifier.value = !hiddenNotifier.value;
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
                              ),
                              icon: Icon(
                                hiddenNotifier.value ? FluentIcons.eye_16_filled : FluentIcons.eye_off_16_filled,
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
    );

  }
}

import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/controller/audio_player_controller.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/worker_controller.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import 'package:provider/provider.dart';
import '../controller/app_manager.dart';
import '../controller/settings_controller.dart';
import '../domain/song_type.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';
import '../utils/lyric_reader/lyrics_reader.dart';
import '../utils/progress_bar/audio_video_progress_bar.dart';
import 'image_widget.dart';
import 'package:flutter/foundation.dart';

class SongPlayerWidget extends StatefulWidget {
  const SongPlayerWidget({super.key});

  @override
  _SongPlayerWidgetState createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  late ScrollController itemScrollController;
  late Future songFuture;
  late Future imageFuture;
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
  ValueNotifier<bool> editMode = ValueNotifier<bool>(false);
  ValueNotifier<bool> hiddenNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> listNotifier = ValueNotifier<bool>(false);


  @override
  void initState() {
    songFuture = Future(() async {
      SongType song = SongType();
      try {
        song = await DataController.getSong(SettingsController.currentSongPath);
      } catch (e) {
        print(e);
      }
      return song;
    });
    lyricFuture = Future(() async {
      try {
        return await DataController.getLyrics(SettingsController.currentSongPath);
      } catch (e) {
        print(e);
        return ["No lyrics found", "No lyrics found"];
      }
    });
    imageFuture = Future(() async {
      Uint8List image = await WorkerController.getImage(SettingsController.currentSongPath);
      AppManager.updateColors(image);
      return image;
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController = ScrollController();
    });
    SettingsController.lightColorNotifier.addListener(() {
      setState(() {
        lyricUI = UINetease(
            defaultSize : MediaQuery.of(context).size.height * 0.023,
            defaultExtSize : MediaQuery.of(context).size.height * 0.02,
            otherMainSize : MediaQuery.of(context).size.height * 0.02,
            bias : 0.5,
            lineGap : 5,
            inlineGap : 5,
            highlightColor: SettingsController.lightColorNotifier.value,
            lyricAlign : LyricAlign.CENTER,
            lyricBaseLine : LyricBaseLine.CENTER,
            highlight : false
        );
      });
    });
    SettingsController.indexNotifier.addListener((){
      print(SettingsController.currentSongPath);
      setState(() {
        songFuture = Future(() async {
          SongType song = SongType();
          try {
            song = await DataController.getSong(SettingsController.currentSongPath);
          } catch (e) {
            print(e);
          }
          return song;
        });
        lyricFuture = Future(() async {
          try {
            return await DataController.getLyrics(SettingsController.currentSongPath);
          } catch (e) {
            print(e);
            return ["No lyrics found", "No lyrics found"];
          }
        });
        imageFuture = Future(() async {
          Uint8List image = await WorkerController.getImage(SettingsController.currentSongPath);
          AppManager.updateColors(image);
          return image;
        });
      });
    });
    // widget.controller.hasBeenChanged.addListener(() {
    //   setState(() {
    //     imageFuture = Future(() async {
    //       Uint8List image = await widget.controller.getImage(SettingsController.shuffledQueue[SettingsController.index]);
    //       widget.controller.updateColors(image);
    //       return image;
    //     });
    //     songFuture = widget.controller.getSong(SettingsController.shuffledQueue[SettingsController.index]);
    //     lyricFuture = widget.controller.getLyrics(SettingsController.shuffledQueue[SettingsController.index]);
    //     lyricUI = UINetease(
    //         defaultSize : MediaQuery.of(context).size.height * 0.023,
    //         defaultExtSize : MediaQuery.of(context).size.height * 0.02,
    //         otherMainSize : MediaQuery.of(context).size.height * 0.02,
    //         bias : 0.5,
    //         lineGap : 5,
    //         inlineGap : 5,
    //         highlightColor: widget.controller.color,
    //         lyricAlign : LyricAlign.CENTER,
    //         lyricBaseLine : LyricBaseLine.CENTER,
    //         highlight : false
    //     );
    //   });
    // });
  }

  @override
  void dispose() {
    itemScrollController.dispose();
    // widget.controller.color.removeListener(() {});
    // SettingsController.index.removeListener(() {});
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dc = Provider.of<DataController>(context);
    final am = Provider.of<AppManager>(context);
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
        highlightColor: SettingsController.lightColorNotifier.value,
        lyricAlign : LyricAlign.CENTER,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    return MultiValueListenableBuilder(
        valueListenables: [am.minimizedNotifier, hiddenNotifier],
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
                              songFuture = Future(() async {
                                SongType song = SongType();
                                try {
                                  song = await DataController.getSong(SettingsController.shuffledQueue[SettingsController.index]);
                                } catch (e) {
                                  print(e);
                                }
                                return song;
                              });
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
                          color: values[0] ? SettingsController.darkColorNotifier.value.withOpacity(values[1] ? 0.0 : 1) : const Color(0xFF0E0E0E),
                          //color: values[0] ? widget.controller.color2.value.withOpacity(values[1] ? 0.0 : 1) : Colors.transparent,
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
                                  future: DataController.getQueue(),
                                  builder: (context, snapshot){
                                    if(snapshot.hasData){
                                      return ListView.builder(
                                        controller: itemScrollController,
                                        itemCount: snapshot.data!.length,
                                        padding: EdgeInsets.only(
                                            right: width * 0.01
                                        ),
                                        itemBuilder: (context, int index) {
                                          if(index >= 0 && index < SettingsController.queue.length){
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
                                                      //print(SettingsController.playingSongsUnShuffled[index].title);
                                                      //widget.controller.audioPlayer.stop();
                                                      // DataController.indexChange(SettingsController.queue[index]);
                                                      SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
                                                      await AudioPlayerController.playSong();
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
                                                                path: SettingsController.queue[index],
                                                                buttons: IconButton(
                                                                  onPressed: () async {
                                                                    print("Delete song from queue");
                                                                    await dc.removeFromQueue(SettingsController.queue[index]);
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
                                                                        color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                                                                        fontSize: normalSize,
                                                                      )
                                                                  ),
                                                                  SizedBox(
                                                                    height: height * 0.005,
                                                                  ),
                                                                  Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                                                                      style: TextStyle(
                                                                        color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                                                                        fontSize: smallSize,
                                                                      )
                                                                  ),
                                                                ]
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                                "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                                                                style: TextStyle(
                                                                  color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
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
                                          }
                                          return null;
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
                                  builder: (context, snapshot){
                                    if(snapshot.hasData){
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
                                                image: Image.memory(snapshot.data).image,
                                              )
                                          ),
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
                              ),
                            ),

                            if (!values[0] && !listNotifier.value)
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
                                    String plainLyric = snapshot.data![0];
                                    var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
                                    return MultiValueListenableBuilder(
                                        valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
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
                                              playing: SettingsController.playing,
                                              size: Size.infinite,
                                              padding: EdgeInsets.only(
                                                right: width * 0.02,
                                                left: width * 0.02,
                                              ),
                                              selectLineBuilder: (progress, confirm) {
                                                return Row(
                                                  children: [
                                                    Icon(FluentIcons.play_12_filled, color: SettingsController.lightColorNotifier.value),
                                                    Expanded(
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            confirm.call();
                                                            setState(() {
                                                              AudioPlayerController.audioPlayer.seek(Duration(milliseconds: progress));
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      //progress.toString(),
                                                      "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                                                      style: TextStyle(color: SettingsController.lightColorNotifier.value),
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
                                              setState(() {
                                                lyricFuture = DataController.getLyrics(SettingsController.shuffledQueue[SettingsController.index]);
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
                                  else {
                                    return Center(
                                        child: Text(
                                          "Searching for lyrics...",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: normalSize,
                                            fontFamily: 'Bahnschrift',
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
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
                                        am.minimizedNotifier.value = !am.minimizedNotifier.value;
                                        listNotifier.value = false;
                                        hiddenNotifier.value = false;
                                      }, icon: Icon(
                                    am.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                                    size: width * 0.01,
                                  )
                                  ),
                                  if (! am.minimizedNotifier.value)
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            listNotifier.value = !listNotifier.value;
                                          });
                                          if (listNotifier.value == true) {
                                            Future.delayed(const Duration(milliseconds: 250), () {
                                              if (itemScrollController.hasClients) {
                                                itemScrollController.animateTo(
                                                  SettingsController.queue.indexOf(SettingsController.currentSongPath) * height * 0.125,
                                                  duration: Duration(milliseconds: SettingsController.queue.indexOf(SettingsController.currentSongPath) * 20),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            });
                                          }
                                        },
                                        padding: const EdgeInsets.all(0),
                                        icon: Icon(FluentIcons.list_20_filled, size: width * 0.01)
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
                                // ProgressBar
                                MultiValueListenableBuilder(
                                    valueListenables: [SettingsController.sliderNotifier, SettingsController.lightColorNotifier],
                                    builder: (context, values, child){
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        width:  am.minimizedNotifier.value ? width * 0.775 : width * 0.9,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical:  am.minimizedNotifier.value ? 0 : height * 0.03,
                                        ),
                                        child: FutureBuilder(
                                          future: DataController.getDuration(currentSong),
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
                                              timeLabelLocation:  am.minimizedNotifier.value ? TimeLabelLocation.sides : TimeLabelLocation.below,
                                              timeLabelTextStyle: TextStyle(
                                                color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                                fontSize: height * 0.02,
                                                fontFamily: 'Bahnschrift',
                                                fontWeight: FontWeight.normal,
                                              ),
                                              onSeek: (duration) {
                                                AudioPlayerController.audioPlayer.seek(duration);
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
                                          valueListenable: SettingsController.shuffleNotifier,
                                          builder: (context, value, child){
                                            return IconButton(
                                                onPressed: () {
                                                  SettingsController.shuffle = !SettingsController.shuffle;
                                                },
                                                icon: value == false ?
                                                Icon(FluentIcons.arrow_shuffle_off_16_filled, size: height * 0.024, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)) :
                                                Icon(FluentIcons.arrow_shuffle_16_filled, size: height * 0.024), color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
                                            );
                                          }
                                      ),

                                      IconButton(
                                        onPressed: () async {
                                          await AudioPlayerController.previousSong();
                                        },
                                        icon: Icon(
                                          FluentIcons.previous_16_filled,
                                          color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                          size: height * 0.022,
                                        ),
                                      ),
                                      if(snapshot.hasData)
                                      MultiValueListenableBuilder(
                                          valueListenables: [SettingsController.playingNotifier],
                                          builder: (context, value, child){
                                            return IconButton(
                                              onPressed: () async {
                                                //print("pressed pause play");
                                                if (SettingsController.playing) {
                                                  await AudioPlayerController.pauseSong();
                                                } else {
                                                  await AudioPlayerController.playSong();
                                                }
                                              },
                                              icon: SettingsController.playing ?
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
                                          print("next");
                                          return await AudioPlayerController.nextSong();
                                        },
                                        icon: Icon(FluentIcons.next_16_filled, color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0), size: height * 0.022, ),
                                      ),
                                      ValueListenableBuilder(
                                          valueListenable: SettingsController.repeatNotifier,
                                          builder: (context, value, child){
                                            return IconButton(
                                                onPressed: () {
                                                  SettingsController.repeat = !SettingsController.repeat;
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
                                  am.minimizedNotifier.value = ! am.minimizedNotifier.value;
                                  listNotifier.value = false;
                                  hiddenNotifier.value = false;
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
                                ),
                                icon: Icon(
                                  am.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                                  size: width * 0.01,
                                )
                            ),
                            // Visibility Toggle
                            IconButton(
                              onPressed: (){
                                print("pressed hiddenNotifier.value");
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

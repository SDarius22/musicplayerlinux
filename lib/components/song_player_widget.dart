import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/animated_background.dart';
import 'package:musicplayer/components/player_tabs/details_tab.dart';
import 'package:musicplayer/components/player_tabs/lyrics_tab.dart';
import 'package:musicplayer/components/player_tabs/queue_tab.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/slider_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SongPlayerWidget extends StatefulWidget{
  const SongPlayerWidget({super.key});

  @override
  State<SongPlayerWidget> createState() => _SongPlayerWidgetState();
}


class _SongPlayerWidgetState extends State<SongPlayerWidget> with TickerProviderStateMixin {
  late AppStateProvider appStateProvider;

  ValueNotifier<bool> likedNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    return Consumer<AudioProvider>(
      builder: (_, audioProvider, __) {
        if (audioProvider.queue.isEmpty) {
          debugPrint("Queue is empty, not showing player");
          return const SizedBox.shrink();
        }
        if (appStateProvider.itemScrollController.hasClients) {
          debugPrint("ItemScrollController has clients, animating to current index, index: ${audioProvider.currentIndex}");
          Future.delayed(const Duration(milliseconds: 250), () {
            appStateProvider.itemScrollController.animateTo(height * 0.1 * audioProvider.currentIndex, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
          });
        }
        return SlidingUpPanel(
          minHeight: height * 0.1,
          maxHeight: height - appWindow.titleBarHeight,
          controller: appStateProvider.panelController,
          collapsed: _buildMinimizedPlayer(width, height, audioProvider),
          panel: _buildMaximizedPlayer(width, height, audioProvider),
          onPanelOpened: () {
            if (appStateProvider.itemScrollController.hasClients) {
              appStateProvider.itemScrollController.jumpTo(height * 0.1 * audioProvider.currentIndex);
            }
          },
        );
      },
    );
  }

  Widget _buildMinimizedPlayer(double width, double height, AudioProvider audioProvider){
    return AnimatedBackground(
      key: const Key("minimizedPlayer"),
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.linear,
      height: height * 0.15,
      width: width,
      alignment: Alignment.centerLeft,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: FractionalOffset.centerLeft,
      //     end: FractionalOffset.centerRight,
      //     colors: [
      //       appStateProvider.darkColor,
      //       Color(0xFF0E0E0E),
      //
      //     ],
      //   ),
      // ),
      padding: EdgeInsets.only(
        top: height * 0.005,
        bottom: height * 0.005,
        left: width * 0.01,
        right: width * 0.01,
      ),
      child: Row(
        children: [
          // Album Art
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(width * 0.01),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.memory(audioProvider.image ?? Uint8List(0)).image,
                    )
                ),
              ),
            ),
          ),

          SizedBox(
            width: width * 0.3,
            child: _buildPlayerButtons(width, height, audioProvider)
          ),

          const Spacer(),

          IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () async {
                appStateProvider.panelController.open();
                // Future.delayed(const Duration(milliseconds: 250), (){
                //   final contentSize = itemScrollController.position.viewportDimension + itemScrollController.position.maxScrollExtent;
                //   itemScrollController.jumpTo(
                //     contentSize * (SettingsController.index / SettingsController.queue.length),
                //   );
                // });
              },
              icon: Icon(
                FluentIcons.maximize, color: Colors.white,
                size: width * 0.01,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMaximizedPlayer(double width, double height, AudioProvider audioProvider){
    return Container(
      key: const Key("maximizedPlayer"),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
          height: MediaQuery.of(context).size.height - appWindow.titleBarHeight,
          width: width,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: height * 0.02,
            bottom: height * 0.02,
            left: width * 0.01,
            right: width * 0.01,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Queue
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: width * 0.3,
                width: width * 0.3,
                // color: Colors.transparent,
                child: QueueTab(),
              ),

              // Album Art
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                height: width * 0.3,
                width: width * 0.3,
                child: DetailsTab(),
              ),

              // Lyrics
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: width * 0.3,
                width: width * 0.3,
                // color: Colors.transparent,
                child: LyricsTab(),
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.03,
                    width: width,
                  ),

                  // ProgressBar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width:  width * 0.92,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical:  height * 0.05,
                    ),
                    alignment: Alignment.center,
                    child: FutureBuilder(
                      future: audioProvider.getDuration(),
                      builder: (context, snapshot){
                        return Consumer<SliderProvider>(
                          builder: (_, sliderProvider, __){
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                height: height * 0.02,
                                child: Center(
                                  child: LinearProgressIndicator(
                                    color: Colors.white,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                              );
                            }
                            return ProgressBar(
                              progress: Duration(milliseconds: sliderProvider.slider),
                              total: snapshot.hasData ? snapshot.data as Duration : Duration.zero,
                              progressBarColor: appStateProvider.darkColor,
                              baseBarColor: Colors.white.withValues(alpha: 0.25),
                              bufferedBarColor: Colors.white.withValues(alpha: 0.25),
                              thumbColor: Colors.white,
                              barHeight: 4.0,
                              thumbRadius: 7.0,
                              timeLabelLocation:  TimeLabelLocation.sides,
                              timeLabelTextStyle: TextStyle(
                                color: Colors.white,
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.normal,
                              ),
                              onSeek: (duration) {
                                sliderProvider.setSlider(
                                  duration.inMilliseconds,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: height * 0.01,
                    width: width,
                  ),

                  // Player Controls - Previous, Play/Pause, Next
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () async {
                            debugPrint("Liked");
                            var currentSong = audioProvider.currentSong;
                            // await dc.updateLiked(currentSong); TODO
                            likedNotifier.value = !likedNotifier.value;
                            if (currentSong.liked) {
                              // am.showNotification("Added ${currentSong.title} to Favorites", 3000);
                            }
                            else {
                              // am.showNotification("Removed ${currentSong.title} from Favorites", 3000);
                            }
                          },
                          icon: Icon(
                              audioProvider.currentSong.liked ? FluentIcons.liked : FluentIcons.unliked,
                              size: height * 0.025,
                              color: Colors.white,
                          )
                        ),

                        SizedBox(
                          width: width * 0.5,
                          child: _buildPlayerButtons(width, height, audioProvider),
                        ),


                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: (){
                            appStateProvider.panelController.close();
                          },
                          icon: Icon(FluentIcons.minimize,
                            color: Colors.white,
                            size: width * 0.01,
                          )
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildPlayerButtons(double width, double height, AudioProvider audioProvider){
    return Consumer<SliderProvider>(
      builder: (context, sliderProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                sliderProvider.setShuffle(!sliderProvider.shuffle);
              },
              icon: Icon(
                sliderProvider.shuffle == false ? FluentIcons.shuffleOff : FluentIcons.shuffleOn,
                size: height * 0.025,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () async {
                await audioProvider.skipToPrevious();
              },
              icon: Icon(
                FluentIcons.previous,
                color: Colors.white,
                size: height * 0.025,
              ),
            ),
            IconButton(
              onPressed: () async {
                //debugPrint("pressed pause play");
                if (sliderProvider.playing) {
                  await audioProvider.pause();
                  appStateProvider.stopAnimation();
                } else {
                  await audioProvider.play();
                  appStateProvider.startAnimation();
                }
              },
              icon: Icon(
                sliderProvider.playing ?
                FluentIcons.pause :
                FluentIcons.play,
                color: Colors.white,
                size: height * 0.025,
              ),
            ),
            IconButton(
              onPressed: () async {
                debugPrint("next");
                return await audioProvider.skipToNext();
              },
              icon: Icon(
                FluentIcons.next,
                color: Colors.white,
                size: height * 0.025,
              ),
            ),
            IconButton(
              onPressed: () {
                sliderProvider.setRepeat(!sliderProvider.repeat);
              },
              icon:
              Icon(
                sliderProvider.repeat == false ? FluentIcons.repeatOff: FluentIcons.repeatOn,
                size: height * 0.025,
                color: Colors.white,
              )
            ),
          ],
        );
      }
    );

  }
}

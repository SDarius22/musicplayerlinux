import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_miniplayer/flutter_miniplayer.dart';
import 'package:musicplayer/providers/albums_provider.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/artist_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/screens/album_screen.dart';
import 'package:musicplayer/screens/artist_screen.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/utils/text_scroll/text_scroll.dart';
import 'package:provider/provider.dart';

class DetailsTab extends StatelessWidget {
  final double opacity;
  DetailsTab({super.key, required this.opacity});
  final ScrollController itemScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;

    var appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

   return Consumer<AudioProvider>(
     builder: (_, audioProvider, __) {
       return AspectRatio(
         aspectRatio: 1.0,
         child: Container(
           decoration: BoxDecoration(
               shape: BoxShape.rectangle,
               color: Colors.black,
               borderRadius: BorderRadius.circular(width * 0.0125),
               image: DecorationImage(
                 fit: BoxFit.cover,
                 image: Image.memory(audioProvider.image ?? Uint8List(0)).image,
               )
           ),
           child: Container(
               alignment: Alignment.bottomCenter,
               padding: EdgeInsets.only(
                 bottom: height * 0.01,
               ),
               decoration: BoxDecoration(
                   shape: BoxShape.rectangle,
                   color: Colors.black,
                   borderRadius: BorderRadius.circular(width * 0.0125),
                   gradient: LinearGradient(
                       begin: FractionalOffset.center,
                       end: FractionalOffset.bottomCenter,
                       colors: [
                         Colors.black.withValues(alpha: 0.0),
                         Colors.black.withValues(alpha: 0.75 * opacity),
                         Colors.black.withValues(alpha: 1.0 * opacity),
                       ],
                       stops: const [0.0, 0.5, 1.0]
                   )
               ),
               child: Opacity(
                 opacity: opacity,
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.end,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     TextScroll(
                       audioProvider.currentSong.name,
                       mode: TextScrollMode.bouncing,
                       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: boldSize,
                         fontWeight: FontWeight.bold,
                       ),
                       pauseOnBounce: const Duration(seconds: 2),
                       delayBefore: const Duration(seconds: 2),
                       pauseBetween: const Duration(seconds: 2),
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         SizedBox(
                           width: width * 0.01,
                         ),
                         Expanded(
                           // width: width * 0.13,
                           // alignment: Alignment.centerRight,
                           child: TextButton.icon(
                             onPressed: () async{
                               appStateProvider.miniPlayerController.animateToHeight(
                                 state: PanelState.MIN,
                               );
                               var artistProvider = Provider.of<ArtistProvider>(context, listen: false);
                               var artist = artistProvider.getArtist(audioProvider.currentSong.trackArtist);
                               if (artist != null) {
                                 Navigator.push(context, ArtistScreen.route(artist: artist));
                               }
                             },
                             icon: Icon(
                               FluentIcons.open,
                               color: Colors.white,
                               size: smallSize,
                             ),
                             iconAlignment: IconAlignment.end,
                             label: TextScroll(
                               audioProvider.currentSong.trackArtist,
                               mode: TextScrollMode.bouncing,
                               velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: normalSize,
                                 fontWeight: FontWeight.normal,
                               ),
                               pauseOnBounce: const Duration(seconds: 2),
                               delayBefore: const Duration(seconds: 2),
                               pauseBetween: const Duration(seconds: 2),
                             ),
                           ),
                         ),
                         Icon(
                           FluentIcons.divider,
                           color: Colors.white,
                           size: normalSize,
                         ),
                         Expanded(
                           // width: width * 0.13,
                           child: TextButton.icon(
                             onPressed: () async {
                                appStateProvider.miniPlayerController.animateToHeight(
                                  state: PanelState.MIN,
                                );
                               var albumProvider = Provider.of<AlbumProvider>(context, listen: false);
                               var album = albumProvider.getAlbum(audioProvider.currentSong.album);
                               if (album != null) {
                                 Navigator.push(context, AlbumScreen.route(album: album));
                               }
                             },
                             icon: Icon(
                               FluentIcons.open,
                               color: Colors.white,
                               size: smallSize,
                             ),
                             label: TextScroll(
                               audioProvider.currentSong.album,
                               mode: TextScrollMode.bouncing,
                               velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: normalSize,
                                 fontWeight: FontWeight.normal,
                               ),
                               pauseOnBounce: const Duration(seconds: 2),
                               delayBefore: const Duration(seconds: 2),
                               pauseBetween: const Duration(seconds: 2),
                             ),
                           ),
                         ),
                         SizedBox(
                           width: width * 0.01,
                         ),

                       ],
                     )
                   ],
                 ),
               ),
           ),
         ),
       );
     },
   );
  }
}
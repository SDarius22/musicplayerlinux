// import 'dart:ui';
//
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:musicplayer/controller/settings_controller.dart';
// import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
// import 'package:musicplayer/utils/hover_widget/hover_container.dart';
// import 'package:musicplayer/entities/album.dart';
// import 'package:musicplayer/services/app_audio_handler.dart';
// import 'package:musicplayer/controller/data_controller.dart';
// import 'package:musicplayer/controller/worker_controller.dart';
// import 'package:musicplayer/components/image_widget.dart';
//
// class AlbumScreen extends StatefulWidget {
//   final Album album;
//   const AlbumScreen({super.key, required this.album});
//
//   @override
//   State<AlbumScreen> createState() => _AlbumScreenState();
// }
//
// class _AlbumScreenState extends State<AlbumScreen> {
//   String duration = "0 seconds";
//
//
//   @override
//   void initState() {
//     widget.album.songs.sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
//     int totalDuration = widget.album.duration;
//     duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
//     duration = duration.replaceAll(" 0 hours,", "");
//     duration = duration.replaceAll(" 0 minutes and", "");
//
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final dc = DataController();
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     var boldSize = height * 0.025;
//     var normalSize = height * 0.02;
//     var smallSize = height * 0.015;
//     return Container(
//       width: width,
//       height: height,
//       padding: EdgeInsets.only(
//           top: height * 0.02,
//           left: width * 0.01,
//           right: width * 0.01,
//           bottom: height * 0.02
//       ),
//       alignment: Alignment.center,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             onPressed: (){
//               debugPrint("Back");
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               FluentIcons.back,
//               size: height * 0.02,
//               color: Colors.white,
//             ),
//           ),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 500),
//             width: width * 0.4,
//             padding: EdgeInsets.only(
//               top: height * 0.1,
//               bottom: height * 0.05,
//             ),
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children:[
//                   Hero(
//                     tag: widget.album.name,
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       curve: Curves.easeInOut,
//                       height: height * 0.5,
//                       padding: EdgeInsets.only(
//                         bottom: height * 0.01,
//                       ),
//                       //color: Colors.red,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(width * 0.025),
//                         child: FutureBuilder(
//                           future: WorkerController.getImage(widget.album.songs.first.path),
//                           builder: (context, snapshot) {
//                             return AspectRatio(
//                               aspectRatio: 1.0,
//                               child: snapshot.hasData?
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black,
//                                   image: DecorationImage(
//                                     fit: BoxFit.cover,
//                                     image: Image.memory(snapshot.data!).image,
//                                   ),
//                                 ),
//                               ) :
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.black,
//                                     image: DecorationImage(
//                                       fit: BoxFit.cover,
//                                       image: Image.asset('assets/logo.png', fit: BoxFit.cover,).image,
//                                     )
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Text(
//                     widget.album.name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: boldSize,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(
//                     height: height * 0.005,
//                   ),
//                   Text(
//                     widget.album.songs.first.albumArtist,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: normalSize,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(
//                     height: height * 0.005,
//                   ),
//                   Text(
//                     "$duration    |  ${widget.album.songs.length} song${widget.album.songs.length > 1 ? "s" : ""}",
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: smallSize,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   SizedBox(
//                     height: height * 0.01,
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         IconButton(
//                           onPressed: () async {
//                             var songPaths = widget.album.songs.map((e) => e.path).toList();
//                             if(SettingsController.queue.equals(songPaths) == false){
//                               dc.updatePlaying(songPaths, 0);
//                             }
//                             SettingsController.index = SettingsController.currentQueue.indexOf(widget.album.songs.first.path);
//                             await AppAudioHandler.play();
//                           },
//                           icon: Icon(
//                             FluentIcons.play,
//                             color: Colors.white,
//                             size: height * 0.025,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: (){
//                             debugPrint("Add ${widget.album.name}");
//                             Navigator.pushNamed(context, '/add', arguments: widget.album.songs);
//                           },
//                           icon: Icon(
//                             FluentIcons.add,
//                             color: Colors.white,
//                             size: height * 0.025,
//                           ),
//                         ),
//                       ]
//                   ),
//                 ]
//             ),
//           ),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 500),
//             width: width * 0.45,
//             padding: EdgeInsets.only(
//               top: height * 0.1,
//               bottom: height * 0.2,
//               left: width * 0.02,
//             ),
//             child: ListView.builder(
//               itemCount: widget.album.songs.length,
//               itemBuilder: (context, int index) {
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 500),
//                   curve: Curves.easeInOut,
//                   height: height * 0.125,
//                   padding: EdgeInsets.only(
//                     right: width * 0.01,
//                   ),
//                   child: MouseRegion(
//                     cursor: SystemMouseCursors.click,
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.translucent,
//                       onTap: () async {
//                         var songPaths = widget.album.songs.map((e) => e.path).toList();
//                         if(SettingsController.queue.equals(songPaths) == false){
//                           dc.updatePlaying(songPaths, index);
//                         }
//                         SettingsController.index = SettingsController.currentQueue.indexOf(widget.album.songs[index].path);
//                         await AppAudioHandler.play();
//                       },
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(width * 0.01),
//                         child: HoverContainer(
//                           padding: EdgeInsets.only(
//                             left: width * 0.0075,
//                             right: width * 0.025,
//                             top: height * 0.0075,
//                             bottom: height * 0.0075,
//                           ),
//                           hoverColor: const Color(0xFF242424),
//                           normalColor: const Color(0xFF0E0E0E),
//                           height: height * 0.125,
//                           child: Row(
//                             children: [
//                               Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(height * 0.02),
//                                     child: ImageWidget(
//                                       path: widget.album.songs[index].path,
//                                       heroTag: widget.album.songs[index].path,
//                                     ),
//                                   ),
//                                   BackdropFilter(
//                                       filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//                                       child: Text(
//                                           "${widget.album.songs[index].trackNumber}",
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: boldSize,
//                                           )
//                                       )
//                                   )
//                                 ],
//                               ),
//                               SizedBox(
//                                 width: width * 0.01,
//                               ),
//                               Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                         widget.album.songs[index].title.toString().length > 40 ? "${widget.album.songs[index].title.toString().substring(0, 40)}..." : widget.album.songs[index].title.toString(),
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: normalSize,
//                                         )
//                                     ),
//                                     SizedBox(
//                                       height: height * 0.005,
//                                     ),
//                                     Text(
//                                         widget.album.songs[index].trackArtist.toString().length > 60 ? "${widget.album.songs[index].trackArtist.toString().substring(0, 60)}..." : widget.album.songs[index].trackArtist.toString(),
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: smallSize,
//                                         )
//                                     ),
//                                   ]
//                               ),
//                               const Spacer(),
//                               Text(
//                                   widget.album.songs[index].duration == 0 ? "??:??" : "${widget.album.songs[index].duration ~/ 60}:${(widget.album.songs[index].duration % 60).toString().padLeft(2, '0')}",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: normalSize,
//                                   )
//                               ),
//                             ],
//                           ),
//
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(
//             width: width * 0.02,
//           ),
//         ],
//       ),
//     );
//   }
// }
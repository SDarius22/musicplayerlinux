// import 'dart:ui';
// import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
// import 'package:flutter/material.dart';
// import 'package:musicplayer/controller/worker_controller.dart';
// import 'package:musicplayer/entities/song.dart';
// import 'package:musicplayer/entities/playlist.dart';
// import 'package:musicplayer/controller/app_manager.dart';
// import 'package:musicplayer/controller/data_controller.dart';
// import 'package:musicplayer/database/objectbox.g.dart';
// import 'package:musicplayer/utils/hover_widget/hover_widget.dart';
//
// class CreateScreen extends StatefulWidget {
//   final List<String> args;
//   const CreateScreen({super.key, required this.args});
//
//   @override
//   State<CreateScreen> createState() => _CreateScreenState();
// }
//
// class _CreateScreenState extends State<CreateScreen> {
//   List<Song> selected = [];
//   String playlistName = "";
//   String playlistAdd = "last";
//   String search = "";
//   FocusNode searchNode = FocusNode();
//   FocusNode nameNode = FocusNode();
//
//   @override
//   void initState() {
//     var name = widget.args[0];
//     var paths = widget.args.sublist(1);
//     playlistName = name;
//     if (paths.isNotEmpty) {
//       for (var path in paths) {
//         debugPrint(path);
//         try {
//           selected.add(DataController.songBox.query(Song_.path.contains(path)).build().findFirst());
//         } catch (e) {
//           debugPrint(e.toString());
//         }
//       }
//     }
//     super.initState();
//     nameNode.requestFocus();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final dc = DataController();
//     final am = AppManager();
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     //var boldSize = height * 0.025;
//     var normalSize = height * 0.02;
//     var smallSize = height * 0.015;
//     return Scaffold(
//       body: Container(
//         width: width,
//         height: height,
//         padding: EdgeInsets.only(
//             top: height * 0.02,
//             left: width * 0.01,
//             right: width * 0.01,
//             bottom: height * 0.02
//         ),
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 IconButton(
//                   onPressed: (){
//                     debugPrint("Back");
//                     Navigator.pop(context);
//                   },
//                   icon: Icon(
//                     FluentIcons.back,
//                     size: height * 0.02,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   "New Playlist",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: normalSize,
//                       fontWeight: FontWeight.bold
//                   ),
//                 ),
//                 const Spacer(),
//                 ElevatedButton(
//                     onPressed: (){
//                       if (playlistName.isEmpty) {
//                         // am.showNotification("Playlist name cannot be empty", 3500);
//                         return;
//                       }
//                       if (selected.isEmpty) {
//                         // am.showNotification("No songs selected", 3500);
//                         return;
//                       }
//                       debugPrint("Create new playlist");
//                       Playlist newPlaylist = Playlist();
//                       newPlaylist.name = playlistName;
//                       newPlaylist.nextAdded = playlistAdd;
//                       for (var song in selected) {
//                         newPlaylist.pathsInOrder.add(song.path);
//                         int duration = song.duration + newPlaylist.duration;
//                         newPlaylist.duration = duration;
//                         bool found = false;
//                         for (var artistCountStr in newPlaylist.artistCount){
//                           if (artistCountStr.contains(song.trackArtist)){
//                             int count = int.parse(artistCountStr.split(" - ")[1]);
//                             count += 1;
//                             newPlaylist.artistCount.remove(artistCountStr);
//                             newPlaylist.artistCount.add("${song.trackArtist} - $count");
//                             found = true;
//                             break;
//                           }
//                         }
//                         if (!found){
//                           newPlaylist.artistCount.add("${song.trackArtist} - 1");
//                         }
//                       }
//                       dc.createPlaylist(newPlaylist);
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       widget.args[0].isEmpty ? "Create" : "Import",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: normalSize
//                       ),
//                     )
//                 ),
//               ],
//             ),
//             TextFormField(
//               maxLength: 50,
//               initialValue: playlistName,
//               decoration: InputDecoration(
//                 border: const UnderlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.white,
//                   ),
//                 ),
//                 hintText: 'Playlist name',
//                 counterText: "",
//                 hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontSize: smallSize,
//                 ),
//               ),
//               cursorColor: Colors.white,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: normalSize,
//               ),
//               onChanged: (value) {
//                 playlistName = value;
//               },
//             ),
//             SizedBox(
//               height: height * 0.01,
//             ),
//
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text("Where to add new songs?",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: normalSize
//                   ),
//                 ),
//                 const Spacer(),
//                 DropdownButton<String>(
//                     value: playlistAdd,
//                     icon: Icon(
//                       FluentIcons.down,
//                       color: Colors.white,
//                       size: height * 0.025,
//                     ),
//                     style: TextStyle(
//                       fontSize: normalSize,
//                       fontWeight: FontWeight.normal,
//                       color: Colors.white,
//                     ),
//                     underline: Container(
//                       height: 0,
//                     ),
//                     borderRadius: BorderRadius.circular(width * 0.01),
//                     padding: EdgeInsets.zero,
//                     alignment: Alignment.center,
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'first',
//                         child: Text("At the beginning"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'last',
//                         child: Text("At the end"),
//                       ),
//                     ],
//                     onChanged: (String? newValue){
//                       setState(() {
//                         playlistAdd = newValue ?? 'last';
//                       });
//                     }
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: height * 0.01,
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//               padding: EdgeInsets.all(width * 0.01),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(width * 0.02),
//                 color: const Color(0xFF242424),
//               ),
//               child: Column(
//                 children: [
//                   TextFormField(
//                     focusNode: searchNode,
//                     onChanged: (value){
//                       setState(() {
//                         search = value;
//                       });
//                     },
//                     cursorColor: Colors.white,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: normalSize,
//                     ),
//                     decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(width * 0.02),
//                           borderSide: const BorderSide(
//                             color: Colors.white,
//                           ),
//                         ),
//                         labelStyle: TextStyle(
//                           color: Colors.white,
//                           fontSize: smallSize,
//                         ),
//                         labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,)
//                     ),
//                   ),
//                   SizedBox(
//                     height: height * 0.02,
//                   ),
//                   SizedBox(
//                     height: height * 0.5,
//                     child: FutureBuilder(
//                         future: DataController.getSongs(search, 25),
//                         builder: (context, snapshot) {
//                           if(snapshot.hasData){
//                             List<Song> songs = snapshot.data ?? [];
//                             return songs.isNotEmpty ?
//                             ListView.builder(
//                               itemCount: songs.length,
//                               itemBuilder: (context, int index) {
//                                 var song = songs[index];
//                                 return AnimatedContainer(
//                                   duration: const Duration(milliseconds: 500),
//                                   curve: Curves.easeInOut,
//                                   height: height * 0.125,
//                                   padding: EdgeInsets.only(right: width * 0.01),
//                                   child: MouseRegion(
//                                     cursor: SystemMouseCursors.click,
//                                     child: GestureDetector(
//                                       behavior: HitTestBehavior.translucent,
//                                       onTap: (){
//                                         debugPrint("Tapped on $index");
//                                         setState(() {
//                                           selected.contains(song) ? selected.remove(song) : selected.add(song);
//                                         });
//                                       },
//                                       child: HoverWidget(
//                                         hoverChild: Container(
//                                           padding: EdgeInsets.all(width * 0.005),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(width * 0.01),
//                                             color: const Color(0xFF2E2E2E),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               ClipRRect(
//                                                   borderRadius: BorderRadius.circular(width * 0.01),
//                                                   child: FutureBuilder(
//                                                     future: WorkerController.getImage(song.path),
//                                                     builder: (context, snapshot) {
//                                                       return AspectRatio(
//                                                         aspectRatio: 1.0,
//                                                         child: snapshot.hasData?
//                                                         Stack(
//                                                           alignment: Alignment.center,
//                                                           children: [
//                                                             Container(
//                                                               decoration: BoxDecoration(
//                                                                   color: Colors.black,
//                                                                   image: DecorationImage(
//                                                                     fit: BoxFit.cover,
//                                                                     image: Image.memory(snapshot.data!).image,
//                                                                   )
//                                                               ),
//                                                             ),
//                                                             ClipRRect(
//                                                               child: BackdropFilter(
//                                                                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                                                                 child: Container(
//                                                                   color: Colors.black.withOpacity(0.3),
//                                                                   alignment: Alignment.center,
//                                                                   child: IconButton(
//                                                                     icon: Icon(selected.contains(song) ? FluentIcons.subtract : FluentIcons.add, color: Colors.white, size: height * 0.03,),
//                                                                     onPressed: () {
//                                                                       debugPrint("Add");
//                                                                       setState(() {
//                                                                         selected.contains(song) ? selected.remove(song) : selected.add(song);
//                                                                       });
//                                                                     },
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ) :
//                                                         snapshot.hasError?
//                                                         Center(
//                                                           child: Text(
//                                                             '${snapshot.error} occurred',
//                                                             style: const TextStyle(fontSize: 18),
//                                                           ),
//                                                         ) :
//                                                         Container(
//                                                           decoration: BoxDecoration(
//                                                               color: Colors.black,
//                                                               image: DecorationImage(
//                                                                 fit: BoxFit.cover,
//                                                                 image: Image.asset("assets/logo.png").image,
//                                                               )
//                                                           ),
//                                                           child: const Center(
//                                                             child: CircularProgressIndicator(
//                                                               color: Colors.white,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   )
//                                               ),
//                                               SizedBox(
//                                                 width: width * 0.005,
//                                               ),
//                                               Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                         song.title.toString().length > 30 ? "${song.title.toString().substring(0, 30)}..." : song.title.toString(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: normalSize,
//                                                         )
//                                                     ),
//                                                     SizedBox(
//                                                       height: height * 0.001,
//                                                     ),
//                                                     Text(song.trackArtist.toString().length > 30 ? "${song.trackArtist.toString().substring(0, 30)}..." : song.trackArtist.toString(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: smallSize,
//                                                         )
//                                                     ),
//                                                   ]
//                                               ),
//                                               const Spacer(),
//                                               Text(
//                                                   song.duration == 0 ? "??:??" : "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: normalSize,
//                                                   )
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         child: Container(
//                                           padding: EdgeInsets.all(width * 0.005),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(width * 0.01),
//                                             color: const Color(0xFF0E0E0E),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               ClipRRect(
//                                                   borderRadius: BorderRadius.circular(width * 0.01),
//                                                   child: FutureBuilder(
//                                                     future: WorkerController.getImage(song.path),
//                                                     builder: (context, snapshot) {
//                                                       return AspectRatio(
//                                                         aspectRatio: 1.0,
//                                                         child: snapshot.hasData?
//                                                         Stack(
//                                                           alignment: Alignment.center,
//                                                           children: [
//                                                             Container(
//                                                               decoration: BoxDecoration(
//                                                                   color: Colors.black,
//                                                                   image: DecorationImage(
//                                                                     fit: BoxFit.cover,
//                                                                     image: Image.memory(snapshot.data!).image,
//                                                                   )
//                                                               ),
//                                                             ),
//                                                             if(selected.contains(song))
//                                                               BackdropFilter(
//                                                                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                                                                 child: Container(
//                                                                   alignment: Alignment.center,
//                                                                   child: Icon(
//                                                                     FluentIcons.check,
//                                                                     size: height * 0.03,
//                                                                     color: Colors.white,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                           ],
//                                                         ) :
//                                                         snapshot.hasError?
//                                                         Center(
//                                                           child: Text(
//                                                             '${snapshot.error} occurred',
//                                                             style: const TextStyle(fontSize: 18),
//                                                           ),
//                                                         ) :
//                                                         Container(
//                                                           decoration: BoxDecoration(
//                                                               color: Colors.black,
//                                                               image: DecorationImage(
//                                                                 fit: BoxFit.cover,
//                                                                 image: Image.asset("assets/logo.png").image,
//                                                               )
//                                                           ),
//                                                           child: const Center(
//                                                             child: CircularProgressIndicator(
//                                                               color: Colors.white,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   )
//                                               ),
//                                               SizedBox(
//                                                 width: width * 0.005,
//                                               ),
//                                               Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                         song.title.toString().length > 30 ? "${song.title.toString().substring(0, 30)}..." : song.title.toString(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: normalSize,
//                                                         )
//                                                     ),
//                                                     SizedBox(
//                                                       height: height * 0.001,
//                                                     ),
//                                                     Text(song.trackArtist.toString().length > 30 ? "${song.trackArtist.toString().substring(0, 30)}..." : song.trackArtist.toString(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: smallSize,
//                                                         )
//                                                     ),
//                                                   ]
//                                               ),
//                                               const Spacer(),
//                                               Text(
//                                                   song.duration == 0 ? "??:??" : "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: normalSize,
//                                                   )
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ) :
//                             Text(
//                               'No results found',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: normalSize
//                               ),
//                             );
//                           }
//                           else if(snapshot.hasError){
//                             return Center(
//                               child: Text(
//                                 "Error occured. Try again later.",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: normalSize,
//                                 ),
//                               ),
//                             );
//                           }
//                           else{
//                             return const Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             );
//                           }
//                         }
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           ],
//         ),
//
//       ),
//     );
//   }
// }
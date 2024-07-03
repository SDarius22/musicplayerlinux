import 'package:flutter/material.dart';
import '../controller/controller.dart';


class Artists extends StatefulWidget{
  final Controller controller;
  const Artists({super.key, required this.controller});

  @override
  _ArtistsState createState() => _ArtistsState();
}


class _ArtistsState extends State<Artists>{
  int _hovereditem = -1;
  bool loading = false;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  int displayedalbum = -1;
  String artistsforalbum = "", playlistname = "New playlist";



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        cacheExtent: 1000,
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        controller: _scrollController,
        itemCount: widget.controller.repo.artists.length + 12,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 0.8 ,
            maxCrossAxisExtent: MediaQuery.of(context).size.width* 0.14,
            crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
            mainAxisSpacing: MediaQuery.of(context).size.width * 0.01
        ),
        itemBuilder: (BuildContext context, int sindex) {
          return sindex < widget.controller.repo.artists.length?
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event){
              setState(() {
                _hovereditem = sindex;
              });
            },
            onExit: (event){
              setState(() {
                _hovereditem = -1;
              });
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  displayedalbum = sindex;
                });
              },
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.2,
                      margin: EdgeInsets.only(bottom: 10),
                      // child: Stack(
                      //   children: [
                      //
                      //     widget.controller.repo.artists[sindex].songs.first.imageloaded ?
                      //     Container(
                      //       decoration: BoxDecoration(
                      //           color: Colors.black,
                      //           borderRadius: BorderRadius.circular(10),
                      //           image: DecorationImage(
                      //             fit: BoxFit.cover,
                      //             image: Image.memory(widget.controller.repo.artists[sindex].songs.first.image).image,
                      //           )
                      //       ),
                      //     ) :
                      //     widget.controller.loading?
                      //     Container(
                      //       decoration: BoxDecoration(
                      //           color: Colors.black,
                      //           borderRadius: BorderRadius.circular(10),
                      //           image: DecorationImage(
                      //             fit: BoxFit.cover,
                      //             image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                      //           )
                      //       ),
                      //       child: const Center(
                      //         child: CircularProgressIndicator(
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ) :
                      //     FutureBuilder(
                      //       future: widget.controller.imageretrieve(widget.controller.repo.artists[sindex].songs.first.path),
                      //       builder: (ctx, snapshot) {
                      //         if (snapshot.hasData) {
                      //           return
                      //             Container(
                      //               decoration: BoxDecoration(
                      //                   color: Colors.black,
                      //                   borderRadius: BorderRadius.circular(10),
                      //                   image: DecorationImage(
                      //                     fit: BoxFit.cover,
                      //                     image: Image.memory(snapshot.data!).image,
                      //                   )
                      //               ),
                      //             );
                      //         }
                      //         else if (snapshot.hasError) {
                      //           return Center(
                      //             child: Text(
                      //               '${snapshot.error} occurred',
                      //               style: TextStyle(fontSize: 18),
                      //             ),
                      //           );
                      //         } else{
                      //           return Container(
                      //             decoration: BoxDecoration(
                      //                 color: Colors.black,
                      //                 borderRadius: BorderRadius.circular(10),
                      //                 image: DecorationImage(
                      //                   fit: BoxFit.cover,
                      //                   image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                      //                 )
                      //             ),
                      //             child: Center(
                      //               child: CircularProgressIndicator(
                      //                 color: Colors.white,
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       },
                      //     ),
                      //     if (_hovereditem == sindex)
                      //       ClipRRect(
                      //         // Clip it cleanly.
                      //         child: BackdropFilter(
                      //           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      //           child: Container(
                      //             color: Colors.black.withOpacity(0.3),
                      //             alignment: Alignment.center,
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //               crossAxisAlignment: CrossAxisAlignment.center,
                      //               children: [
                      //                 IconButton(onPressed: (){
                      //                   print("Add ${sindex}");
                      //                   // _songstoadd.add(widget.controller.allmetadata[sindex]);
                      //                   // setState(() {
                      //                   //   addelement = true;
                      //                   // });
                      //                 },
                      //                   padding: EdgeInsets.all(0),
                      //                   icon:
                      //                   Icon(FluentIcons.add_12_filled, color: Colors.white, size: 40,),
                      //                 ),
                      //
                      //                 Icon(FluentIcons.open_16_filled, size: 110, color: Colors.white,),
                      //
                      //                 IconButton(onPressed: (){
                      //                   widget.controller.playingsongs.clear();
                      //                   widget.controller.playingsongs_unshuffled.clear();
                      //
                      //                   widget.controller.playingsongs.addAll(widget.controller.allalbums[sindex].songs);
                      //                   widget.controller.playingsongs_unshuffled.addAll(widget.controller.allalbums[sindex].songs);
                      //
                      //                   if(widget.controller.shuffle == true)
                      //                     widget.controller.playingsongs.shuffle();
                      //
                      //                   var file = File("assets/settings.json");
                      //                   widget.controller.settings1.lastplaying.clear();
                      //
                      //                   for(int i = 0; i < widget.controller.playingsongs.length; i++){
                      //                     widget.controller.settings1.lastplaying.add(widget.controller.playingsongs[i].path);
                      //                   }
                      //                   widget.controller.settings1.lastplayingindex = widget.controller.playingsongs.indexOf(widget.controller.playingsongs_unshuffled[0]);
                      //                   file.writeAsStringSync(jsonEncode(widget.controller.settings1.toJson()));
                      //
                      //                   widget.controller.index = widget.controller.settings1.lastplayingindex;
                      //                   widget.controller.playSong();
                      //                 },
                      //                   padding: EdgeInsets.all(0),
                      //                   icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 40,),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //   ],
                      // ),
                    ),
                  ),
                  Text(
                    widget.controller.repo.artists[sindex].name.length > 35 ? widget.controller.repo.artists[sindex].name.substring(0, 35) + "..." : widget.controller.repo.artists[sindex].name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ) :
          Container(
            height: 250,
            width: 250,
          );

        },
      ),
    );
  }

}
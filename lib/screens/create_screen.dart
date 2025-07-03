import 'package:bot_toast/bot_toast.dart';
import 'package:musicplayer/components/custom_tiling/list_component.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/playlist_provider.dart';
import 'package:musicplayer/providers/song_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CreateScreen extends StatefulWidget {
  static Route<void> route({required List<String> args}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/create', arguments: List<String>),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateScreen(args: args);
      },
    );
  }
  final List<String> args;
  const CreateScreen({super.key, required this.args});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  ValueNotifier<List<String>> selected = ValueNotifier<List<String>>([]);
  String playlistName = "";
  String playlistAdd = "last";
  String search = "";
  FocusNode searchNode = FocusNode();
  FocusNode nameNode = FocusNode();

  @override
  void initState() {
    var name = widget.args[0];
    var paths = widget.args.sublist(1);
    playlistName = name;
    if (paths.isNotEmpty) {
      selected.value.addAll(paths);
    }
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
      body: Container(
        width: width,
        height: height,
        padding: EdgeInsets.only(
            top: height * 0.02,
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.15
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
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
                    playlistName = value;
                  },
                ),
                ),
                Text("Where to add new songs?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize
                  ),
                ),
                DropdownButton<String>(
                    value: playlistAdd,
                    icon: Icon(
                      FluentIcons.down,
                      color: Colors.white,
                      size: height * 0.025,
                    ),
                    style: TextStyle(
                      fontSize: normalSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                    underline: Container(
                      height: 0,
                    ),
                    borderRadius: BorderRadius.circular(width * 0.01),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    items: const [
                      DropdownMenuItem(
                        value: 'first',
                        child: Text("At the beginning"),
                      ),
                      DropdownMenuItem(
                        value: 'last',
                        child: Text("At the end"),
                      ),
                    ],
                    onChanged: (String? newValue){
                      setState(() {
                        playlistAdd = newValue ?? 'last';
                      });
                    }
                ),
              ],
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Expanded(
              child: Container(
              padding: EdgeInsets.all(width * 0.01),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.02),
                color: const Color(0xFF242424),
              ),
              child: Column(
                children: [
                  TextFormField(
                    focusNode: searchNode,
                    onChanged: (value){
                      setState(() {
                        search = value;
                      });
                    },
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
                        labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,)
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Expanded(
                    child: Consumer<SongProvider>(
                      builder: (context, songProvider, child) {
                        return FutureBuilder(
                          future: Future(() => songProvider.getSongs(search, "Name", false),),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              debugPrint(snapshot.error.toString());
                              debugPrintStack();
                              return Center(
                                child: Text(
                                  "Error loading songs",
                                  style: TextStyle(color: Colors.white, fontSize: smallSize),
                                ),
                              );
                            }
                            debugPrint("Songs loaded: ${snapshot.data?.length ?? 0}");
                            return CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: EdgeInsets.only(
                                    right: width * 0.01,
                                    left: width * 0.01,
                                  ),
                                  sliver: ValueListenableBuilder<List<String>>(
                                    valueListenable: selected,
                                    builder: (context, selectedSongs, child) {
                                      return ListComponent(
                                        items: snapshot.data ?? [],
                                        itemExtent: height * 0.125,
                                        isSelected: (entity) {
                                          return selected.value.contains((entity as Song).path);
                                        },
                                        onTap: (entity) {
                                          debugPrint("Tapped on ${entity.name}");
                                          if (selected.value.contains((entity as Song).path)) {
                                            selected.value = List.from(selected.value)..remove(entity.path);
                                          } else {
                                            selected.value = List.from(selected.value)..add(entity.path);
                                          }
                                        },
                                        onLongPress: (entity) {
                                          debugPrint("Long pressed on ${entity.name}");
                                        },
                                      );
                                    },
                                  ),
                                )
                              ],
                            );
                          }
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                    onPressed: (){
                      if (playlistName.isEmpty) {
                        BotToast.showText(
                          text: "Playlist name cannot be empty",
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }
                      if (selected.value.isEmpty) {
                        BotToast.showText(
                          text: "You must select at least one song",
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }
                      debugPrint("Create new playlist");
                      var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
                      playlistProvider.addPlaylist(playlistName, selected.value, playlistAdd,);
                      BotToast.showText(
                        text: "Playlist created successfully",
                        duration: const Duration(seconds: 3),
                      );
                      selected.value.clear();
                      playlistName = "";
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize
                      ),
                    )
                ),
              ],
            ),
          ],
        ),

      ),
    );
  }
}
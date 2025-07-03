import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/list_component.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: Provider.of<AudioProvider>(context, listen: false).queueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("Queue is empty"),
            );
          }
          debugPrint("QueueTab: ${snapshot.data!.length} items loaded");
          return Scrollbar(
            controller: Provider.of<AppStateProvider>(context, listen: false).itemScrollController,
            thumbVisibility: true,
            child: CustomScrollView(
              controller: Provider.of<AppStateProvider>(context, listen: false).itemScrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    right: width * 0.01,
                    left: width * 0.01,
                    top: height * 0.01,
                  ),
                  sliver: ListComponent(
                    items: snapshot.data ?? [],
                    itemExtent: height * 0.1,
                    isSelected: (entity) {
                      return false;
                    },
                    onTap: (entity) async {
                      debugPrint("Tapped on: ${entity.name}");
                      var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                      await audioProvider.setCurrentIndex((entity as Song).path);

                    },
                    onLongPress: (entity) {
                      debugPrint("Long pressed on: ${entity.name}");
                      // audioProvider.showContextMenu(entity);
                    },
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}
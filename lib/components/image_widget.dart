import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/services/file_service.dart';

class ImageWidget extends StatefulWidget {
  final String? path;
  final String? url;
  final Widget? hoveredChild;
  final Widget? child;

  const ImageWidget({super.key, this.path, this.hoveredChild, this.url, this.child})
      : assert(path == null || url == null, "Cannot provide both a path and a url!")
  ;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ValueNotifier<bool> isHovered = ValueNotifier(false);
  late Future imageFuture;
  final ImageProvider image = Image.asset('assets/logo.png', fit: BoxFit.cover,).image;

  @override
  void initState() {
    super.initState();
    imageFuture = getImage();
  }

  Future getImage() {
    if (widget.path != null) {
      return Future(() async {
        final image = await FileService.getImage(widget.path!);
        return Image.memory(image).image;
      });
    }
    if (widget.url != null) {
      return Future(() async {
        return Image.network(widget.url ?? "").image;
      });
    }
    return Future(() async {
      return Image.asset('assets/logo.png', fit: BoxFit.cover,).image;
    });
  }

  Widget imageWidget(ImageProvider image) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: MouseRegion(
        onEnter: (event) {
          isHovered.value = true;
        },
        onExit: (event) {
          isHovered.value = false;
        },
        child:Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: image,
            ),
          ),
          child: widget.hoveredChild != null?
          ValueListenableBuilder(
              valueListenable: isHovered,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: value ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 0),
                      child: widget.child,
                    ),
                    AnimatedOpacity(
                      opacity: value ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 0),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            alignment: Alignment.center,
                            child: widget.hoveredChild,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
          ) :
          widget.child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: image,
                )
            ),
          );
        }
        return imageWidget(snapshot.data ?? image);
      },
    );
  }
}

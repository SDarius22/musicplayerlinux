import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/worker_controller.dart';

class ImageWidget extends StatefulWidget {
  final String? path;
  final String? url;
  final String heroTag;
  final Widget? hoveredChild;
  final Widget? child;

  const ImageWidget({super.key, this.path, this.hoveredChild, required this.heroTag, this.url, this.child})
      : assert(path == null || url == null, "Cannot provide both a path and a url!")
  ;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ValueNotifier<bool> isHovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    if (widget.url != null) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: MouseRegion(
          onEnter: (event) {
            isHovered.value = true;
          },
          onExit: (event) {
            isHovered.value = false;
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.network(widget.url ?? "").image,
                )
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
                              color: Colors.black.withOpacity(0.4),
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
    return FutureBuilder(
      future: WorkerController.getImage(widget.path ?? ""),
      builder: (context, snapshot) {
        return AspectRatio(
          aspectRatio: 1.0,
          child: snapshot.hasData?
          MouseRegion(
            onEnter: (event) {
              isHovered.value = true;
            },
            onExit: (event) {
              isHovered.value = false;
            },
            child: Hero(
              tag: widget.heroTag.toString(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.memory(snapshot.data!).image,
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
                                  color: Colors.black.withOpacity(0.4),
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
          ) :
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/bg.png', fit: BoxFit.cover,).image,
                )
            ),
          ),
        );
      },
    );
  }
}

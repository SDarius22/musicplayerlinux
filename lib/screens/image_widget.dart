import 'dart:ui';
import 'package:flutter/material.dart';
import '../controller/controller.dart';

class ImageWidget extends StatefulWidget {
  final Controller controller;
  final String? path;
  final String? url;
  final String? heroTag;
  final Widget? buttons;
  const ImageWidget({super.key, required this.controller, this.path, this.buttons, this.heroTag, this.url})
      : assert(path == null || url == null, "Cannot provide both a path and a url!")
  ;

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ValueNotifier<bool> isHovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    if(widget.path != null){
      return FutureBuilder(
        future: widget.controller.getImage(widget.path ?? ""),
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
              child: widget.heroTag != null?
                Hero(
                  tag: widget.heroTag.toString(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.memory(snapshot.data!).image,
                      ),
                    ),
                    child: widget.buttons != null?
                    ValueListenableBuilder(
                      valueListenable: isHovered,
                      builder: (context, value, child) {
                        return value ?
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              alignment: Alignment.center,
                              child: widget.buttons,
                            ),
                          ),
                        ) :
                        Container();
                      }
                    ) :
                    Container(),
                  ),
                ) :
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.memory(snapshot.data!).image,
                      )
                  ),
                  child: widget.buttons != null?
                  ValueListenableBuilder(
                      valueListenable: isHovered,
                      builder: (context, value, child) {
                        return value ?
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            alignment: Alignment.center,
                            child: widget.buttons,
                          ),
                        ) :
                        Container();
                      }
                  ) :
                  Container(),
                ),
            ) :
            snapshot.hasError?
            Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
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
    return AspectRatio(
      aspectRatio: 1.0,
      child: MouseRegion(
        onEnter: (event) {
          isHovered.value = true;
        },
        onExit: (event) {
          isHovered.value = false;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.network(widget.url ?? "").image,
                  )
              ),
            ),
            if(widget.buttons != null)
              ValueListenableBuilder(
                valueListenable: isHovered,
                builder: (context, value, child) {
                  return value?
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.center,
                        child: widget.buttons,
                      ),
                    ),
                  ) :
                  Container();
                },
              ),
          ],
        ),
      ),
    );

  }
}

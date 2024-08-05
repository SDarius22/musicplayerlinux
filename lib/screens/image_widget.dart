import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controller/controller.dart';

class ImageWidget extends StatefulWidget {
  final Controller controller;
  final String path;
  final String? heroTag;
  final Widget? buttons;
  const ImageWidget({super.key, required this.controller, required this.path, this.buttons, this.heroTag});

  @override
  _ImageWidget createState() => _ImageWidget();
}

class _ImageWidget extends State<ImageWidget> {
  ValueNotifier<bool> isHovered = ValueNotifier(false);
  Image image = Image.memory(File("assets/bg.png").readAsBytesSync());

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.controller.imageRetrieve(widget.path, false),
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: widget.heroTag ?? "${widget.path}hero",
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: Image.memory(snapshot.data!).image,
                            )
                        ),
                      ),
                    ),
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
                      image: image.image,
                    )
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
        );
      },
    );
  }
}

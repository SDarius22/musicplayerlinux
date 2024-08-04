import 'dart:io';
import 'dart:ui';
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
  bool isHovered = false;
  late Future imageFuture;
  Image image = Image.memory(File("assets/bg.png").readAsBytesSync());

  @override
  void initState() {
    imageFuture = widget.controller.imageRetrieve(widget.path, false);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageFuture,
      builder: (context, snapshot) {
        return AspectRatio(
          aspectRatio: 1.0,
          child: snapshot.hasData? 
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHovered = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    isHovered = false;
                  });
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
                    if (isHovered)
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            alignment: Alignment.center,
                            child: widget.buttons,
                          ),
                        ),
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

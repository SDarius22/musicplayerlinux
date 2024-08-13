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
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ValueNotifier<bool> isHovered = ValueNotifier(false);
  Image image = Image.asset('assets/bg.png', fit: BoxFit.cover,);

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
                    if(widget.heroTag != null)
                      Hero(
                        tag: widget.heroTag.toString(),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.memory(snapshot.data!).image,
                              )
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: Image.memory(snapshot.data!).image,
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
              ),
        );
      },
    );
  }
}

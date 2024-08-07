import 'package:flutter/material.dart';
import '../controller/controller.dart';
import '../utils/multivaluelistenablebuilder/mvlb.dart';

class UserMessageWidget extends StatefulWidget {
  final Controller controller;
  const UserMessageWidget({super.key, required this.controller});

  @override
  _UserMessageWidgetState createState() => _UserMessageWidgetState();
}

class _UserMessageWidgetState extends State<UserMessageWidget> {

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(
        top: height * 0.05,
        bottom: height * 0.8,
        left: width * 0.01,
        right: width * 0.75,
      ),
      child: Center(
        child: MultiValueListenableBuilder(
          valueListenables: [widget.controller.userMessageNotifier, widget.controller.userMessageProgressNotifier],
          builder: (context, value, child) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.01),
                color: Colors.black,
              ),
              padding: EdgeInsets.only(
                left: width * 0.02,
                right: width * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.controller.userMessageNotifier.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                    ),
                  ),
                  SizedBox(height: height * 0.01,),
                  LinearProgressIndicator(
                    value: widget.controller.userMessageProgressNotifier.value < 0 ? 0 : widget.controller.userMessageProgressNotifier.value / 3500,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  ),
                ],
              )
            );
          },
        ),
      )
    );
  }
}

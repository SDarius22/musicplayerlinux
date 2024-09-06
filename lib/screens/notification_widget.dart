import 'package:flutter/material.dart';
import '../controller/controller.dart';


class NotificationWidget extends StatefulWidget {
  final Controller controller;
  const NotificationWidget({super.key, required this.controller});

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    //var smallSize = height * 0.015;
    return ValueListenableBuilder(
      valueListenable: widget.controller.notification,
      builder: (context, value, child){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: value == "" ? 0 : height * 0.07,
          padding: EdgeInsets.symmetric(horizontal: width * 0.01),
          color: const Color(0xFF0E0E0E),
          child: Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: normalSize,
                ),
              ),
              const Spacer(),
              widget.controller.actions,
            ],
          ),
        );
      },
    );

  }
}

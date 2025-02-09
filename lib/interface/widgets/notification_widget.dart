import 'package:flutter/material.dart';
import '../../controller/app_manager.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  @override
  Widget build(BuildContext context) {
    final am = AppManager();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    return ValueListenableBuilder(
      valueListenable: am.notificationMessage,
      builder: (context, value, child){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: value == "" ? 0 : height * 0.07,
          width: width * 0.85,
          padding: EdgeInsets.symmetric(horizontal: width * 0.01),
          margin: EdgeInsets.only(top: value == "" ? 0 : height * 0.15),
          color: const Color(0xFF0E0E0E),
          alignment: Alignment.center,
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
              am.actions,
            ],
          ),
        );
      },
    );

  }
}

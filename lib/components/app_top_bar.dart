import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;

  const AppBarWidget({
    super.key,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<AppStateProvider>(
      builder: (_, appStateProvider, __){
        return PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: WindowTitleBarBox(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: appStateProvider.darkColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: MoveWindow(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: width * 0.01
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Music Player',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.height * 0.02,
                            ),
                          ),
                        ),
                      )
                  ),
                  MinimizeWindowButton(
                    animate: true,
                    colors: WindowButtonColors(
                      normal: Colors.transparent,
                      iconNormal: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.grey,
                      mouseDown: Colors.grey,
                    ),
                  ),
                  appWindow.isMaximized ?
                  RestoreWindowButton(
                    animate: true,
                    colors: WindowButtonColors(
                      normal: Colors.transparent,
                      iconNormal: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.grey,
                      mouseDown: Colors.grey,
                    ),
                  ) :
                  MaximizeWindowButton(
                    animate: true,
                    colors: WindowButtonColors(
                      normal: Colors.transparent,
                      iconNormal: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.grey,
                      mouseDown: Colors.grey,
                    ),
                  ),
                  CloseWindowButton(
                    animate: true,
                    onPressed: () {
                      if (appStateProvider.appSettings.fullClose) {
                        appWindow.close();
                      }
                      else {
                        appWindow.hide();
                      }
                    },
                    colors: WindowButtonColors(
                      normal: Colors.transparent,
                      iconNormal: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.grey,
                      mouseDown: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
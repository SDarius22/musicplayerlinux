import 'package:flutter/material.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:provider/provider.dart';

class VolumeWidget extends StatefulWidget {
  const VolumeWidget({
    super.key,
  });

  @override
  State<VolumeWidget> createState() => _VolumeWidgetState();
}

class _VolumeWidgetState extends State<VolumeWidget> {
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  late final AudioProvider _audioProvider;

  @override
  void initState() {
    super.initState();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ValueListenableBuilder(
      valueListenable: _visible,
      builder: (context, value, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: _visible.value,
              child: MouseRegion(
                onEnter: (event) {
                  _visible.value = true;
                },
                onExit: (event) {
                  _visible.value = false;
                },
                child: SizedBox(
                  width: width * 0.1,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: height * 0.0075
                      ),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _audioProvider.volumeNotifier,
                      builder: (context, value, child) {
                        return Slider(
                          min: 0.0,
                          max: 1.0,
                          mouseCursor: SystemMouseCursors.click,
                          value: value,
                          activeColor: Colors.white,
                          thumbColor: Colors.white,
                          inactiveColor: Colors.white,
                          onChangeEnd: (double value) {
                            _audioProvider.setVolume(value);
                          },
                          onChanged: (double value) {
                            _audioProvider.volumeNotifier.value = value;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (event) {
                _visible.value = true;
              },
              onExit: (event) {
                _visible.value = false;
              },
              child: ValueListenableBuilder(
                valueListenable: _audioProvider.volumeNotifier,
                builder: (context, value, child) {
                  return IconButton(
                    icon: value > 0.0 ? Icon(
                      FluentIcons.volumeOn,
                      size: height * 0.0175,
                      color: Colors.white,
                    ) :
                    Icon(
                      FluentIcons.volumeOff,
                      size: height * 0.0175,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (value > 0.0) {
                        _audioProvider.setVolume(0.0);
                      } else {
                        _audioProvider.setVolume(0.25);
                      }
                    },
                  );
                }
              )
            ),
          ],
        );

      }
    );
  }
}
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/providers/audio_provider.dart';

class SliderProvider with ChangeNotifier {
  final AudioProvider _audioProvider;
  int slider = 0;
  bool playing = false;

  SliderProvider(this._audioProvider){
    _audioProvider.audioPlayer.onPositionChanged.listen((Duration event) {
      slider = event.inMilliseconds;
      _audioProvider.setSlider(slider);
      notifyListeners();
    });
    _audioProvider.audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      playing = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        if (_audioProvider.repeat) {
          slider = 0;
          _audioProvider.play();
        } else {
          _audioProvider.skipToNext();
        }
      }
    });
  }

  void setSlider(int value) {
    slider = value;
    _audioProvider.audioPlayer.seek(Duration(milliseconds: value));
    _audioProvider.setSlider(value);
    notifyListeners();
  }
}